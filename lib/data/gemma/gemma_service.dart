import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/landmark_result.dart';
import 'prompt_builder.dart';

class GemmaService {
  GemmaService._();

  InferenceModel? _model;
  bool get isReady => _model != null;

  static Future<GemmaService> load() async {
    final svc = GemmaService._();
    await svc._init();
    return svc;
  }

  Future<void> _init() async {
    try {
      _model = await FlutterGemma.getActiveModel(
        maxTokens: AppConst.gemmaMaxTokens,
      );
    } catch (e) {
      debugPrint('[GemmaService] load error: $e');
    }
  }

  /// 실시간 오버레이용 짧은 스트리밍 분석
  Stream<String> analyzeRealtime({
    required FaceFeatures features,
    required String locale,
  }) {
    return _streamResponse(
      systemInstruction: kRealtimeSystemPrompts[locale] ??
          kRealtimeSystemPrompts['ko']!,
      userPrompt: PromptBuilder.buildRealtimePrompt(features, locale),
    );
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

  Stream<String> _streamResponse({
    required String systemInstruction,
    required String userPrompt,
  }) async* {
    final model = _model;
    if (model == null) {
      yield '[오류] Gemma 모델이 로드되지 않았습니다.';
      return;
    }

    try {
      final chat = await model.createChat(
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
      yield '[분석 오류] $e';
    }
  }

  void dispose() {
    _model?.close();
    _model = null;
  }
}
