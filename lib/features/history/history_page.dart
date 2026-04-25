import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/supabase/reading_repository.dart';
import '../../domain/entities/reading.dart';
import '../auth/auth_notifier.dart';
import 'history_detail_page.dart';

enum _Filter { all, face, palm }

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  static String _displayName(String? email) {
    if (email == null || email.isEmpty) return '';
    return email.contains('@') ? email.split('@').first : email;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.history)),
      body: authState.isLoggedIn
          ? _HistoryList(
              userId: authState.user!.id,
              displayName: _displayName(authState.user?.email),
            )
          : _LoginPrompt(),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final aura = context.auraColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64, color: aura.onSurfaceSubtle),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.historyLoginPrompt,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: aura.onSurfaceMuted)),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
              onPressed: () => context.push('/auth'),
              child: Text(l10n.login)),
        ],
      ),
    );
  }
}

class _HistoryList extends ConsumerStatefulWidget {
  const _HistoryList({required this.userId, required this.displayName});
  final String userId;
  final String displayName;

  @override
  ConsumerState<_HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends ConsumerState<_HistoryList> {
  List<Reading> _readings = [];
  bool _loading = true;
  String? _error;
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await ref.read(readingRepositoryProvider)
          .getHistory(widget.userId);
      if (mounted) setState(() { _readings = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _delete(Reading reading) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteRecord),
        content: Text(l10n.deleteRecordContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(readingRepositoryProvider).deleteReading(reading.id);
      setState(() => _readings.removeWhere((r) => r.id == reading.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            '${AppLocalizations.of(context)!.deleteFailed}: $e')),
      );
    }
  }

  List<Reading> get _filtered => _readings.where((r) {
    if (_filter == _Filter.face) return r.type == ReadingType.face;
    if (_filter == _Filter.palm) return r.type == ReadingType.palm;
    return true;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final aura = context.auraColors;
    final theme = Theme.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48,
                color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.commonLoadError, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(_error!,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: aura.onSurfaceMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry)),
          ],
        ),
      );
    }

    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 필터 탭
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
          child: SegmentedButton<_Filter>(
            segments: [
              ButtonSegment(
                  value: _Filter.all,
                  label: Text(l10n.historyAll)),
              ButtonSegment(
                  value: _Filter.face,
                  label: Text(l10n.historyFace),
                  icon: const Icon(Icons.face_retouching_natural, size: 16)),
              ButtonSegment(
                  value: _Filter.palm,
                  label: Text(l10n.historyPalm),
                  icon: const Icon(Icons.back_hand_outlined, size: 16)),
            ],
            selected: {_filter},
            onSelectionChanged: (s) =>
                setState(() => _filter = s.first),
            style: ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 목록
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_outlined, size: 56,
                          color: aura.onSurfaceSubtle),
                      const SizedBox(height: AppSpacing.md),
                      Text(l10n.historyEmpty,
                          style: theme.textTheme.bodyLarge?.copyWith(
                              color: aura.onSurfaceMuted)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) => _ReadingCard(
                    reading: filtered[i],
                    onDelete: () => _delete(filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.reading, required this.onDelete});
  final Reading reading;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;
    final l10n = AppLocalizations.of(context)!;
    final isFace = reading.type == ReadingType.face;
    final accent = aura.sectionAccents[isFace ? 'overall' : 'eyes']!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => HistoryDetailPage(reading: reading)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: aura.surfaceContainer,
            border: Border.all(color: aura.cardBorder, width: 1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                  color: aura.cardShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 2)),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  isFace
                      ? Icons.face_retouching_natural_outlined
                      : Icons.back_hand_outlined,
                  color: accent, size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isFace ? l10n.faceAnalysis : l10n.palmAnalysis,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.10),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            reading.subjectName,
                            style: TextStyle(
                              fontSize: 11,
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDateTime(reading.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: aura.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: AppColors.danger, size: 20),
                tooltip: l10n.delete,
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
              Icon(Icons.chevron_right,
                  color: aura.onSurfaceSubtle, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}.${local.month.toString().padLeft(2, '0')}.${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
