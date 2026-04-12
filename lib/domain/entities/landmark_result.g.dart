// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'landmark_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LandmarkPointImpl _$$LandmarkPointImplFromJson(Map<String, dynamic> json) =>
    _$LandmarkPointImpl(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$LandmarkPointImplToJson(_$LandmarkPointImpl instance) =>
    <String, dynamic>{'x': instance.x, 'y': instance.y, 'z': instance.z};

_$FaceFeaturesImpl _$$FaceFeaturesImplFromJson(Map<String, dynamic> json) =>
    _$FaceFeaturesImpl(
      eyeSpan: (json['eyeSpan'] as num).toDouble(),
      faceHeight: (json['faceHeight'] as num).toDouble(),
      noseRatio: (json['noseRatio'] as num).toDouble(),
      mouthWidth: (json['mouthWidth'] as num).toDouble(),
      symmetry: (json['symmetry'] as num).toDouble(),
      foreheadHeight: (json['foreheadHeight'] as num).toDouble(),
      eyebrowDistance: (json['eyebrowDistance'] as num).toDouble(),
    );

Map<String, dynamic> _$$FaceFeaturesImplToJson(_$FaceFeaturesImpl instance) =>
    <String, dynamic>{
      'eyeSpan': instance.eyeSpan,
      'faceHeight': instance.faceHeight,
      'noseRatio': instance.noseRatio,
      'mouthWidth': instance.mouthWidth,
      'symmetry': instance.symmetry,
      'foreheadHeight': instance.foreheadHeight,
      'eyebrowDistance': instance.eyebrowDistance,
    };

_$FaceLandmarkResultImpl _$$FaceLandmarkResultImplFromJson(
  Map<String, dynamic> json,
) => _$FaceLandmarkResultImpl(
  landmarks: (json['landmarks'] as List<dynamic>)
      .map((e) => LandmarkPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  score: (json['score'] as num).toDouble(),
  features: FaceFeatures.fromJson(json['features'] as Map<String, dynamic>),
  frameWidth: (json['frameWidth'] as num).toInt(),
  frameHeight: (json['frameHeight'] as num).toInt(),
);

Map<String, dynamic> _$$FaceLandmarkResultImplToJson(
  _$FaceLandmarkResultImpl instance,
) => <String, dynamic>{
  'landmarks': instance.landmarks,
  'score': instance.score,
  'features': instance.features,
  'frameWidth': instance.frameWidth,
  'frameHeight': instance.frameHeight,
};
