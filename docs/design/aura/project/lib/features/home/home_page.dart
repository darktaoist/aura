// lib/features/home/home_page.dart
//
// Aura 홈 — 히어로 + 메인 카드 2종(관상/손금) + 이어가기 섹션
// ─────────────────────────────────────────────────────────────────────────────
// 변경 요약
// • 히어로: 오늘의 한 문장 + Aura 로고 그라데이션 워드마크 + 인사
// • 관상/손금: 2×1 그리드, 각 카드에 은은한 brandWash + Material Symbol,
//   카드 상단 오른쪽에 비로그인 뱃지(게스트 표시) 통합
// • 상담: "이어가기" 섹션으로 하단 분리, 가장 최근 세션 1건 + "모두 보기"
// • 기존 HomeNotifier/GoRouter 시그니처는 변경하지 않음 (provider/route 이름 가정)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import 'providers/home_providers.dart';  // 기존 providers 재사용 (가정)
import 'widgets/aura_wordmark.dart';
import 'widgets/home_hero_card.dart';
import 'widgets/home_resume_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final aura = context.auraColors;

    final dailyLine = ref.watch(dailyLineProvider);          // 기존 provider 가정
    final isGuest = ref.watch(isGuestProvider);              // 기존 provider 가정
    final latestConsultation = ref.watch(latestConsultationProvider); // 기존

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── App bar ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md,
                  AppSpacing.lg, AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const AuraWordmark(size: 22),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.history_outlined),
                      tooltip: l10n.historyTitle,
                      onPressed: () => context.push('/history'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: l10n.settingsTitle,
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Hero ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.sm,
                  AppSpacing.lg, AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // TODO: add key 'homeGreeting' to ARB (e.g. "오늘의 아우라")
                      l10n.homeGreeting,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: aura.onSurfaceSubtle,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // 오늘의 한 문장
                    dailyLine.when(
                      data: (line) => Text(
                        line,
                        style: theme.textTheme.displaySmall?.copyWith(
                          height: 1.3,
                        ),
                      ),
                      loading: () => _shimmerLines(context, lines: 2),
                      error: (_, __) => Text(
                        l10n.homeDailyFallback, // TODO: add key 'homeDailyFallback'
                        style: theme.textTheme.displaySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Main analysis grid 2×1 ────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = AppSpacing.md;
                    final cardW = (constraints.maxWidth - gap) / 2;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: cardW,
                          child: HomeHeroCard(
                            label: l10n.homeFaceLabel,         // "AI 관상"
                            title: l10n.homeFaceTitle,         // "얼굴을 읽다"
                            description: l10n.homeFaceDesc,    // "468 landmarks"
                            icon: Icons.face_retouching_natural_outlined,
                            accent: aura.sectionAccents['overall']!,
                            showGuestBadge: isGuest,
                            onTap: () => context.push('/face'),
                          ),
                        ),
                        const SizedBox(width: gap),
                        SizedBox(
                          width: cardW,
                          child: HomeHeroCard(
                            label: l10n.homePalmLabel,         // "AI 손금"
                            title: l10n.homePalmTitle,         // "손을 읽다"
                            description: l10n.homePalmDesc,    // "21 landmarks"
                            icon: Icons.back_hand_outlined,
                            accent: aura.sectionAccents['eyes']!,
                            showGuestBadge: isGuest,
                            onTap: () => context.push('/palm'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

            // ─── Resume consultation ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Text(
                      l10n.homeResumeTitle, // TODO: add key 'homeResumeTitle' "이어가기"
                      style: theme.textTheme.titleLarge,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push('/consultations'),
                      child: Text(l10n.commonSeeAll), // TODO: add key 'commonSeeAll'
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl,
              ),
              sliver: SliverToBoxAdapter(
                child: latestConsultation.when(
                  data: (item) => item == null
                      ? _EmptyResume(l10n: l10n)
                      : HomeResumeTile(
                          item: item,
                          onTap: () => context.push('/consultations/${item.id}'),
                        ),
                  loading: () => _shimmerLines(context, lines: 2, height: 72),
                  error: (_, __) => _EmptyResume(l10n: l10n),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerLines(BuildContext context, {int lines = 1, double? height}) {
    final aura = context.auraColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i == lines - 1 ? 0 : AppSpacing.sm),
          child: Container(
            height: height ?? 28,
            width: double.infinity,
            decoration: BoxDecoration(
              color: aura.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      }),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
class _EmptyResume extends StatelessWidget {
  const _EmptyResume({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final aura = context.auraColors;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: aura.surfaceContainer,
        border: Border.all(color: aura.cardBorder, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: aura.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 20, color: aura.onSurfaceMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              l10n.homeResumeEmpty, // TODO: add key 'homeResumeEmpty'
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
