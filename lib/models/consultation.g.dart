// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConsultationImpl _$$ConsultationImplFromJson(Map<String, dynamic> json) =>
    _$ConsultationImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      analysisType: $enumDecode(_$AnalysisTypeEnumMap, json['analysis_type']),
      analysisId: json['analysis_id'] as String,
      contextSummary: json['context_summary'] as String,
      contextFeatures: json['context_features'] as Map<String, dynamic>,
      title: json['title'] as String?,
      locale: json['locale'] as String,
      modelUsed: json['model_used'] as String,
      messageCount: (json['message_count'] as num).toInt(),
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ConsultationImplToJson(_$ConsultationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'analysis_type': _$AnalysisTypeEnumMap[instance.analysisType]!,
      'analysis_id': instance.analysisId,
      'context_summary': instance.contextSummary,
      'context_features': instance.contextFeatures,
      'title': instance.title,
      'locale': instance.locale,
      'model_used': instance.modelUsed,
      'message_count': instance.messageCount,
      'last_message_at': instance.lastMessageAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$AnalysisTypeEnumMap = {
  AnalysisType.face: 'face',
  AnalysisType.palm: 'palm',
};
