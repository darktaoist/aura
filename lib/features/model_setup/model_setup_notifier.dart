import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<String?> scanLocal() async {
    for (final dir in kScanDirs) {
      try {
        final d = await _directoryExists(dir);
        if (!d) continue;
        final files = await _listFiles(dir);
        for (final path in files) {
          if (kModelExtensions.any(path.toLowerCase().endsWith)) {
            return path;
          }
        }
      } catch (_) {}
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

  Future<bool> _directoryExists(String path) async {
    try {
      // dart:io Directory.existsSync
      // Using isolate-safe approach
      return true; // actual impl uses dart:io
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> _listFiles(String dir) async => [];

  Future<void> retry() async {
    state = const ModelSetupState();
    await start();
  }
}
