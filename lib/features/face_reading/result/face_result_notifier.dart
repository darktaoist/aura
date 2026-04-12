import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/gemma/prompt_builder.dart';
import '../../../data/supabase/reading_repository.dart';
import '../../../domain/entities/landmark_result.dart';
import '../../../domain/entities/reading.dart';

part 'face_result_notifier.g.dart';

class FaceResultState {
  const FaceResultState({
    this.fullText = '',
    this.isStreaming = false,
    this.isSaving = false,
    this.error,
  });

  final String fullText;
  final bool isStreaming;
  final bool isSaving;
  final String? error;

  bool get hasContent => fullText.isNotEmpty;

  FaceResultState copyWith({
    String? fullText,
    bool? isStreaming,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) =>
      FaceResultState(
        fullText: fullText ?? this.fullText,
        isStreaming: isStreaming ?? this.isStreaming,
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : error ?? this.error,
      );
}

@riverpod
class FaceResultNotifier extends _$FaceResultNotifier {
  InferenceChat? _chat;

  @override
  FaceResultState build() {
    ref.onDispose(_closeChat);
    return const FaceResultState();
  }

  Future<void> analyze({
    required FaceLandmarkResult result,
    required String locale,
    List<String> ragChunks = const [],
  }) async {
    state = state.copyWith(isStreaming: true, fullText: '', clearError: true);

    try {
      // 이전 chat 세션 해제 (fresh session 보장)
      _closeChat();

      final model = await FlutterGemma.getActiveModel(
        maxTokens: AppConst.gemmaMaxTokens,
      );

      final systemInstruction =
          kLongFormSystemPrompts[locale] ?? kLongFormSystemPrompts['ko']!;

      _chat = await model.createChat(  // returns InferenceChat
        modelType: ModelType.gemmaIt,
        systemInstruction: systemInstruction,
        temperature: AppConst.gemmaTemp,
        topK: AppConst.gemmaTopK,
      );

      final prompt = PromptBuilder.buildLongFormPrompt(
        result: result,
        locale: locale,
        ragChunks: ragChunks,
      );

      await _chat!.addQueryChunk(Message(text: prompt, isUser: true));

      final buffer = StringBuffer();
      await for (final response in _chat!.generateChatResponseAsync()) {
        if (response is TextResponse) {
          buffer.write(response.token);
          state = state.copyWith(fullText: buffer.toString());
        }
      }

      state = state.copyWith(isStreaming: false);
    } catch (e) {
      debugPrint('[FaceResultNotifier] analyze error: $e');
      state = state.copyWith(isStreaming: false, error: e.toString());
    } finally {
      _closeChat();
    }
  }

  void _closeChat() {
    // InferenceChat은 별도 close API 없음 — 참조 해제로 GC 유도
    _chat = null;
  }

  Future<bool> saveReading({
    required String userId,
    required FaceLandmarkResult landmarkResult,
    required String modelUsed,
    required String locale,
  }) async {
    if (state.fullText.isEmpty) return false;
    state = state.copyWith(isSaving: true);
    try {
      await ref.read(readingRepositoryProvider).saveReading(
            userId: userId,
            type: ReadingType.face,
            landmarkResult: landmarkResult,
            resultText: state.fullText,
            modelUsed: modelUsed,
            locale: locale,
          );
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}
