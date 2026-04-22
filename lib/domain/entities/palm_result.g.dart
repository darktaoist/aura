// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'palm_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PalmFeaturesImpl _$$PalmFeaturesImplFromJson(Map<String, dynamic> json) =>
    _$PalmFeaturesImpl(
      palmWidth: (json['palmWidth'] as num).toDouble(),
      indexLength: (json['indexLength'] as num).toDouble(),
      middleLength: (json['middleLength'] as num).toDouble(),
      ringLength: (json['ringLength'] as num).toDouble(),
      pinkyLength: (json['pinkyLength'] as num).toDouble(),
      thumbLength: (json['thumbLength'] as num).toDouble(),
      fingerSpread: (json['fingerSpread'] as num).toDouble(),
    );

Map<String, dynamic> _$$PalmFeaturesImplToJson(_$PalmFeaturesImpl instance) =>
    <String, dynamic>{
      'palmWidth': instance.palmWidth,
      'indexLength': instance.indexLength,
      'middleLength': instance.middleLength,
      'ringLength': instance.ringLength,
      'pinkyLength': instance.pinkyLength,
      'thumbLength': instance.thumbLength,
      'fingerSpread': instance.fingerSpread,
    };

_$PalmLandmarkResultImpl _$$PalmLandmarkResultImplFromJson(
  Map<String, dynamic> json,
) => _$PalmLandmarkResultImpl(
  landmarks: (json['landmarks'] as List<dynamic>)
      .map((e) => LandmarkPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  score: (json['score'] as num).toDouble(),
  features: PalmFeatures.fromJson(json['features'] as Map<String, dynamic>),
  frameWidth: (json['frameWidth'] as num).toInt(),
  frameHeight: (json['frameHeight'] as num).toInt(),
  isLeftHand: json['isLeftHand'] as bool,
);

Map<String, dynamic> _$$PalmLandmarkResultImplToJson(
  _$PalmLandmarkResultImpl instance,
) => <String, dynamic>{
  'landmarks': instance.landmarks,
  'score': instance.score,
  'features': instance.features,
  'frameWidth': instance.frameWidth,
  'frameHeight': instance.frameHeight,
  'isLeftHand': instance.isLeftHand,
};
