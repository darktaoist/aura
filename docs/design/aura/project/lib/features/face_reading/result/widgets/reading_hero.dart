// lib/features/face_reading/result/widgets/reading_hero.dart
//
// 결과 화면 상단 히어로 — 분석 일시 + 핵심 특이점 요약 칩 + 진행률 표시.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

class ReadingHero extends StatelessWidget {
  const ReadingHero({
    super.key,
    required this.analyzedAt,
    required this.highlightChips,
    required this.isStreaming,
    required this.progress,
  });

  final DateTime analyzedAt;
  final List<String> highlightChips;
  final bool isStreaming;
  final double progress; // 0..1

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: aura.brandWash,
        color: aura.surfaceContainer,
        border: Border.all(color: aura.cardBorder, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.faceResultAnalyzedAt(
                  DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
                      .add_Hm()
                      .format(analyzedAt),
                ), // TODO: add key 'faceResultAnalyzedAt' (plural/placeholder)
                style: theme.textTheme.labelSmall?.copyWith(
                  color: aura.onSurfaceMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isStreaming
                ? l10n.faceResultStreamingTitle // TODO: add key 'faceResultStreamingTitle'
                : l10n.faceResultReadyTitle,    // TODO: add key 'faceResultReadyTitle'
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (highlightChips.isNotEmpty)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final tag in highlightChips)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: aura.cardBorder, width: 1),
                    ),
                    child: Text(
                      tag,
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
              ],
            ),

          if (isStreaming) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: progress > 0 && progress < 1 ? progress : null,
                minHeight: 4,
                backgroundColor: aura.surfaceContainerHighest,
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
