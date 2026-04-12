import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading.freezed.dart';
part 'reading.g.dart';

enum ReadingType { face, palm }

@freezed
class Reading with _$Reading {
  const factory Reading({
    required String id,
    String? userId,
    required ReadingType type,
    String? imagePath,
    required Map<String, dynamic> landmarks,
    Map<String, dynamic>? features,
    required String resultText,
    String? modelUsed,
    String? locale,
    required DateTime createdAt,
  }) = _Reading;

  factory Reading.fromJson(Map<String, dynamic> json) =>
      _$ReadingFromJson(json);
}
