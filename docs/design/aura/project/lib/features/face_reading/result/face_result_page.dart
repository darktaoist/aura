// lib/features/face_reading/result/face_result_page.dart
//
// 관상 분석 결과 화면 — 항상 펼쳐진 리포트 카드 6개 + 고정 CTA.
// ─────────────────────────────────────────────────────────────────────────────
// 변경 요약
// • ExpansionTile 전면 제거 → 모두 펼쳐진 ReadingSectionCard 리스트
// • 상단 히어로: 분석 일시 + 핵심 특이점 요약 칩 + 프로그레스(스트리밍 중)
// • 스트리밍 중인 섹션은 cardBorderAccent + glow pulse + progressive fade-in
// • 하단 고정: 저장 / 상담하기 CTA (BottomAppBar 스타일, safe area 존중)
// • 기존 FaceReadingNotifier 상태/시그니처는 그대로 소비 (가정)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import 'providers/face_result_providers.dart'; // 기존 provider 가정
import 'widgets/reading_section_card.dart';
import 'widgets/reading_hero.dart';

class FaceResultPage extends ConsumerWidget {
  const FaceResultPage({super.key, required this.readingId});
  final String readingId;

  static const _sectionOrder = <String>[
    'forehead', 'eyes', 'nose', 'mouth', 'chin', 'overall',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final aura = context.auraColors;

    final state = ref.watch(faceResultProvider(readingId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.faceResultTitle), // TODO: add key 'faceResultTitle'
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: l10n.commonShare, // TODO: add key 'commonShare'
            onPressed: state.isComplete ? () => _share(context, ref) : null,
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm,
          AppSpacing.lg, AppSpacing.xxl + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          ReadingHero(
            analyzedAt: state.analyzedAt,
            highlightChips: state.highlights, // List<String>
            isStreaming: state.isStreaming,
            progress: state.progress,
          ),
          const SizedBox(height: AppSpacing.xl),

          // ─── Section cards ───────────────────────────────────────────
          for (var i = 0; i < _sectionOrder.length; i++) ...[
            _AnimatedSectionSlot(
              index: i,
              visible: state.sections[_sectionOrder[i]] != null,
              child: ReadingSectionCard(
                sectionId: _sectionOrder[i],
                accent: aura.sectionAccents[_sectionOrder[i]]!,
                label: _sectionLabel(l10n, _sectionOrder[i]),
                title: state.sectionTitle(_sectionOrder[i]) ?? '',
                body: state.sections[_sectionOrder[i]] ?? '',
                icon: _sectionIcon(_sectionOrder[i]),
                isStreaming: state.streamingSection == _sectionOrder[i],
              ),
            ),
            if (i != _sectionOrder.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),

      // ─── CTA bar (BottomAppBar 스타일) ───────────────────────────────
      bottomNavigationBar: _ResultCtaBar(
        enabled: state.isComplete,
        onSave: () => ref.read(faceResultProvider(readingId).notifier).save(),
        onConsult: () => context.push('/consultation/new?from=$readingId'),
      ),
    );
  }

  String _sectionLabel(AppLocalizations l, String id) {
    // TODO: add keys 'sectionForehead'/'sectionEyes'/... to ARB
    switch (id) {
      case 'forehead': return l.sectionForehead;
      case 'eyes':     return l.sectionEyes;
      case 'nose':     return l.sectionNose;
      case 'mouth':    return l.sectionMouth;
      case 'chin':     return l.sectionChin;
      case 'overall':  return l.sectionOverall;
    }
    return '';
  }

  IconData _sectionIcon(String id) {
    switch (id) {
      case 'forehead': return Icons.waves_outlined;
      case 'eyes':     return Icons.visibility_outlined;
      case 'nose':     return Icons.air_outlined;
      case 'mouth':    return Icons.chat_bubble_outline;
      case 'chin':     return Icons.landscape_outlined;
      case 'overall':  return Icons.auto_awesome_outlined;
    }
    return Icons.circle_outlined;
  }

  void _share(BuildContext context, WidgetRef ref) {
    // 기존 share 로직 재사용 (notifier 호출)
    ref.read(faceResultProvider(readingId).notifier).share();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Progressive fade-in wrapper — 섹션이 스트리밍으로 도착할 때 살짝 들어올린다.
// ═════════════════════════════════════════════════════════════════════════════
class _AnimatedSectionSlot extends StatelessWidget {
  const _AnimatedSectionSlot({
    required this.index,
    required this.visible,
    required this.child,
  });
  final int index;
  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, anim) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06), end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        );
      },
      child: visible
          ? KeyedSubtree(key: ValueKey('section-$index'), child: child)
          : const SizedBox(
              key: ValueKey('skel'),
              height: 120,
            ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
class _ResultCtaBar extends StatelessWidget {
  const _ResultCtaBar({
    required this.enabled,
    required this.onSave,
    required this.onConsult,
  });
  final bool enabled;
  final VoidCallback onSave;
  final VoidCallback onConsult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: aura.cardBorder, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md,
        AppSpacing.lg, AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: enabled ? onSave : null,
              icon: const Icon(Icons.bookmark_outline, size: 18),
              label: Text(l10n.commonSave), // TODO: add key 'commonSave'
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: enabled ? onConsult : null,
              icon: const Icon(Icons.psychology_outlined, size: 18),
              label: Text(l10n.resultConsult), // TODO: add key 'resultConsult'
            ),
          ),
        ],
      ),
    );
  }
}
