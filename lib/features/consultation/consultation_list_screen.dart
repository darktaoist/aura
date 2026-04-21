import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/consultation.dart';
import '../../services/consultation_service.dart';
import 'providers/consultation_list_provider.dart';
import 'widgets/consultation_card.dart';

class ConsultationListScreen extends ConsumerWidget {
  const ConsultationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(consultationListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('상담 기록')),
      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (list) => list.isEmpty
            ? _Empty(onStartAnalysis: () => context.push('/face/camera'))
            : _List(
                consultations: list,
                onTap: (c) => context.push('/consultation/${c.id}'),
                onDelete: (c) => _confirmDelete(context, ref, c),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/consultation/picker'),
        icon: const Icon(Icons.add),
        label: const Text('새 상담'),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Consultation consultation,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('상담 삭제'),
        content: const Text('이 상담을 삭제할까요?\n대화 내용이 모두 사라집니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(consultationServiceProvider).deleteConsultation(consultation.id);
    ref.invalidate(consultationListProvider);
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onStartAnalysis});
  final VoidCallback onStartAnalysis;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '아직 상담 기록이 없습니다',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onStartAnalysis,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('관상/손금 분석부터 시작하세요'),
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
