// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'consultation.freezed.dart';
part 'consultation.g.dart';

enum AnalysisType {
  @JsonValue('face')
  face,
  @JsonValue('palm')
  palm,
}

@freezed
class Consultation with _$Consultation {
  const factory Consultation({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'analysis_type') required AnalysisType analysisType,
    @JsonKey(name: 'analysis_id') required String analysisId,
    @JsonKey(name: 'context_summary') required String contextSummary,
    @JsonKey(name: 'context_features') required Map<String, dynamic> contextFeatures,
    String? title,
    required String locale,
    @JsonKey(name: 'model_used') required String modelUsed,
    @JsonKey(name: 'message_count') required int messageCount,
    @JsonKey(name: 'last_message_at') required DateTime lastMessageAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Consultation;

  factory Consultation.fromJson(Map<String, dynamic> json) =>
      _$ConsultationFromJson(json);
}
