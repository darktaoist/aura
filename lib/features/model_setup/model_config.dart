import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/model_constants.dart';

class GemmaModelConfig {
  const GemmaModelConfig({
    required this.name,
    required this.modelType,
    required this.fileType,
    required this.downloadUrl,
    required this.fileName,
    required this.sizeGb,
    required this.expectedBytes,
  });

  final String name;
  final ModelType modelType;
  final ModelFileType fileType;
  final String downloadUrl;
  final String fileName;
  final double sizeGb;
  final int expectedBytes;

  String get sha256Url => '$downloadUrl.sha256';
}

/// 모델 URL/파일이 바뀔 때마다 이 값을 올린다.
/// 이전 버전과 다르면 기기의 모든 모델 파일을 삭제하고 재다운로드한다.
const kModelUrlVersion = 6; // R2 전환

// ── 사용 가능한 모델 ────────────────────────────────────────────────────────
const kGemmaE4B = GemmaModelConfig(
  name: 'Gemma4 E4B',
  modelType: ModelType.gemmaIt,
  fileType: ModelFileType.litertlm,
  downloadUrl: kE4bDownloadUrl,
  fileName: kE4bFileName,
  sizeGb: 3.4,
  expectedBytes: kE4bExpectedBytes,
);

const kGemmaE2B = GemmaModelConfig(
  name: 'Gemma4 E2B',
  modelType: ModelType.gemmaIt,
  fileType: ModelFileType.litertlm,
  downloadUrl: kE2bDownloadUrl,
  fileName: kE2bFileName,
  sizeGb: 2.4,
  expectedBytes: kE2bExpectedBytes,
);

// 기본 모델
const kDefaultModel = kGemmaE2B;

// 파일 확장자로 설정 자동 판별 (로컬 파일 등록용)
GemmaModelConfig configForFile(String path) {
  final name = path.split('/').last;
  if (path.endsWith('.litertlm')) {
    return GemmaModelConfig(
      name: name,
      modelType: ModelType.gemmaIt,
      fileType: ModelFileType.litertlm,
      downloadUrl: '',
      fileName: name,
      sizeGb: 0,
      expectedBytes: 0,
    );
  } else if (path.endsWith('.task')) {
    return GemmaModelConfig(
      name: name,
      modelType: ModelType.gemmaIt,
      fileType: ModelFileType.task,
      downloadUrl: '',
      fileName: name,
      sizeGb: 0,
      expectedBytes: 0,
    );
  } else {
    return GemmaModelConfig(
      name: name,
      modelType: ModelType.gemmaIt,
      fileType: ModelFileType.binary,
      downloadUrl: '',
      fileName: name,
      sizeGb: 0,
      expectedBytes: 0,
    );
  }
}

// 로컬 스캔 경로 (정적 — 외부 스토리지)
const kStaticScanDirs = [
  '/sdcard/Download',
  '/storage/emulated/0/Download',
  '/sdcard',
  '/storage/emulated/0',
  '/data/local/tmp',
];

const kModelExtensions = ['.litertlm', '.task', '.bin'];

/// 모델 파일 크기가 예상 크기의 95% 이상인지 검증한다.
///
/// [expectedBytes]가 0이면 500 MB 최소 임계값만 확인한다.
Future<bool> isValidModelContent(File f, {int expectedBytes = 0}) async {
  try {
    final size = f.statSync().size;
    final minBytes = expectedBytes > 0
        ? (expectedBytes * 0.95).round()
        : 500 * 1024 * 1024;

    if (size < minBytes) {
      debugPrint(
        '[ModelConfig] 파일 크기 부족 (${(size / 1e9).toStringAsFixed(2)} GB'
        ' < ${(minBytes / 1e9).toStringAsFixed(2)} GB): ${f.path}',
      );
      return false;
    }
    debugPrint(
      '[ModelConfig] 파일 크기 검증 통과: ${(size / 1e9).toStringAsFixed(2)} GB',
    );
    return true;
  } catch (e) {
    debugPrint('[ModelConfig] isValidModelContent 오류: $e');
    return false;
  }
}

/// 기기에서 발견된 모든 모델 파일(앱 내부 + 외부 스토리지)을 삭제한다.
/// URL 버전이 바뀌었을 때 오래된 파일을 정리하기 위해 사용한다.
Future<void> deleteAllModelFiles() async {
  final dirs = await buildScanDirs();
  int deleted = 0;
  for (final dir in dirs) {
    try {
      final d = Directory(dir);
      if (!d.existsSync()) continue;
      for (final e in d.listSync(followLinks: false)) {
        if (e is! File) continue;
        final lower = e.path.toLowerCase();
        final isModel = kModelExtensions.any(lower.endsWith) ||
            lower.endsWith('/gemma_model.litertlm') ||
            lower.endsWith('/gemma_model.task');
        if (isModel) {
          try {
            await e.delete();
            deleted++;
            debugPrint('[ModelConfig] 삭제: ${e.path}');
          } catch (_) {}
        }
      }
    } catch (_) {}
  }
  debugPrint('[ModelConfig] 모델 파일 $deleted 개 삭제 완료');
}

/// flutter_gemma 가 모델을 내려받는 앱 내부 경로 포함 전체 스캔 목록을 반환한다.
Future<List<String>> buildScanDirs() async {
  final dirs = <String>[...kStaticScanDirs];
  try {
    final appDoc = await getApplicationDocumentsDirectory();
    final pkgDir  = appDoc.parent;
    final pkgName = pkgDir.path.split('/').last;

    dirs.addAll([
      appDoc.path,
      '${pkgDir.path}/app_flutter',
      '${pkgDir.path}/app_flutter/download',
      '/data/data/$pkgName/app_flutter',
      '/data/data/$pkgName/app_flutter/download',
      '/data/user/0/$pkgName/app_flutter',
      '/data/user/0/$pkgName/app_flutter/download',
    ]);
  } catch (e) {
    debugPrint('[ModelConfig] buildScanDirs 오류: $e');
  }
  return dirs;
}
