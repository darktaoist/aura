// lib/features/history/history_page.dart
//
// 분석 히스토리 — 2열 썸네일 카드 그리드. 관상/손금 필터 탭.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import 'providers/history_providers.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final aura = context.auraColors;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: false,
          dividerColor: Colors.transparent,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 2,
          labelStyle: theme.textTheme.labelLarge,
          unselectedLabelColor: aura.onSurfaceMuted,
          tabs: [
            Tab(text: l10n.historyAll),     // TODO: add key
            Tab(text: l10n.historyFace),    // TODO: add key
            Tab(text: l10n.historyPalm),    // TODO: add key
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _HistoryGrid(filter: HistoryFilter.all),
          _HistoryGrid(filter: HistoryFilter.face),
          _HistoryGrid(filter: HistoryFilter.palm),
        ],
      ),
    );
  }
}

class _HistoryGrid extends ConsumerWidget {
  const _HistoryGrid({required this.filter});
  final HistoryFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(historyListProvider(filter));
    final aura = context.auraColors;

    return items.when(
      data: (list) => GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.78,
        ),
        itemCount: list.length,
        itemBuilder: (context, i) => _HistoryCard(item: list[i]),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Icon(Icons.error_outline, color: aura.onSurfaceMuted),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;
    final accent =
        item?.kind == 'palm' ? aura.sectionAccents['eyes']! : aura.sectionAccents['overall']!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => context.push('/readings/${item.id}'),
        child: Ink(
          decoration: BoxDecoration(
            color: aura.surfaceContainer,
            border: Border.all(color: aura.cardBorder, width: 1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withOpacity(0.18),
                          accent.withOpacity(0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        item?.kind == 'palm'
                            ? Icons.back_hand_outlined
                            : Icons.face_retouching_natural_outlined,
                        size: 56,
                        color: accent.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (item?.title as String?) ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat.yMMMd().format(
                        (item?.createdAt as DateTime?) ?? DateTime.now()),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: aura.onSurfaceSubtle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
