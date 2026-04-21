// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConsultationMessageImpl _$$ConsultationMessageImplFromJson(
  Map<String, dynamic> json,
) => _$ConsultationMessageImpl(
  id: json['id'] as String,
  consultationId: json['consultation_id'] as String,
  role: $enumDecode(_$MessageRoleEnumMap, json['role']),
  content: json['content'] as String,
  tokenCount: (json['token_count'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$ConsultationMessageImplToJson(
  _$ConsultationMessageImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'consultation_id': instance.consultationId,
  'role': _$MessageRoleEnumMap[instance.role]!,
  'content': instance.content,
  'token_count': instance.tokenCount,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
};
