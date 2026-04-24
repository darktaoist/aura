// lib/features/home/widgets/home_hero_card.dart
//
// 홈 메인 카드 — 관상/손금.
// 카드 배경에 brandWash 그라데이션 + 좌하단 큰 Material Symbol.
// 비로그인 상태면 우상단 "게스트" 뱃지 표시.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    super.key,
    required this.label,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.showGuestBadge = false,
  });

  final String label;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final bool showGuestBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withOpacity(theme.brightness == Brightness.dark ? 0.18 : 0.08),
                accent.withOpacity(theme.brightness == Brightness.dark ? 0.06 : 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            color: aura.surfaceContainer,
            border: Border.all(color: aura.cardBorder, width: 1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: aura.cardShadow,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 0.82,
            child: Stack(
              children: [
                // 배경 아이콘 — 카드 우하단 오프셋, 은은한 포지션.
                Positioned(
                  right: -12, bottom: -12,
                  child: Icon(
                    icon,
                    size: 128,
                    color: accent.withOpacity(
                      theme.brightness == Brightness.dark ? 0.22 : 0.14,
                    ),
                  ),
                ),
                // 컨텐츠
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accent,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const Spacer(),
                          if (showGuestBadge)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: aura.surfaceContainerHighest,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: aura.cardBorder, width: 1),
                              ),
                              child: Text(
                                l10n.commonGuest, // TODO: add key 'commonGuest'
                                style: theme.textTheme.labelSmall?.copyWith(
                                  letterSpacing: 0.6,
                                  color: aura.onSurfaceMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: aura.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
