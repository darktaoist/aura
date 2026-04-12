import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaModelConfig {
  const GemmaModelConfig({
    required this.name,
    required this.modelType,
    required this.fileType,
    required this.downloadUrl,
    required this.fileName,
    required this.sizeGb,
  });

  final String name;
  final ModelType modelType;
  final ModelFileType fileType;
  final String downloadUrl;
  final String fileName;
  final double sizeGb;
}

String _driveUrl(String fileId) =>
    'https://drive.usercontent.google.com/download?id=$fileId&export=download&confirm=t';

// ── 사용 가능한 모델 ────────────────────────────────────────────────────────
final kGemmaE4B = GemmaModelConfig(
  name: 'Gemma4 E4B',
  modelType: ModelType.gemmaIt,
  fileType: ModelFileType.litertlm,
  downloadUrl: _driveUrl('1aXnYvUAGvoDfojp6AeRx7N6GcIFUmfsy'),
  fileName: 'gemma-4-E4B-it.litertlm',
  sizeGb: 5.0,
);

final kGemmaE2B = GemmaModelConfig(
  name: 'Gemma4 E2B',
  modelType: ModelType.gemmaIt,
  fileType: ModelFileType.litertlm,
  downloadUrl: _driveUrl('1bsRm7Ri0rm13fkcfAvkABZeJa4RnNflE'),
  fileName: 'gemma-4-E2B-it.litertlm',
  sizeGb: 2.5,
);

// 기본 모델 (E4B 우선, 용량 부족 시 E2B 폴백)
final kDefaultModel = kGemmaE4B;

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
    );
  } else if (path.endsWith('.task')) {
    return GemmaModelConfig(
      name: name,
      modelType: ModelType.gemmaIt,
      fileType: ModelFileType.task,
      downloadUrl: '',
      fileName: name,
      sizeGb: 0,
    );
  } else {
    return GemmaModelConfig(
      name: name,
      modelType: ModelType.gemmaIt,
      fileType: ModelFileType.binary,
      downloadUrl: '',
      fileName: name,
      sizeGb: 0,
    );
  }
}

// 로컬 스캔 경로
const kScanDirs = [
  '/sdcard/Download',
  '/storage/emulated/0/Download',
  '/sdcard',
  '/storage/emulated/0',
  '/data/local/tmp',
];

const kModelExtensions = ['.litertlm', '.task', '.bin'];
