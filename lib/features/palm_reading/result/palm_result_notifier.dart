import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/gemma/gemma_service.dart';
import '../../../data/supabase/reading_repository.dart';
import '../../../domain/entities/palm_result.dart';
import '../../../domain/entities/reading.dart';

part 'palm_result_notifier.g.dart';

class PalmResultState {
  const PalmResultState({
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
  final bool isModelError;

  bool get hasContent => fullText.isNotEmpty;

  PalmResultState copyWith({
    String? fullText,
    bool? isStreaming,
    bool? isSaving,
    String? error,
    bool? isModelError,
    bool clearError = false,
  }) =>
      PalmResultState(
        fullText: fullText ?? this.fullText,
        isStreaming: isStreaming ?? this.isStreaming,
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : error ?? this.error,
        isModelError: isModelError ?? (clearError ? false : this.isModelError),
      );
}

@riverpod
class PalmResultNotifier extends _$PalmResultNotifier {
  StreamSubscription<String>? _sub;

  @override
  PalmResultState build() => const PalmResultState();

  Future<void> analyze({
    required PalmLandmarkResult result,
    required String locale,
    List<String> ragChunks = const [],
  }) async {
    // 진행 중인 분석 취소 후 재시작 (locale 변경 시 등)
    await _sub?.cancel();
    _sub = null;

    state = state.copyWith(isStreaming: true, fullText: '', clearError: true);

    try {
      final svc = await ref.read(gemmaServiceProvider.future);
      final stream = svc.analyzePalmLongForm(
        result: result,
        locale: locale,
        ragChunks: ragChunks,
      );

      var buffer = '';
      _sub = stream.listen(
        (token) {
          buffer += token;
          if (buffer.length >= 20) {
            state = state.copyWith(fullText: state.fullText + buffer);
            buffer = '';
          }
        },
        onDone: () {
          if (buffer.isNotEmpty) {
            state = state.copyWith(fullText: state.fullText + buffer);
          }
          state = state.copyWith(isStreaming: false);
          _sub = null;
        },
        onError: (e) {
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
          _sub = null;
        },
        cancelOnError: true,
      );
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
    required PalmLandmarkResult landmarkResult,
    required String modelUsed,
    required String locale,
    String subjectName = '나',
  }) async {
    if (state.fullText.isEmpty) return null;
    state = state.copyWith(isSaving: true);
    try {
      final reading = await ref.read(readingRepositoryProvider).savePalmReading(
            userId: userId,
            landmarkResult: landmarkResult,
            resultText: state.fullText,
            modelUsed: modelUsed,
            locale: locale,
            subjectName: subjectName,
          );
      state = state.copyWith(isSaving: false);
      return reading;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return null;
    }
  }
}
