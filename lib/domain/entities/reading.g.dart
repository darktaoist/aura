// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReadingImpl _$$ReadingImplFromJson(Map<String, dynamic> json) =>
    _$ReadingImpl(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      type: $enumDecode(_$ReadingTypeEnumMap, json['type']),
      imagePath: json['imagePath'] as String?,
      landmarks: json['landmarks'] as Map<String, dynamic>,
      features: json['features'] as Map<String, dynamic>?,
      resultText: json['resultText'] as String,
      modelUsed: json['modelUsed'] as String?,
      locale: json['locale'] as String?,
      subjectName: json['subjectName'] as String? ?? '나',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ReadingImplToJson(_$ReadingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$ReadingTypeEnumMap[instance.type]!,
      'imagePath': instance.imagePath,
      'landmarks': instance.landmarks,
      'features': instance.features,
      'resultText': instance.resultText,
      'modelUsed': instance.modelUsed,
      'locale': instance.locale,
      'subjectName': instance.subjectName,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ReadingTypeEnumMap = {
  ReadingType.face: 'face',
  ReadingType.palm: 'palm',
};
