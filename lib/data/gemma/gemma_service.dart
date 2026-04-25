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
    // createChat()은 매번 새 systemInstruction으로 독립 컨텍스트를 생성.
    // 이전 chat.close() 호출은 InferenceModel 내부 공유 상태를 훼손해
    // 새 채팅이 조기 종료되는 부작용이 있어 제거.
    try {
      final chat = await _model.createChat(
        modelType: ModelType.gemmaIt,
        systemInstruction: systemInstruction,
        temperature: AppConst.gemmaTemp,
        topK: AppConst.gemmaTopK,
      );
      await chat.addQueryChunk(Message(text: userPrompt, isUser: true));

      await for (final response in chat.generateChatResponseAsync()) {
        if (response is TextResponse) {
          yield response.token;
        }
      }
    } catch (e) {
      debugPrint('[GemmaService] inference error: $e');
      rethrow;
    }
  }

  void dispose() {
    _model.close();
  }
}
