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
  GemmaService._(this._model);

  final InferenceModel _model;
  InferenceChat? _activeChat;   // 현재 활성 채팅 세션 추적
  bool get isReady => true;

  static Future<GemmaService> load() async {
    final model = await FlutterGemma.getActiveModel(
      maxTokens: AppConst.gemmaMaxTokens,
    );
    debugPrint('[GemmaService] 모델 로드 완료 (maxTokens=${AppConst.gemmaMaxTokens})');
    return GemmaService._(model);
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
  }) async* {
    // 이전 채팅이 열려 있으면 먼저 닫아 모델 컨텍스트를 초기화.
    // 플래그만 리셋하면 이전 InferenceChat의 KV-캐시가 남아
    // 새 분석 결과에 이전 내용이 섞이는 문제가 발생.
    if (_activeChat != null) {
      debugPrint('[GemmaService] closing previous chat before new inference');
      try { await _activeChat!.close(); } catch (_) {}
      _activeChat = null;
    }
    try {
      final chat = await _model.createChat(
        modelType: ModelType.gemmaIt,
        systemInstruction: systemInstruction,
        temperature: AppConst.gemmaTemp,
        topK: AppConst.gemmaTopK,
      );
      _activeChat = chat;
      await chat.addQueryChunk(Message(text: userPrompt, isUser: true));

      await for (final response in chat.generateChatResponseAsync()) {
        if (response is TextResponse) {
          yield response.token;
        }
      }
    } catch (e) {
      debugPrint('[GemmaService] inference error: $e');
      rethrow;
    } finally {
      _activeChat = null;
    }
  }

  void dispose() {
    _model.close();
  }
}
