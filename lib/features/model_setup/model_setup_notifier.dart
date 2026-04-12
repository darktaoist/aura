import 'dart:io';

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'model_config.dart';

part 'model_setup_notifier.g.dart';

enum ModelSetupPhase { idle, scanning, registering, downloading, done, error }

class ModelSetupState {
  const ModelSetupState({
    this.phase = ModelSetupPhase.idle,
    this.progress = 0,
    this.errorMessage,
    this.foundLocalPath,
  });

  final ModelSetupPhase phase;
  final int progress;          // 0–100 (다운로드 진행률)
  final String? errorMessage;
  final String? foundLocalPath;

  bool get isDone => phase == ModelSetupPhase.done;
  bool get isError => phase == ModelSetupPhase.error;
  bool get isDownloading => phase == ModelSetupPhase.downloading;

  ModelSetupState copyWith({
    ModelSetupPhase? phase,
    int? progress,
    String? errorMessage,
    String? foundLocalPath,
  }) =>
      ModelSetupState(
        phase: phase ?? this.phase,
        progress: progress ?? this.progress,
        errorMessage: errorMessage ?? this.errorMessage,
        foundLocalPath: foundLocalPath ?? this.foundLocalPath,
      );
}

@riverpod
class ModelSetupNotifier extends _$ModelSetupNotifier {
  @override
  ModelSetupState build() => const ModelSetupState();

  Future<void> start() async {
    state = state.copyWith(phase: ModelSetupPhase.scanning);

    final localPath = await scanLocal();
    if (localPath != null) {
      state = state.copyWith(
        phase: ModelSetupPhase.registering,
        foundLocalPath: localPath,
      );
      await _registerFile(localPath);
    } else {
      state = state.copyWith(phase: ModelSetupPhase.downloading);
      await _download();
    }
  }

  /// 기기 내 .litertlm 파일 스캔 (Android only)
  Future<String?> scanLocal() async {
    if (!Platform.isAndroid) return null;

    for (final dir in kScanDirs) {
      try {
        final d = Directory(dir);
        if (!d.existsSync()) continue;
        for (final entity in d.listSync(followLinks: false)) {
          if (entity is File) {
            final lower = entity.path.toLowerCase();
            if (kModelExtensions.any(lower.endsWith)) {
              return entity.path;
            }
          }
        }
      } catch (_) {
        // 접근 불가 디렉토리는 건너뜀
      }
    }
    return null;
  }

  Future<void> _registerFile(String path) async {
    try {
      final config = configForFile(path);
      await FlutterGemma.installModel(
        modelType: config.modelType,
        fileType: config.fileType,
      ).fromFile(path).install();
      state = state.copyWith(phase: ModelSetupPhase.done);
    } catch (_) {
      // 로컬 파일 등록 실패 → 다운로드로 폴백
      state = state.copyWith(phase: ModelSetupPhase.downloading);
      await _download();
    }
  }

  Future<void> _download() async {
    try {
      await FlutterGemma.installModel(
        modelType: kDefaultModel.modelType,
        fileType: kDefaultModel.fileType,
      )
          .fromNetwork(kDefaultModel.downloadUrl)
          .withProgress((p) {
            state = state.copyWith(progress: p);
          })
          .install();
      state = state.copyWith(phase: ModelSetupPhase.done);
    } catch (e) {
      state = state.copyWith(
        phase: ModelSetupPhase.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> retry() async {
    state = const ModelSetupState();
    await start();
  }
}
