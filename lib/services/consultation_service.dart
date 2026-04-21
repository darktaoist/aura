import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/supabase/supabase_client.dart';
import '../models/consultation.dart';
import '../models/consultation_message.dart';

part 'consultation_service.g.dart';

@riverpod
ConsultationService consultationService(Ref ref) =>
    ConsultationService(ref.watch(supabaseClientProvider));

class ConsultationService {
  ConsultationService(this._client);

  final SupabaseClient _client;

  // ─────────────────────────── Consultation CRUD ──────────────────────────

  /// 새 상담 세션 생성 (readings 레코드와 연결)
  Future<Consultation> createConsultation({
    required String userId,
    required AnalysisType analysisType,
    required String analysisId,
    required String contextSummary,
    required Map<String, dynamic> contextFeatures,
    required String locale,
    required String modelUsed,
    String? title,
  }) async {
    final now = DateTime.now();
    final autoTitle =
        title ?? '${analysisType == AnalysisType.face ? '관상' : '손금'} 상담 ${now.month}.${now.day}';

    final row = {
      'user_id': userId,
      'analysis_type': analysisType == AnalysisType.face ? 'face' : 'palm',
      'analysis_id': analysisId,
      'context_summary': contextSummary,
      'context_features': contextFeatures,
      'title': autoTitle,
      'locale': locale,
      'model_used': modelUsed,
      'message_count': 0,
      'last_message_at': now.toIso8601String(),
    };

    final response = await _client
        .from('consultations')
        .insert(row)
        .select()
        .single();

    return Consultation.fromJson(response);
  }

  /// 사용자의 상담 목록 조회 (최신순)
  Future<List<Consultation>> getConsultations(String userId) async {
    final rows = await _client
        .from('consultations')
        .select()
        .eq('user_id', userId)
        .order('last_message_at', ascending: false);

    return (rows as List)
        .map((r) => Consultation.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// 단일 상담 조회
  Future<Consultation> getConsultation(String consultationId) async {
    final row = await _client
        .from('consultations')
        .select()
        .eq('id', consultationId)
        .single();

    return Consultation.fromJson(row);
  }

  /// 상담 제목 업데이트
  Future<void> updateTitle({
    required String consultationId,
    required String title,
  }) async {
    await _client
        .from('consultations')
        .update({'title': title})
        .eq('id', consultationId);
  }

  /// 상담 삭제
  Future<void> deleteConsultation(String consultationId) async {
    await _client
        .from('consultations')
        .delete()
        .eq('id', consultationId);
  }

  // ─────────────────────────── Message CRUD ────────────────────────────────

  /// 메시지 목록 조회 (오래된 것부터)
  Future<List<ConsultationMessage>> getMessages(String consultationId) async {
    final rows = await _client
        .from('consultation_messages')
        .select()
        .eq('consultation_id', consultationId)
        .order('created_at', ascending: true);

    return (rows as List)
        .map((r) =>
            ConsultationMessage.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// 메시지 추가 + consultations.message_count / last_message_at 갱신
  Future<ConsultationMessage> addMessage({
    required String consultationId,
    required MessageRole role,
    required String content,
    int? tokenCount,
  }) async {
    final now = DateTime.now();

    final row = {
      'consultation_id': consultationId,
      'role': role == MessageRole.user ? 'user' : 'assistant',
      'content': content,
      if (tokenCount != null) 'token_count': tokenCount,
      'created_at': now.toIso8601String(),
    };

    final response = await _client
        .from('consultation_messages')
        .insert(row)
        .select()
        .single();

    // message_count, last_message_at 갱신 (RPC 없이 클라이언트 update)
    await _client.from('consultations').update({
      'last_message_at': now.toIso8601String(),
    }).eq('id', consultationId);

    // message_count는 DB 트리거 또는 별도 RPC로 관리 권장
    // 클라이언트에서 increment가 불안전하므로 현재는 생략

    return ConsultationMessage.fromJson(response);
  }

  /// 상담의 메시지 수 갱신 (UI 호출용)
  Future<void> refreshMessageCount(String consultationId) async {
    final rows = await _client
        .from('consultation_messages')
        .select('id')
        .eq('consultation_id', consultationId);

    final count = (rows as List).length;
    await _client
        .from('consultations')
        .update({'message_count': count})
        .eq('id', consultationId);
  }
}
