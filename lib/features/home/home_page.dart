import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_notifier.dart';
import '../consultation/providers/consultation_list_provider.dart';
import '../model_setup/model_config.dart';
import '../model_setup/model_setup_notifier.dart';
import 'widgets/aura_wordmark.dart';
import 'widgets/home_hero_card.dart';
import 'widgets/home_resume_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(modelSetupNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final isGuest = !authState.isLoggedIn;
    final theme = Theme.of(context);
    final aura = context.auraColors;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── App bar ─────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.md,
                        AppSpacing.sm, AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          const AuraWordmark(size: 22),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.history_outlined),
                            tooltip: l10n.history,
                            onPressed: () => context.push('/history'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            tooltip: l10n.settings,
                            onPressed: () => context.push('/settings'),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (val) {
                              switch (val) {
                                case 'login':
                                  context.push('/auth');
                                case 'logout':
                                  ref.read(authNotifierProvider.notifier).signOut();
                                case 'terms':
                                  context.push('/terms');
                                case 'privacy':
                                  context.push('/privacy');
                              }
                            },
                            itemBuilder: (_) => [
                              if (!authState.isLoggedIn)
                                PopupMenuItem(value: 'login', child: Text(l10n.login))
                              else
                                PopupMenuItem(value: 'logout', child: Text(l10n.logout)),
                              PopupMenuItem(value: 'terms', child: Text(l10n.termsOfService)),
                              PopupMenuItem(value: 'privacy', child: Text(l10n.privacyPolicy)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Hero ────────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.md,
                        AppSpacing.lg, AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.homeGreeting,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: aura.onSurfaceSubtle,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.homeDailyFallback,
                            style: theme.textTheme.displaySmall?.copyWith(height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── 관상/손금 2×1 그리드 ────────────────────────────────
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
                                  label: l10n.homeFaceLabel,
                                  title: l10n.homeFaceTitle,
                                  description: l10n.homeFaceDesc,
                                  icon: Icons.face_retouching_natural_outlined,
                                  accent: aura.sectionAccents['overall']!,
                                  showGuestBadge: isGuest,
                                  onTap: () => context.push('/face/camera'),
                                ),
                              ),
                              const SizedBox(width: gap),
                              SizedBox(
                                width: cardW,
                                child: HomeHeroCard(
                                  label: l10n.homePalmLabel,
                                  title: l10n.homePalmTitle,
                                  description: l10n.homePalmDesc,
                                  icon: Icons.back_hand_outlined,
                                  accent: aura.sectionAccents['eyes']!,
                                  showGuestBadge: isGuest,
                                  onTap: () => context.push('/palm/camera'),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

                  // ── 이어가기 섹션 헤더 ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Row(
                        children: [
                          Text(l10n.homeResumeTitle,
                              style: theme.textTheme.titleLarge),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/consultation'),
                            child: Text(l10n.commonSeeAll),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

                  // ── 최근 상담 1건 or 빈 상태 ────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _ResumeSection(l10n: l10n),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 모델 다운로드 배너 ──────────────────────────────────────────
          if (setupState.isDownloading)
            _ModelDownloadBanner(
              progress: setupState.progress,
              modelSizeGb: kDefaultModel.sizeGb,
              l10n: l10n,
            ),
        ],
      ),
    );
  }
}

// ── 이어가기 섹션 (로그인/비로그인/로딩 분기) ─────────────────────────────────
class _ResumeSection extends ConsumerWidget {
  const _ResumeSection({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aura = context.auraColors;
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);

    if (!authState.isLoggedIn) {
      return _emptyResume(context, aura, theme, l10n);
    }

    final asyncList = ref.watch(consultationListProvider);
    return asyncList.when(
      loading: () => _shimmer(aura),
      error: (_, __) => _emptyResume(context, aura, theme, l10n),
      data: (list) {
        if (list.isEmpty) return _emptyResume(context, aura, theme, l10n);
        final latest = list.first;
        return HomeResumeTile(
          consultation: latest,
          onTap: () => context.push('/consultation/${latest.id}'),
        );
      },
    );
  }

  Widget _shimmer(AuraColors aura) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: aura.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: aura.cardBorder, width: 1),
      ),
    );
  }

  Widget _emptyResume(
    BuildContext context, AuraColors aura, ThemeData theme, AppLocalizations l10n,
  ) {
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
            child: Icon(Icons.chat_bubble_outline,
                size: 20, color: aura.onSurfaceMuted),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(l10n.homeResumeEmpty,
                style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// ── 모델 다운로드 배너 ─────────────────────────────────────────────────────────
class _ModelDownloadBanner extends StatelessWidget {
  const _ModelDownloadBanner({
    required this.progress,
    required this.modelSizeGb,
    required this.l10n,
  });

  final int progress;
  final double modelSizeGb;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final downloaded = (progress / 100 * modelSizeGb).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${l10n.modelDownloading}…',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text('$progress%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.bold,
                      )),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 6,
              backgroundColor: cs.outlineVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$downloaded GB / ${modelSizeGb.toStringAsFixed(1)} GB',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
