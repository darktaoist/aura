import 'dart:async';

import 'package:flutter/foundation.dart';
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
  StreamSubscription<String>? _sub;
  GemmaService? _svc;
  bool _disposed = false;

  @override
  FaceResultState build() {
    ref.onDispose(() {
      _disposed = true;
      _sub?.cancel();
      _sub = null;
      _svc?.cancelCurrentGeneration();
      _svc?.disposeSession();
      _svc = null;
    });
    return const FaceResultState();
  }

  Future<void> analyze({
    required FaceLandmarkResult result,
    required String locale,
    List<String> ragChunks = const [],
  }) async {
    debugPrint('[FaceResultNotifier] analyze 호출 locale=$locale ragChunks=${ragChunks.length}');
    // 진행 중인 분석 취소 후 재시작
    _sub?.cancel();
    _sub = null;
    _svc?.cancelCurrentGeneration();

    state = state.copyWith(isStreaming: true, fullText: '', clearError: true);

    try {
      final svc = await ref.read(gemmaServiceProvider.future);
      if (_disposed) return;
      _svc = svc;
      debugPrint('[FaceResultNotifier] GemmaService 획득 완료, 스트림 시작');
      final stream = svc.analyzeLongForm(
        result: result,
        locale: locale,
        ragChunks: ragChunks,
      );

      var buffer = '';
      _sub = stream.listen(
        (token) {
          if (_disposed) return;
          buffer += token;
          if (buffer.length == token.length) {
            debugPrint('[FaceResultNotifier] 첫 토큰 수신: "${token.substring(0, token.length.clamp(0, 20))}"');
          }
          if (buffer.length >= 20) {
            state = state.copyWith(fullText: state.fullText + buffer);
            buffer = '';
          }
        },
        onDone: () {
          if (_disposed) return;
          debugPrint('[FaceResultNotifier] onDone, buffer=${buffer.length}, fullText=${state.fullText.length}');
          if (buffer.isNotEmpty) {
            state = state.copyWith(fullText: state.fullText + buffer);
          }
          state = state.copyWith(isStreaming: false);
          _sub = null;
        },
        onError: (e) {
          if (_disposed) return;
          debugPrint('[FaceResultNotifier] onError: $e');
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
      debugPrint('[FaceResultNotifier] 구독 등록 완료');
    } catch (e) {
      debugPrint('[FaceResultNotifier] catch: $e');
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
    String subjectName = '나',
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
            subjectName: subjectName,
          );
      state = state.copyWith(isSaving: false);
      return reading;
    } catch (e) {
      debugPrint('[FaceResultNotifier] saveReading error: $e');
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }
}
