import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/consultation.dart';
import 'aura_avatar.dart';

class ConsultationCard extends StatelessWidget {
  const ConsultationCard({
    super.key,
    required this.consultation,
    required this.onTap,
    required this.onDelete,
  });

  final Consultation consultation;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;
    final l10n = AppLocalizations.of(context)!;
    final isface = consultation.analysisType == AnalysisType.face;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        onLongPress: onDelete,
        child: Ink(
          decoration: BoxDecoration(
            color: aura.surfaceContainer,
            border: Border.all(color: aura.cardBorder, width: 1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: aura.cardShadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const AuraAvatar(size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consultation.title ??
                          (isface ? l10n.faceConsultation : l10n.palmConsultation),
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _relativeTime(context, consultation.lastMessageAt, l10n),
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: aura.onSurfaceMuted),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '· ${l10n.consultationMessageCount(consultation.messageCount)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: aura.onSurfaceSubtle),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: aura.onSurfaceSubtle, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeTime(
      BuildContext context, DateTime dt, AppLocalizations l10n) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return '${dt.month}.${dt.day}';
  }
}
