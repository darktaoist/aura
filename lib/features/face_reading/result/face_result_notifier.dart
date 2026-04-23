import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/gemma/gemma_service.dart';
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
    this.isModelError = false,
  });

  final String fullText;
  final bool isStreaming;
  final bool isSaving;
  final String? error;
  /// true: 모델 파일 손상/누락 → 모델 재설치 안내 필요
  final bool isModelError;

  bool get hasContent => fullText.isNotEmpty;

  FaceResultState copyWith({
    String? fullText,
    bool? isStreaming,
    bool? isSaving,
    String? error,
    bool? isModelError,
    bool clearError = false,
  }) =>
      FaceResultState(
        fullText: fullText ?? this.fullText,
        isStreaming: isStreaming ?? this.isStreaming,
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : error ?? this.error,
        isModelError: isModelError ?? (clearError ? false : this.isModelError),
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
    if (state.isStreaming) return; // 중복 호출 방어
    state = state.copyWith(isStreaming: true, fullText: '', clearError: true);

    try {
      final svc = await ref.read(gemmaServiceProvider.future);
      final stream = svc.analyzeLongForm(
        result: result,
        locale: locale,
        ragChunks: ragChunks,
      );

      var buffer = '';
      await for (final token in stream) {
        buffer += token;
        if (buffer.length >= 20) {
          state = state.copyWith(fullText: state.fullText + buffer);
          buffer = '';
        }
      }
      if (buffer.isNotEmpty) {
        state = state.copyWith(fullText: state.fullText + buffer);
      }

      state = state.copyWith(isStreaming: false);
    } catch (e) {
      final msg = e.toString();
      final isModelErr = msg.contains('model') ||
          msg.contains('Model') ||
          msg.contains('Unsupported') ||
          msg.contains('StateError');
      state = state.copyWith(
        isStreaming: false,
        error: msg,
        isModelError: isModelErr,
      );
    }
  }

  Future<Reading?> saveReading({
    required String userId,
    required FaceLandmarkResult landmarkResult,
    required String modelUsed,
    required String locale,
  }) async {
    if (state.fullText.isEmpty) return null;
    state = state.copyWith(isSaving: true);
    try {
      final reading = await ref.read(readingRepositoryProvider).saveReading(
            userId: userId,
            type: ReadingType.face,
            landmarkResult: landmarkResult,
            resultText: state.fullText,
            modelUsed: modelUsed,
            locale: locale,
          );
      state = state.copyWith(isSaving: false);
      return reading;
    } catch (e) {
      // 저장 실패는 분석 결과를 지우지 않도록 error 상태에 반영하지 않음
      state = state.copyWith(isSaving: false);
      return null;
    }
  }
}
