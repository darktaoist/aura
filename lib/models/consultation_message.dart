// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'consultation_message.freezed.dart';
part 'consultation_message.g.dart';

enum MessageRole {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
}

@freezed
class ConsultationMessage with _$ConsultationMessage {
  const factory ConsultationMessage({
    required String id,
    @JsonKey(name: 'consultation_id') required String consultationId,
    required MessageRole role,
    required String content,
    @JsonKey(name: 'token_count') int? tokenCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ConsultationMessage;

  factory ConsultationMessage.fromJson(Map<String, dynamic> json) =>
      _$ConsultationMessageFromJson(json);
}
