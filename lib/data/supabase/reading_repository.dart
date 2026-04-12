import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/landmark_result.dart';
import '../../domain/entities/reading.dart';
import 'supabase_client.dart';

part 'reading_repository.g.dart';

@riverpod
ReadingRepository readingRepository(Ref ref) =>
    ReadingRepository(ref.watch(supabaseClientProvider));

class ReadingRepository {
  ReadingRepository(this._client);

  final SupabaseClient _client;
  final _uuid = const Uuid();

  /// 이미지 Storage 업로드 (저장 액션 시에만 호출)
  Future<String> uploadImage({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    // JPEG 매직 바이트 검증 (FF D8 FF)
    if (imageBytes.length < 3 ||
        imageBytes[0] != 0xFF ||
        imageBytes[1] != 0xD8 ||
        imageBytes[2] != 0xFF) {
      throw ArgumentError('imageBytes는 유효한 JPEG 데이터여야 합니다');
    }

    final fileName = '${_uuid.v4()}.jpg';
    final path = '$userId/$fileName';

    await _client.storage
        .from('readings')
        .uploadBinary(
          path,
          imageBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    return path;
  }

  /// readings INSERT
  Future<Reading> saveReading({
    required String userId,
    required ReadingType type,
    String? imagePath,
    required FaceLandmarkResult landmarkResult,
    required String resultText,
    required String modelUsed,
    required String locale,
  }) async {
    final id = _uuid.v4();

    final landmarksJson = {
      'landmarks': landmarkResult.landmarks
          .map((l) => {'x': l.x, 'y': l.y, 'z': l.z})
          .toList(),
      'score': landmarkResult.score,
      'frame_width': landmarkResult.frameWidth,
      'frame_height': landmarkResult.frameHeight,
    };

    final featuresJson = {
      'eye_span': landmarkResult.features.eyeSpan,
      'face_height': landmarkResult.features.faceHeight,
      'nose_ratio': landmarkResult.features.noseRatio,
      'mouth_width': landmarkResult.features.mouthWidth,
      'symmetry': landmarkResult.features.symmetry,
      'forehead_height': landmarkResult.features.foreheadHeight,
      'eyebrow_distance': landmarkResult.features.eyebrowDistance,
    };

    final row = {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'image_path': imagePath,
      'landmarks': landmarksJson,
      'features': featuresJson,
      'result_text': resultText,
      'model_used': modelUsed,
      'locale': locale,
    };

    final response = await _client
        .from('readings')
        .insert(row)
        .select()
        .single();

    return _fromRow(response);
  }

  /// readings SELECT (RLS: user_id = auth.uid())
  Future<List<Reading>> getHistory(String userId) async {
    final rows = await _client
        .from('readings')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (rows as List).map((r) => _fromRow(r as Map<String, dynamic>)).toList();
  }

  /// readings DELETE
  Future<void> deleteReading(String readingId) async {
    await _client.from('readings').delete().eq('id', readingId);
  }

  /// RAG 검색: Edge Function rag-search 호출
  Future<List<String>> ragSearch({
    required String type,  // 'face' | 'palm'
    required List<double> queryEmbedding,
    int topK = 5,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'rag-search',
        body: {
          'type': type,
          'query_embedding': queryEmbedding,
          'top_k': topK,
        },
      );

      if (response.status != 200) return [];

      final data = response.data as Map<String, dynamic>;
      final chunks = data['chunks'] as List? ?? [];
      return chunks
          .map((c) => (c as Map<String, dynamic>)['content'] as String)
          .toList();
    } catch (e) {
      debugPrint('[ReadingRepository] ragSearch error: $e');
      return [];
    }
  }

  Reading _fromRow(Map<String, dynamic> row) {
    return Reading(
      id: row['id'] as String,
      userId: row['user_id'] as String?,
      type: row['type'] == 'face' ? ReadingType.face : ReadingType.palm,
      imagePath: row['image_path'] as String?,
      landmarks: row['landmarks'] as Map<String, dynamic>,
      features: row['features'] as Map<String, dynamic>?,
      resultText: row['result_text'] as String,
      modelUsed: row['model_used'] as String?,
      locale: row['locale'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
