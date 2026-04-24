import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/consultation.dart';
import '../../models/consultation_message.dart';
import 'providers/consultation_chat_provider.dart';
import 'widgets/aura_avatar.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/context_summary_chips.dart';
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
  bool _contextExpanded = false;

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
    final theme = Theme.of(context);
    final chatState =
        ref.watch(consultationChatProvider(widget.consultationId));

    ref.listen(consultationChatProvider(widget.consultationId), (prev, next) {
      if (prev?.messages.length != next.messages.length ||
          prev?.streamingText != next.streamingText) {
        _scrollToBottom();
      }
    });

    if (chatState.isLoading) {
      return Scaffold(
        appBar: _buildAppBar(context, ref, null, l10n),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (chatState.error != null && chatState.consultation == null) {
      return Scaffold(
        appBar: _buildAppBar(context, ref, null, l10n),
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
    final showStreamingBubble =
        chatState.isStreaming && chatState.streamingText.isNotEmpty;

    return Scaffold(
      appBar: _buildAppBar(context, ref, consultation, l10n),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 배경 radial 워시
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.8),
                    radius: 1.2,
                    colors: [
                      theme.colorScheme.primary.withValues(
                        alpha: theme.brightness == Brightness.dark ? 0.07 : 0.03,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          Column(
            children: [
              // 컨텍스트 요약 (접기/펼치기)
              if (consultation.contextSummary.isNotEmpty)
                ContextSummaryChips(
                  summary: consultation.contextSummary,
                  expanded: _contextExpanded,
                  onToggle: () =>
                      setState(() => _contextExpanded = !_contextExpanded),
                ),

              // 메시지 리스트
              Expanded(
                child: _MessageList(
                  scrollCtrl: _scrollCtrl,
                  messages: chatState.messages,
                  streamingText: chatState.streamingText,
                  showStreamingBubble: showStreamingBubble,
                  isStreaming: chatState.isStreaming,
                  l10n: l10n,
                ),
              ),

              // 입력바
              ChatInputBar(
                isDisabled: chatState.isStreaming || chatState.isLoading,
                hintText: l10n.chatInputHint,
                generatingText: l10n.chatGenerating,
                onSend: (text) {
                  ref
                      .read(consultationChatProvider(widget.consultationId)
                          .notifier)
                      .sendMessage(text);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    Consultation? consultation,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final aura = context.auraColors;

    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          const AuraAvatar(size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: consultation == null
                      ? null
                      : () => _editTitle(context, ref, consultation, l10n),
                  child: Text(
                    consultation?.title ?? l10n.consultationAuraTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  l10n.consultationSubjectYou,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: aura.onSurfaceMuted,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (consultation != null)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (val) async {
              if (val == 'delete') {
                final ok = await _confirmDelete(context, l10n);
                if (ok && context.mounted) {
                  await ref
                      .read(consultationChatProvider(widget.consultationId)
                          .notifier)
                      .deleteConsultation();
                  if (context.mounted) context.go('/consultation');
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'delete', child: Text(l10n.chatDeleteConsultation)),
            ],
          ),
      ],
    );
  }

  Future<void> _editTitle(
    BuildContext context,
    WidgetRef ref,
    Consultation consultation,
    AppLocalizations l10n,
  ) async {
    final ctrl = TextEditingController(text: consultation.title);
    await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chatTitleEdit),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.consultationTitleHint),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }

  Future<bool> _confirmDelete(
      BuildContext context, AppLocalizations l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chatDeleteConsultation),
        content: Text(l10n.consultationDeleteContent),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
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
    required this.showStreamingBubble,
    required this.isStreaming,
    required this.l10n,
  });

  final ScrollController scrollCtrl;
  final List<ConsultationMessage> messages;
  final String streamingText;
  final bool showStreamingBubble;
  final bool isStreaming;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final aura = context.auraColors;
    final theme = Theme.of(context);

    if (messages.isEmpty && !showStreamingBubble) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AuraAvatar(size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.consultationEmptyHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: aura.onSurfaceMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final itemCount = messages.length + (showStreamingBubble ? 1 : 0);

    return ListView.separated(
      controller: scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md,
      ),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) {
        if (i < messages.length) return MessageBubble(message: messages[i]);
        return StreamingBubble(text: streamingText);
      },
    );
  }
}
