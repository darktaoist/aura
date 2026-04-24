import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
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

class _ConsultationChatScreenState extends ConsumerState<ConsultationChatScreen> {
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
    final l10n = AppLocalizations.of(context)!;
    final chatState = ref.watch(consultationChatProvider(widget.consultationId));

    ref.listen(consultationChatProvider(widget.consultationId), (prev, next) {
      if (prev?.messages.length != next.messages.length ||
          prev?.streamingText != next.streamingText) {
        _scrollToBottom();
      }
    });

    if (chatState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.consultationTitle)),
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
              Text(l10n.consultationNotFound),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => context.go('/consultation'),
                child: Text(l10n.backToList),
              ),
            ],
          ),
        ),
      );
    }

    final consultation = chatState.consultation!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context, ref, consultation, l10n),
      body: Column(
        children: [
          Expanded(
            child: _MessageList(
              scrollCtrl: _scrollCtrl,
              messages: chatState.messages,
              streamingText: chatState.streamingText,
              isStreaming: chatState.isStreaming,
              l10n: l10n,
            ),
          ),
          ChatInputBar(
            isDisabled: chatState.isStreaming || chatState.isLoading,
            hintText: l10n.chatInputHint,
            generatingText: l10n.chatGenerating,
            onSend: (text) {
              ref.read(consultationChatProvider(widget.consultationId).notifier)
                  .sendMessage(text);
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context, WidgetRef ref,
    Consultation consultation, AppLocalizations l10n,
  ) {
    return AppBar(
      title: GestureDetector(
        onTap: () => _editTitle(context, ref, consultation, l10n),
        child: Text(
          consultation.title ?? l10n.consultationTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (val) async {
            if (val == 'delete') {
              final ok = await _confirmDelete(context, l10n);
              if (ok && context.mounted) {
                await ref.read(consultationChatProvider(widget.consultationId).notifier)
                    .deleteConsultation();
                if (context.mounted) context.go('/consultation');
              }
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'delete', child: Text(l10n.chatDeleteConsultation)),
          ],
        ),
      ],
    );
  }

  Future<void> _editTitle(
    BuildContext context, WidgetRef ref,
    Consultation consultation, AppLocalizations l10n,
  ) async {
    final ctrl = TextEditingController(text: consultation.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chatTitleEdit),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.consultationTitleHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result != null && result.isNotEmpty && context.mounted) {
      // TODO: ConsultationService.updateTitle 호출 후 provider 갱신
    }
  }

  Future<bool> _confirmDelete(BuildContext context, AppLocalizations l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chatDeleteConsultation),
        content: Text(l10n.consultationDeleteContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
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
    required this.l10n,
  });

  final ScrollController scrollCtrl;
  final List<ConsultationMessage> messages;
  final String streamingText;
  final bool isStreaming;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final showStreamingBubble = isStreaming && streamingText.isNotEmpty;

    if (messages.isEmpty && !showStreamingBubble) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (b) => AppColors.brandGradient.createShader(b),
                child: const Icon(Icons.chat_bubble_outline, size: 48, color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.consultationEmptyHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
        if (i < messages.length) return MessageBubble(message: messages[i]);
        return StreamingBubble(text: streamingText);
      },
    );
  }
}
