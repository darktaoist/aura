import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/consultation.dart';
import '../../models/consultation_message.dart';
import 'providers/consultation_chat_provider.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';

class ConsultationChatScreen extends ConsumerStatefulWidget {
  const ConsultationChatScreen({super.key, required this.consultationId});

  final String consultationId;

  @override
  ConsumerState<ConsultationChatScreen> createState() =>
      _ConsultationChatScreenState();
}

class _ConsultationChatScreenState
    extends ConsumerState<ConsultationChatScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState =
        ref.watch(consultationChatProvider(widget.consultationId));

    // 새 메시지 / 스트리밍 변화 시 자동 스크롤
    ref.listen(consultationChatProvider(widget.consultationId), (prev, next) {
      if (prev?.messages.length != next.messages.length ||
          prev?.streamingText != next.streamingText) {
        _scrollToBottom();
      }
    });

    if (chatState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('상담')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (chatState.error != null && chatState.consultation == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: AppSpacing.md),
              const Text('상담을 찾을 수 없습니다'),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => context.go('/consultation'),
                child: const Text('목록으로'),
              ),
            ],
          ),
        ),
      );
    }

    final consultation = chatState.consultation!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context, ref, consultation),
      body: Column(
        children: [
          Expanded(
            child: _MessageList(
              scrollCtrl: _scrollCtrl,
              messages: chatState.messages,
              streamingText: chatState.streamingText,
              isStreaming: chatState.isStreaming,
            ),
          ),
          ChatInputBar(
            isDisabled: chatState.isStreaming || chatState.isLoading,
            onSend: (text) {
              ref
                  .read(consultationChatProvider(widget.consultationId).notifier)
                  .sendMessage(text);
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    Consultation consultation,
  ) {
    return AppBar(
      title: GestureDetector(
        onTap: () => _editTitle(context, ref, consultation),
        child: Text(
          consultation.title ?? '상담',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (val) async {
            if (val == 'delete') {
              final ok = await _confirmDelete(context);
              if (ok && context.mounted) {
                await ref
                    .read(consultationChatProvider(widget.consultationId).notifier)
                    .deleteConsultation();
                if (context.mounted) context.go('/consultation');
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'delete', child: Text('상담 삭제')),
          ],
        ),
      ],
    );
  }

  Future<void> _editTitle(
    BuildContext context,
    WidgetRef ref,
    Consultation consultation,
  ) async {
    final ctrl = TextEditingController(text: consultation.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('제목 편집'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '상담 제목'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result != null && result.isNotEmpty && context.mounted) {
      // TODO: ConsultationService.updateTitle 호출 후 provider 갱신
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('상담 삭제'),
        content: const Text('이 상담을 삭제할까요?\n대화 내용이 모두 사라집니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.scrollCtrl,
    required this.messages,
    required this.streamingText,
    required this.isStreaming,
  });

  final ScrollController scrollCtrl;
  final List<ConsultationMessage> messages;
  final String streamingText;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final showStreamingBubble = isStreaming && streamingText.isNotEmpty;

    // 전체 아이템 수: 메시지 + 스트리밍 버블(있으면) + 빈 항목(없으면)
    if (messages.isEmpty && !showStreamingBubble) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (b) => AppColors.brandGradient.createShader(b),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '분석 결과에 대해 궁금한 점을 물어보세요',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final itemCount = messages.length + (showStreamingBubble ? 1 : 0);

    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: itemCount,
      itemBuilder: (_, i) {
        if (i < messages.length) {
          return MessageBubble(message: messages[i]);
        }
        // 스트리밍 버블
        return StreamingBubble(text: streamingText);
      },
    );
  }
}
