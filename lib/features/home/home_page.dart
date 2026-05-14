import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_notifier.dart';
import '../../core/constants/daily_quotes.dart';
import '../model_setup/model_config.dart';
import '../model_setup/model_setup_notifier.dart';
import 'widgets/aura_wordmark.dart';
import 'widgets/home_hero_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(modelSetupNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final isGuest = !authState.isLoggedIn;


    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // ── Vertical poetry strip (left edge) ──────────────────────
                Positioned(
                  left: 0, top: 80, bottom: 80, width: 22,
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        '結이 흐르는 자리, 읽어드립니다',
                        style: GoogleFonts.notoSerifKr(
                          fontSize: 10,
                          color: AppColors.goldLight.withValues(alpha: 0.5),
                          letterSpacing: 5,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Main scroll ─────────────────────────────────────────────
                SafeArea(
                  bottom: false,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Top bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 12, 12, 6),
                          child: Row(
                            children: [
                              const AuraWordmark(size: 20),
                              const Spacer(),
                              // history icon
                              _TopBarIconBtn(
                                icon: Icons.history_outlined,
                                tooltip: l10n.history,
                                onTap: () => context.push('/history'),
                              ),
                              const SizedBox(width: 2),
                              // settings icon
                              _TopBarIconBtn(
                                icon: Icons.tune_outlined,
                                tooltip: l10n.settings,
                                onTap: () => context.push('/settings'),
                              ),
                              const SizedBox(width: 2),
                              // profile / menu (login·logout·약관만)
                              PopupMenuButton<String>(
                                icon: Container(
                                  width: 34, height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.hair, width: 1),
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: AppColors.ivoryMid,
                                  ),
                                ),
                                color: AppColors.bg3,
                                onSelected: (val) {
                                  switch (val) {
                                    case 'login': context.push('/auth');
                                    case 'logout': ref.read(authNotifierProvider.notifier).signOut();
                                    case 'terms': context.push('/terms');
                                    case 'privacy': context.push('/privacy');
                                  }
                                },
                                itemBuilder: (_) => [
                                  if (!authState.isLoggedIn)
                                    PopupMenuItem(value: 'login', child: Text(l10n.login))
                                  else
                                    PopupMenuItem(value: 'logout', child: Text(l10n.logout)),
                                  const PopupMenuDivider(),
                                  PopupMenuItem(value: 'terms', child: Text(l10n.termsOfService)),
                                  PopupMenuItem(value: 'privacy', child: Text(l10n.privacyPolicy)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Daily header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 10, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.homeGreeting.toUpperCase(),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9, letterSpacing: 3,
                                  color: AppColors.goldLight,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                '「${getDailyQuote(Localizations.localeOf(context).languageCode)}」',
                                style: GoogleFonts.notoSerifKr(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.ivory,
                                  height: 1.55,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Hairline rule
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 0, 24, 16),
                          child: Divider(
                            color: AppColors.hair,
                            height: 1, thickness: 1,
                          ),
                        ),
                      ),

                      // Hero cards
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(28, 0, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            children: [
                              HomeHeroCard(
                                label: l10n.homeFaceLabel,
                                title: l10n.homeFaceTitle,
                                description: l10n.homeFaceDesc,
                                icon: Icons.face_retouching_natural_outlined,
                                accent: AppColors.face,
                                sealChar: '相',
                                tall: true,
                                metaLabel: l10n.minRead,
                                silhouette: const FaceSilhouette(),
                                showGuestBadge: isGuest,
                                onTap: () => context.push('/face/camera'),
                              ),
                              const SizedBox(height: 12),
                              HomeHeroCard(
                                label: l10n.homePalmLabel,
                                title: l10n.homePalmTitle,
                                description: l10n.homePalmDesc,
                                icon: Icons.back_hand_outlined,
                                accent: AppColors.palm,
                                sealChar: '掌',
                                tall: true,
                                metaLabel: l10n.minRead,
                                silhouette: const PalmSilhouette(),
                                showGuestBadge: isGuest,
                                onTap: () => context.push('/palm/camera'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // AI Consultation row
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 16, 20, 36),
                          child: GestureDetector(
                            onTap: () => context.push('/consultation'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                                border: Border.all(color: AppColors.hair, width: 1),
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.chat.withValues(alpha: 0.15),
                                    AppColors.bg1.withValues(alpha: 0.6),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  _AvatarBubble(),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${l10n.aiName} · ${l10n.homeConsultLabel}',
                                          style: GoogleFonts.notoSerifKr(
                                            fontSize: 14,
                                            color: AppColors.ivory,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          l10n.homeConsultSub,
                                          style: GoogleFonts.notoSansKr(
                                            fontSize: 11,
                                            color: AppColors.ivoryDim,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: AppColors.goldLight, size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Model download banner
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

class _TopBarIconBtn extends StatelessWidget {
  const _TopBarIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.hair, width: 1),
          ),
          child: Icon(icon, size: 16, color: AppColors.ivoryMid),
        ),
      ),
    );
  }
}

class _AvatarBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.chat.withValues(alpha: 0.25),
            border: Border.all(
              color: AppColors.chat.withValues(alpha: 0.6), width: 0.6,
            ),
          ),
          child: Center(
            child: Text(
              '解',
              style: GoogleFonts.notoSerifKr(
                fontSize: 14, color: AppColors.goldLight,
              ),
            ),
          ),
        ),
        Positioned(
          top: 1, right: 1,
          child: Container(
            width: 7, height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.ok,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Model download banner ────────────────────────────────────────────────────

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
    final downloaded = (progress / 100 * modelSizeGb).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        border: const Border(top: BorderSide(color: AppColors.hair, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${l10n.modelDownloading}…',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text(
                '$progress%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.gold, fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$downloaded GB / ${modelSizeGb.toStringAsFixed(1)} GB',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.ivoryDim,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
