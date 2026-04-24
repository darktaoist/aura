import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

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
    final isDark = theme.brightness == Brightness.dark;
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
                accent.withValues(alpha: isDark ? 0.18 : 0.08),
                accent.withValues(alpha: isDark ? 0.06 : 0.02),
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
                Positioned(
                  right: -12, bottom: -12,
                  child: Icon(
                    icon,
                    size: 128,
                    color: accent.withValues(alpha: isDark ? 0.22 : 0.14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: theme.textTheme.labelMedium?.copyWith(
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
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(color: aura.cardBorder, width: 1),
                              ),
                              child: Text(
                                l10n.commonGuest,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  letterSpacing: 0.6,
                                  color: aura.onSurfaceMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
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
                      const Spacer(),
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
