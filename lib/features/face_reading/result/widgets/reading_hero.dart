import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';

/// 결과 화면 상단 히어로 — 분석 일시 + 상태 타이틀 + 특이점 칩 + 진행바.
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
    final locale = Localizations.localeOf(context).toLanguageTag();

    final dateStr = DateFormat.yMMMd(locale).add_Hm().format(analyzedAt.toLocal());

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
              Icon(Icons.auto_awesome, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.faceResultAnalyzedAt(dateStr),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: aura.onSurfaceMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isStreaming ? l10n.faceResultStreamingTitle : l10n.faceResultReadyTitle,
            style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (highlightChips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final chip in highlightChips)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: aura.cardBorder, width: 1),
                    ),
                    child: Text(chip, style: theme.textTheme.labelMedium),
                  ),
              ],
            ),
          ],
          if (isStreaming) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: progress > 0 && progress < 1 ? progress : null,
                minHeight: 4,
                backgroundColor: aura.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
