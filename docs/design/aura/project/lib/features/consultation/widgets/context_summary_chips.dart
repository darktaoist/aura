// lib/features/consultation/widgets/context_summary_chips.dart
//
// 상담 컨텍스트 요약 칩 — 접기/펼치기 토글.
// 분석 리포트의 highlight 태그들을 칩으로 펼쳐 보여준다.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../models/consultation_context.dart'; // 기존 (가정)

class ContextSummaryChips extends StatelessWidget {
  const ContextSummaryChips({
    super.key,
    required this.context,
    required this.expanded,
    required this.onToggle,
  });

  final ConsultationContext context;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext ctx) {
    final theme = Theme.of(ctx);
    final aura = ctx.auraColors;
    final l10n = AppLocalizations.of(ctx)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      decoration: BoxDecoration(
        color: aura.surfaceContainer,
        border: Border.all(color: aura.cardBorder, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
              child: Row(
                children: [
                  Icon(Icons.insights_outlined,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.consultationContextTitle,
                    // TODO: add key 'consultationContextTitle'
                    style: theme.textTheme.labelMedium,
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      Icons.expand_more,
                      size: 18, color: aura.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final tag in context.highlights)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 6),
                      decoration: BoxDecoration(
                        color: aura.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        tag, style: theme.textTheme.labelMedium),
                    ),
                ],
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 240),
          ),
        ],
      ),
    );
  }
}
