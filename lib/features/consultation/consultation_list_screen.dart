import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/aura_avatar.dart';
import '../../models/consultation.dart';
import '../../services/consultation_service.dart';
import 'providers/consultation_list_provider.dart';
import 'widgets/consultation_card.dart';

class ConsultationListScreen extends ConsumerWidget {
  const ConsultationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncList = ref.watch(consultationListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.consultationListTitle)),
      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorPrefix}: $e')),
        data: (list) => list.isEmpty
            ? _Empty(onStartAnalysis: () => context.push('/face/camera'), l10n: l10n)
            : _List(
                consultations: list,
                onTap: (c) => context.push('/consultation/${c.id}'),
                onDelete: (c) => _confirmDelete(context, ref, c, l10n),
              ),
      ),
      floatingActionButton: _GradientFab(
        label: l10n.consultationListNew,
        onPressed: () => context.push('/consultation/picker'),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context, WidgetRef ref,
    Consultation consultation, AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chatDeleteConsultation),
        content: Text(l10n.consultationDeleteContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(consultationServiceProvider).deleteConsultation(consultation.id);
    ref.invalidate(consultationListProvider);
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onStartAnalysis, required this.l10n});
  final VoidCallback onStartAnalysis;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64,
              color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.consultationListEmpty,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onStartAnalysis,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(l10n.consultationListEmptyAction),
          ),
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.consultations,
    required this.onTap,
    required this.onDelete,
  });

  final List<Consultation> consultations;
  final void Function(Consultation) onTap;
  final void Function(Consultation) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: consultations.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => ConsultationCard(
        consultation: consultations[i],
        onTap: () => onTap(consultations[i]),
        onDelete: () => onDelete(consultations[i]),
      ),
    );
  }
}

class _GradientFab extends StatelessWidget {
  const _GradientFab({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: [
            BoxShadow(
              color: AppColors.seed.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AuraAvatar(size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
