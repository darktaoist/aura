// lib/features/consultation/consultation_list_screen.dart
//
// 상담 목록 화면 — 빈 상태 일러스트(도형 기반) + 세션 카드 리스트.
// ─────────────────────────────────────────────────────────────────────────────
// 변경 요약
// • 빈 상태: 중앙에 그라데이션 원 + Material Symbol + 안내 문구 + 시작 CTA
// • 세션 카드: 썸네일(아바타) + 제목/스니펫/타임스탬프 + unread 뱃지
// • pull-to-refresh + SliverAppBar large title 패턴
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import 'providers/consultation_providers.dart';
import 'widgets/aura_avatar.dart';

class ConsultationListScreen extends ConsumerWidget {
  const ConsultationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final aura = context.auraColors;
    final list = ref.watch(consultationListProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.refresh(consultationListProvider.future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 108,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                title: Text(
                  l10n.consultationsTitle,
                  // TODO: add key 'consultationsTitle'
                  style: theme.textTheme.headlineLarge,
                ),
              ),
            ),
            list.when(
              data: (items) => items.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        onStart: () => context.push('/consultation/new'),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
                      sliver: SliverList.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) {
                          final it = items[i];
                          return _SessionCard(
                            title: it.title,
                            snippet: it.preview,
                            updatedAt: it.updatedAt,
                            unread: it.unreadCount,
                            onTap: () =>
                                context.push('/consultations/${it.id}'),
                          );
                        },
                      ),
                    ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    l10n.commonLoadError, // TODO: add key 'commonLoadError'
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: aura.onSurfaceMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 도형 기반 일러스트 — 그라데이션 원 + 겹쳐진 반투명 원 + 중앙 심볼
          SizedBox(
            width: 160, height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    gradient: aura.brandWash,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: aura.surfaceContainer,
                    border: Border.all(color: aura.cardBorder, width: 1),
                    shape: BoxShape.circle,
                  ),
                ),
                const AuraAvatar(size: 56),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.consultationEmptyTitle, // TODO: add key
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.consultationEmptyBody, // TODO: add key
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: aura.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.consultationStart), // TODO: add key
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.title,
    required this.snippet,
    required this.updatedAt,
    required this.unread,
    required this.onTap,
  });

  final String title;
  final String snippet;
  final DateTime updatedAt;
  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: aura.surfaceContainer,
            border: Border.all(color: aura.cardBorder, width: 1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuraAvatar(size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          DateFormat.MMMd().format(updatedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: aura.onSurfaceSubtle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            snippet,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: aura.onSurfaceMuted,
                            ),
                          ),
                        ),
                        if (unread > 0) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: AppColors.brandGradient,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              '$unread',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
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
