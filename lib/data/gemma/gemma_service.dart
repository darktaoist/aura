import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/landmark_result.dart';
import '../../domain/entities/palm_result.dart';
import 'prompt_builder.dart';

part 'gemma_service.g.dart';

/// 앱 생애 동안 단 한 번만 로드되는 Gemma 모델 서비스.
/// keepAlive=true 로 provider가 dispose 되지 않고 모델을 보존한다.
@Riverpod(keepAlive: true)
Future<GemmaService> gemmaService(GemmaServiceRef ref) async {
  final svc = await GemmaService.load();
  ref.onDispose(svc.dispose);
  return svc;
}

class GemmaService {
  GemmaService._(InferenceModel model, this.backend) : _model = model;

  final InferenceModel _model;
  final PreferredBackend backend;
  bool get isReady => true;

  // Inference serialization: ensures only one createChat() runs at a time.
  // When a session is cancelled mid-stream, stopGeneration() halts native
  // inference and leaves the model idle. The next createChat() call then
  // starts a fully independent session without model.close() or reload.
  Future<void> _lock = Future.value();
  int _generation = 0;

  // Callback to set `done=true` in the currently running _streamResponse closure.
  void Function()? _cancelCurrent;

  /// Immediately signals the current streaming session to stop.
  /// Safe to call at any time; no-op when nothing is running.
  void cancelCurrentGeneration() {
    _cancelCurrent?.call();
    _cancelCurrent = null;
  }

  /// Invalidates any queued (not-yet-started) session so it exits on entry.
  /// Call after cancelCurrentGeneration() when the caller is tearing down.
  void disposeSession() {
    ++_generation;
    _cancelCurrent = null;
  }

  static Future<GemmaService> load() async {
    final (model, backend) = await _loadWithFallback();
    return GemmaService._(model, backend);
  }

  static Future<(InferenceModel, PreferredBackend)> _loadWithFallback() async {
    for (final backend in [PreferredBackend.gpu, PreferredBackend.cpu]) {
      try {
        final model = await FlutterGemma.getActiveModel(
          maxTokens: AppConst.gemmaMaxTokens,
          preferredBackend: backend,
        );
        debugPrint('[GemmaService] 모델 로드 완료 backend=$backend maxTokens=${AppConst.gemmaMaxTokens}');
        return (model, backend);
      } catch (e) {
        debugPrint('[GemmaService] $backend 백엔드 실패, 다음 시도: $e');
      }
    }
    throw StateError('[GemmaService] GPU·CPU 모든 백엔드에서 모델 로드 실패');
  }

  /// 결과화면용 장문 스트리밍 분석
  Stream<String> analyzeLongForm({
    required FaceLandmarkResult result,
    required String locale,
    List<String> ragChunks = const [],
  }) {
    return _streamResponse(
      systemInstruction: kLongFormSystemPrompts[locale] ??
          kLongFormSystemPrompts['ko']!,
      userPrompt: PromptBuilder.buildLongFormPrompt(
        result: result,
        locale: locale,
        ragChunks: ragChunks,
      ),
    );
  }

  /// 손금 결과화면용 장문 스트리밍 분석
  Stream<String> analyzePalmLongForm({
    required PalmLandmarkResult result,
    required String locale,
    List<String> ragChunks = const [],
  }) {
    return _streamResponse(
      systemInstruction: kPalmLongFormSystemPrompts[locale] ??
          kPalmLongFormSystemPrompts['ko']!,
      userPrompt: PromptBuilder.buildPalmLongFormPrompt(
        result: result,
        locale: locale,
        ragChunks: ragChunks,
      ),
    );
  }

  Stream<String> _streamResponse({
    required String systemInstruction,
    required String userPrompt,
  }) {
    final myGen = ++_generation;
    var done = false;

    // Register cancel hook so cancelCurrentGeneration() can signal this closure.
    _cancelCurrent = () { done = true; };

    debugPrint('[GemmaService] gen=$myGen _streamResponse 시작, gen전역=$_generation');
    late StreamController<String> ctrl;
    ctrl = StreamController<String>(
      onCancel: () {
        done = true;
        debugPrint('[GemmaService] gen=$myGen onCancel 호출 → done=true');
      },
    );

    _lock = _lock.then((_) async {
      debugPrint('[GemmaService] gen=$myGen 락 진입, done=$done, curGen=$_generation');
      if (myGen != _generation || done) {
        if (!ctrl.isClosed) ctrl.close();
        debugPrint('[GemmaService] gen=$myGen 스킵 (superseded=${myGen != _generation}, done=$done)');
        return;
      }

      var stopped = false;
      var tokenCount = 0;
      // Declared outside try so finally can close it.
      // Without chat.close(), MobileInferenceModel._createCompleter is never
      // cleared and every subsequent createChat() reuses the same dirty session.
      InferenceChat? chat;
      try {
        debugPrint('[GemmaService] gen=$myGen createChat 호출');
        chat = await _model.createChat(
          modelType: ModelType.gemmaIt,
          systemInstruction: systemInstruction,
          temperature: AppConst.gemmaTemp,
          topK: AppConst.gemmaTopK,
        );
        debugPrint('[GemmaService] gen=$myGen createChat 완료, done=$done');
        if (done) {
          debugPrint('[GemmaService] gen=$myGen createChat 후 done=true → 조기 종료');
          return;
        }

        await chat.addQueryChunk(Message(text: userPrompt, isUser: true));
        debugPrint('[GemmaService] gen=$myGen addQueryChunk 완료, done=$done');
        if (done) {
          debugPrint('[GemmaService] gen=$myGen addQueryChunk 후 done=true → 조기 종료');
          return;
        }

        debugPrint('[GemmaService] gen=$myGen generateChatResponseAsync 시작');
        await for (final response in chat.generateChatResponseAsync()) {
          if (done) {
            // Do NOT call stopGeneration() here — chat.close() in finally
            // handles it exactly once. Calling it here too causes a race:
            // the native cancel lingers in the platform channel queue and
            // can kill the next session's prefill (seen as gen+2 "Process
            // cancelled" PlatformException before any tokens are generated).
            stopped = true;
            break;
          }
          if (response is TextResponse) {
            ctrl.add(response.token);
            tokenCount++;
            if (tokenCount == 1) {
              debugPrint('[GemmaService] gen=$myGen 첫 토큰: "${response.token}"');
            }
          }
        }
        debugPrint('[GemmaService] gen=$myGen generateChatResponseAsync 완료, 토큰=$tokenCount');
      } catch (e) {
        debugPrint('[GemmaService] gen=$myGen 추론 에러: $e');
        if (!ctrl.isClosed) ctrl.addError(e);
      } finally {
        // Release the native session so MobileInferenceModel._createCompleter is
        // cleared and the next createChat() gets a truly fresh session.
        try {
          await chat?.close();
        } catch (e) {
          debugPrint('[GemmaService] gen=$myGen chat.close() 오류 무시: $e');
        }
        if (!ctrl.isClosed) ctrl.close();
        debugPrint('[GemmaService] gen=$myGen 락 해제 (stopped=$stopped, tokens=$tokenCount)');
      }
    }).catchError((Object e) {
      debugPrint('[GemmaService] gen=$myGen 락체인 에러: $e');
    });

    return ctrl.stream;
  }

  void dispose() {
    _model.close();
  }
}
