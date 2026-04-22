import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/consultation.dart';
import '../../../models/consultation_message.dart';
import '../../../services/consultation_service.dart';
import 'consultation_list_provider.dart';
import 'gemma_chat_session_provider.dart';

part 'consultation_chat_provider.g.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class ConsultationChatState {
  const ConsultationChatState({
    this.consultation,
    this.messages = const [],
    this.streamingText = '',
    this.isStreaming = false,
    this.isLoading = true,
    this.error,
  });

  final Consultation? consultation;
  final List<ConsultationMessage> messages;
  final String streamingText;
  final bool isStreaming;
  final bool isLoading;
  final String? error;

  ConsultationChatState copyWith({
    Consultation? consultation,
    List<ConsultationMessage>? messages,
    String? streamingText,
    bool? isStreaming,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ConsultationChatState(
      consultation: consultation ?? this.consultation,
      messages: messages ?? this.messages,
      streamingText: streamingText ?? this.streamingText,
      isStreaming: isStreaming ?? this.isStreaming,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

@riverpod
class ConsultationChat extends _$ConsultationChat {
  // 세션 인스턴스를 필드로 보관 — autoDispose 교체 방지
  GemmaChatSessionNotifier? _gemmaSession;

  @override
  ConsultationChatState build(String consultationId) {
    _init(consultationId);
    return const ConsultationChatState();
  }

  Future<void> _init(String id) async {
    try {
      final svc = ref.read(consultationServiceProvider);
      final consultation = await svc.getConsultation(id);
      final messages = await svc.getMessages(id);

      // 동일 인스턴스를 필드에 보관한 뒤 세션 열기
      _gemmaSession = ref.read(gemmaChatSessionProvider);
      await _gemmaSession!.openSession(consultation);

      state = state.copyWith(
        consultation: consultation,
        messages: messages,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(String text) async {
    final consultation = state.consultation;
    if (consultation == null || state.isStreaming) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final svc = ref.read(consultationServiceProvider);
    final GemmaChatSessionNotifier gemmaSession =
        _gemmaSession ?? ref.read(gemmaChatSessionProvider);

    // 1. 사용자 메시지를 즉시 UI에 반영
    final tempUserMsg = ConsultationMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      consultationId: consultation.id,
      role: MessageRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, tempUserMsg],
      isStreaming: true,
      streamingText: '',
      clearError: true,
    );

    // 2. DB에 사용자 메시지 저장
    ConsultationMessage? savedUserMsg;
    try {
      savedUserMsg = await svc.addMessage(
        consultationId: consultation.id,
        role: MessageRole.user,
        content: trimmed,
      );
      // temp 메시지를 저장된 메시지로 교체
      final updatedMessages = state.messages
          .map((m) => m.id == tempUserMsg.id ? savedUserMsg! : m)
          .toList();
      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      // DB 저장 실패해도 스트리밍은 계속 시도
    }

    // 3. Gemma 스트리밍
    final buffer = StringBuffer();
    try {
      await for (final token in gemmaSession.sendMessage(trimmed)) {
        buffer.write(token);
        state = state.copyWith(streamingText: buffer.toString());
      }
    } catch (e) {
      buffer.write('응답 생성에 실패했습니다. 다시 시도해주세요.');
      state = state.copyWith(streamingText: buffer.toString());
    }

    // 4. 스트리밍 완료 — DB에 assistant 메시지 저장
    final assistantContent = buffer.toString();
    ConsultationMessage assistantMsg;
    try {
      assistantMsg = await svc.addMessage(
        consultationId: consultation.id,
        role: MessageRole.assistant,
        content: assistantContent,
      );
    } catch (e) {
      assistantMsg = ConsultationMessage(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        consultationId: consultation.id,
        role: MessageRole.assistant,
        content: assistantContent,
        createdAt: DateTime.now(),
      );
    }

    state = state.copyWith(
      messages: [...state.messages, assistantMsg],
      isStreaming: false,
      streamingText: '',
    );
  }

  Future<void> deleteConsultation() async {
    final consultation = state.consultation;
    if (consultation == null) return;
    await ref.read(consultationServiceProvider).deleteConsultation(consultation.id);
    ref.invalidate(consultationListProvider);
  }
}
