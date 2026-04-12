import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/gemma/prompt_builder.dart';
import '../../../data/supabase/reading_repository.dart';
import '../../../domain/entities/landmark_result.dart';

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
  }) =>
      FaceResultState(
        fullText: fullText ?? this.fullText,
        isStreaming: isStreaming ?? this.isStreaming,
        isSaving: isSaving ?? this.isSaving,
        error: error ?? this.error,
      );
}

@riverpod
class FaceResultNotifier extends _$FaceResultNotifier {
  @override
  FaceResultState build() => const FaceResultState();

  Future<void> analyze({
    required FaceLandmarkResult result,
    required String locale,
    List<String> ragChunks = const [],
  }) async {
    state = state.copyWith(isStreaming: true, fullText: '');

    final model = await FlutterGemma.getActiveModel(
      maxTokens: AppConst.gemmaMaxTokens,
    );

    final systemInstruction =
        kLongFormSystemPrompts[locale] ?? kLongFormSystemPrompts['ko']!;

    final chat = await model.createChat(
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

    await chat.addQueryChunk(Message(text: prompt, isUser: true));

    final buffer = StringBuffer();
    await for (final response in chat.generateChatResponseAsync()) {
      if (response is TextResponse) {
        buffer.write(response.token);
        state = state.copyWith(fullText: buffer.toString());
      }
    }

    state = state.copyWith(isStreaming: false);
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
