import 'package:freezed_annotation/freezed_annotation.dart';

part 'landmark_result.freezed.dart';
part 'landmark_result.g.dart';

@freezed
class LandmarkPoint with _$LandmarkPoint {
  const factory LandmarkPoint({
    required double x,
    required double y,
    @Default(0.0) double z,
  }) = _LandmarkPoint;

  factory LandmarkPoint.fromJson(Map<String, dynamic> json) =>
      _$LandmarkPointFromJson(json);
}

/// 관상 파생 지표
@freezed
class FaceFeatures with _$FaceFeatures {
  const factory FaceFeatures({
    required double eyeSpan,
    required double faceHeight,
    required double noseRatio,
    required double mouthWidth,
    required double symmetry,
    required double foreheadHeight,
    required double eyebrowDistance,
  }) = _FaceFeatures;

  factory FaceFeatures.fromJson(Map<String, dynamic> json) =>
      _$FaceFeaturesFromJson(json);
}

/// 얼굴 분석 결과 (카메라 → 결과 화면 전달 객체)
@freezed
class FaceLandmarkResult with _$FaceLandmarkResult {
  const factory FaceLandmarkResult({
    required List<LandmarkPoint> landmarks,
    required double score,
    required FaceFeatures features,
    required int frameWidth,
    required int frameHeight,
  }) = _FaceLandmarkResult;

  factory FaceLandmarkResult.fromJson(Map<String, dynamic> json) =>
      _$FaceLandmarkResultFromJson(json);
}
