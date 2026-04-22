import 'package:freezed_annotation/freezed_annotation.dart';

import 'landmark_result.dart';

part 'palm_result.freezed.dart';
part 'palm_result.g.dart';

/// 손금 파생 지표 (21 hand landmarks 기반)
@freezed
class PalmFeatures with _$PalmFeatures {
  const factory PalmFeatures({
    required double palmWidth,
    required double indexLength,
    required double middleLength,
    required double ringLength,
    required double pinkyLength,
    required double thumbLength,
    required double fingerSpread,
  }) = _PalmFeatures;

  factory PalmFeatures.fromJson(Map<String, dynamic> json) =>
      _$PalmFeaturesFromJson(json);
}

/// 손금 분석 결과 (카메라 → 결과 화면 전달 객체)
@freezed
class PalmLandmarkResult with _$PalmLandmarkResult {
  const factory PalmLandmarkResult({
    required List<LandmarkPoint> landmarks, // 21 MediaPipe hand landmarks
    required double score,
    required PalmFeatures features,
    required int frameWidth,
    required int frameHeight,
    required bool isLeftHand,
  }) = _PalmLandmarkResult;

  factory PalmLandmarkResult.fromJson(Map<String, dynamic> json) =>
      _$PalmLandmarkResultFromJson(json);
}
