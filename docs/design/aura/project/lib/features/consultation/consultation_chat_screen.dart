// lib/features/consultation/consultation_chat_screen.dart
//
// AI 상담 채팅 — 분석 컨텍스트 칩 + 은은한 그라데이션 워시 배경 + 타이핑 인디케이터.
// ─────────────────────────────────────────────────────────────────────────────
// 변경 요약
// • AppBar 에 Aura 심볼 아바타(brandGradient 원) + 분석 대상자 표시
// • 상단에 접기/펼치기 가능한 컨텍스트 요약 칩(관상/손금 요약 태그들)
// • 배경에 아주 은은한 radial wash (brand 색, 3% opacity)
// • 기존 ConsultationChatNotifier 시그니처는 그대로 사용 (가정)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import 'providers/consultation_providers.dart'; // 기존 (가정)
import 'widgets/message_bubble.dart';
import 'widgets/chat_composer.dart';
import 'widgets/context_summary_chips.dart';
import 'widgets/aura_avatar.dart';

class ConsultationChatScreen extends ConsumerStatefulWidget {
  const ConsultationChatScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  ConsumerState<ConsultationChatScreen> createState() =>
      _ConsultationChatScreenState();
}

class _ConsultationChatScreenState
    extends ConsumerState<ConsultationChatScreen> {
  final ScrollController _scroll = ScrollController();
  bool _contextExpanded = true;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final aura = context.auraColors;

    final state = ref.watch(consultationChatProvider(widget.sessionId));

    // 스트리밍 도착 시 자동 스크롤
    ref.listen(consultationChatProvider(widget.sessionId), (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
          );
        }
      });
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const AuraAvatar(size: 28),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.consultationAuraTitle, // TODO: add key 'consultationAuraTitle' "Aura"
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    state.subjectLabel ?? l10n.consultationSubjectYou,
                    // TODO: add key 'consultationSubjectYou'
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
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {/* menu */},
          ),
        ],
      ),
      body: Stack(
        children: [
          // ─── 배경 워시 ──────────────────────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.8),
                    radius: 1.2,
                    colors: [
                      theme.colorScheme.primary.withOpacity(
                        theme.brightness == Brightness.dark ? 0.08 : 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ─── 컨텍스트 요약 칩 (접기/펼치기) ───────────────────────
                if (state.context != null)
                  ContextSummaryChips(
                    context: state.context!,
                    expanded: _contextExpanded,
                    onToggle: () => setState(() {
                      _contextExpanded = !_contextExpanded;
                    }),
                  ),

                // ─── 메시지 리스트 ───────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    controller: _scroll,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.md,
                      AppSpacing.lg, AppSpacing.md,
                    ),
                    itemCount: state.messages.length +
                        (state.isAiTyping ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) {
                      if (i == state.messages.length && state.isAiTyping) {
                        return const _TypingBubble();
                      }
                      final m = state.messages[i];
                      return MessageBubble(message: m);
                    },
                  ),
                ),

                // ─── Composer ─────────────────────────────────────────────
                ChatComposer(
                  enabled: !state.isAiTyping,
                  onSend: (text) => ref
                      .read(consultationChatProvider(widget.sessionId).notifier)
                      .sendUserMessage(text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final aura = context.auraColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const AuraAvatar(size: 24),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: aura.surfaceContainer,
            border: Border.all(color: aura.cardBorder, width: 1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(AppRadius.lg),
              bottomLeft: Radius.circular(AppRadius.lg),
              bottomRight: Radius.circular(AppRadius.lg),
            ),
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              final t = _c.value;
              Widget dot(double phase) {
                final v = (1 + (((t + phase) * 2 * 3.14159).remainder(2 * 3.14159)).toDouble());
                final y = -3.0 * (0.5 + 0.5 * (v - 1));
                return Transform.translate(
                  offset: Offset(0, y),
                  child: Container(
                    width: 6, height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: aura.aiPulse.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [dot(0), dot(0.33), dot(0.66)],
              );
            },
          ),
        ),
      ],
    );
  }
}
