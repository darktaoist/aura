import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model_config.dart';
import 'model_selector.dart';

part 'model_setup_notifier.g.dart';

enum ModelSetupPhase { idle, scanning, registering, downloading, done, error }

class ModelSetupState {
  const ModelSetupState({
    this.phase = ModelSetupPhase.idle,
    this.progress = 0,
    this.errorMessage,
    this.foundLocalPath,
    this.selectedModel,
  });

  final ModelSetupPhase phase;
  final int progress;
  final String? errorMessage;
  final String? foundLocalPath;
  /// 다운로드 대상으로 선택된 모델 (null = 아직 선택 전)
  final GemmaModelConfig? selectedModel;

  bool get isDone => phase == ModelSetupPhase.done;
  bool get isError => phase == ModelSetupPhase.error;
  bool get isDownloading => phase == ModelSetupPhase.downloading;

  ModelSetupState copyWith({
    ModelSetupPhase? phase,
    int? progress,
    String? errorMessage,
    String? foundLocalPath,
    GemmaModelConfig? selectedModel,
  }) =>
      ModelSetupState(
        phase: phase ?? this.phase,
        progress: progress ?? this.progress,
        errorMessage: errorMessage ?? this.errorMessage,
        foundLocalPath: foundLocalPath ?? this.foundLocalPath,
        selectedModel: selectedModel ?? this.selectedModel,
      );
}

@riverpod
class ModelSetupNotifier extends _$ModelSetupNotifier {
  @override
  ModelSetupState build() => const ModelSetupState();

  Future<void> start() async {
    state = state.copyWith(phase: ModelSetupPhase.scanning);

    final results = await Future.wait([scanLocal(), selectModel()]);
    final localPath = results[0] as String?;
    final model = results[1] as GemmaModelConfig;
    debugPrint('[ModelSetupNotifier] 선택된 모델: ${model.name}');

    state = state.copyWith(selectedModel: model);

    if (localPath != null) {
      state = state.copyWith(
        phase: ModelSetupPhase.registering,
        foundLocalPath: localPath,
      );
      await _registerFile(localPath);
    } else {
      state = state.copyWith(phase: ModelSetupPhase.downloading);
      await _download(model);
    }
  }

  Future<String?> scanLocal() async {
    if (!Platform.isAndroid) return null;

    final dirs = await buildScanDirs();
    for (final dir in dirs) {
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
      final model = state.selectedModel ?? kDefaultModel;
      state = state.copyWith(phase: ModelSetupPhase.downloading);
      await _download(model);
    }
  }

  /// Range 요청 기반 재개 다운로드 + SHA-256 검증.
  Future<void> _download(GemmaModelConfig model, {int attempt = 0}) async {
    String? savePath;
    try {
      final appDoc = await getApplicationDocumentsDirectory();
      savePath = '${appDoc.path}/${model.fileName}';

      final file = File(savePath);
      final existingSize = file.existsSync() ? file.lengthSync() : 0;

      final dio = Dio();
      final headers = <String, dynamic>{
        'User-Agent': 'Mozilla/5.0 (Android)',
        if (existingSize > 0) 'Range': 'bytes=$existingSize-',
      };

      final resp = await dio.get<ResponseBody>(
        model.downloadUrl,
        options: Options(
          responseType: ResponseType.stream,
          headers: headers,
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (s) => s != null && s < 400,
        ),
      );

      final isPartial = resp.statusCode == 206;
      final contentLength = int.tryParse(
        resp.headers.value(Headers.contentLengthHeader) ?? '',
      ) ?? 0;

      final startFrom = isPartial ? existingSize : 0;
      final total = contentLength > 0
          ? startFrom + contentLength
          : model.expectedBytes;
      int received = startFrom;

      final raf = await file.open(
        mode: isPartial ? FileMode.append : FileMode.write,
      );

      try {
        await for (final chunk in resp.data!.stream) {
          await raf.writeFrom(chunk);
          received += chunk.length;
          if (total > 0) {
            state = state.copyWith(
              progress: (received / total * 100).clamp(0, 100).round(),
            );
          }
        }
      } finally {
        await raf.close();
      }

      if (!await isValidModelContent(file, expectedBytes: model.expectedBytes)) {
        await file.delete();
        throw Exception('다운로드된 파일이 유효하지 않습니다 (크기 부족).');
      }

      final hashOk = await _verifySha256(file, model);
      if (!hashOk) {
        await file.delete();
        if (attempt == 0) {
          debugPrint('[ModelSetupNotifier] 해시 불일치 → 재시도');
          state = state.copyWith(progress: 0);
          await _download(model, attempt: 1);
          return;
        }
        throw Exception('파일 무결성 검증 실패 (SHA-256 불일치).');
      }

      await FlutterGemma.installModel(
        modelType: model.modelType,
        fileType: model.fileType,
      ).fromFile(savePath).install();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('model_url_version', kModelUrlVersion);

      state = state.copyWith(phase: ModelSetupPhase.done);
    } catch (e) {
      if (savePath != null) {
        try { await File(savePath).delete(); } catch (_) {}
      }
      state = state.copyWith(
        phase: ModelSetupPhase.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> _verifySha256(File file, GemmaModelConfig model) async {
    try {
      final dio = Dio();
      final resp = await dio.get<String>(
        model.sha256Url,
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (s) => s != null && s < 400,
        ),
      );
      final expectedHash = (resp.data ?? '')
          .trim()
          .split(RegExp(r'\s+'))
          .first
          .toLowerCase();

      if (expectedHash.isEmpty || expectedHash.length != 64) {
        debugPrint('[ModelSetupNotifier] .sha256 파일 형식 불명 → 검증 스킵');
        return true;
      }

      Digest? digest;
      final input = sha256.startChunkedConversion(
        ChunkedConversionSink.withCallback((chunks) => digest = chunks.single),
      );
      final raf = await file.open();
      try {
        const chunkSize = 64 * 1024 * 1024;
        while (true) {
          final chunk = await raf.read(chunkSize);
          if (chunk.isEmpty) break;
          input.add(chunk);
        }
      } finally {
        await raf.close();
      }
      input.close();
      final actualHash = digest!.toString();

      if (expectedHash != actualHash) {
        debugPrint('[ModelSetupNotifier] SHA-256 불일치');
        return false;
      }
      debugPrint('[ModelSetupNotifier] SHA-256 검증 완료');
      return true;
    } catch (e) {
      debugPrint('[ModelSetupNotifier] SHA-256 검증 오류 (스킵): $e');
      return true;
    }
  }

  Future<void> retry() async {
    state = const ModelSetupState();
    await start();
  }
}
