import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/l10n/locale_notifier.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_notifier.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _version = '1.0.0+1';
  static const _localeLabels = {
    'ko': '한국어', 'en': 'English', 'ja': '日本語', 'zh': '中文',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeNotifierProvider).languageCode;
    final authState = ref.watch(authNotifierProvider);
    final aura = context.auraColors;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        children: [
          // 프로필 카드 (로그인 시)
          if (authState.isLoggedIn) ...[
            _ProfileCard(
              email: authState.user?.email ?? '',
              aura: aura,
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // 분석 섹션
          _SectionHeader(label: l10n.settingsSectionAnalysis),
          _SettingGroup(children: [
            _SettingRow(
              icon: Icons.language_outlined,
              title: l10n.language,
              value: _localeLabels[locale] ?? locale,
              onTap: () => _showLocaleDialog(context, ref, locale, l10n),
            ),
            _SettingRow(
              icon: Icons.dark_mode_outlined,
              title: l10n.theme,
              value: l10n.themeSystem,
              onTap: () {},
            ),
            _SettingRow(
              icon: Icons.memory_outlined,
              title: l10n.model,
              value: 'Gemma 4 E2B',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: AppSpacing.lg),

          // 개인정보·법적 섹션
          _SectionHeader(label: l10n.settingsSectionPrivacy),
          _SettingGroup(children: [
            _SettingRow(
              icon: Icons.description_outlined,
              title: l10n.termsOfService,
              onTap: () => context.push('/terms'),
            ),
            _SettingRow(
              icon: Icons.privacy_tip_outlined,
              title: l10n.privacyPolicy,
              onTap: () => context.push('/privacy'),
            ),
            _SettingRow(
              icon: Icons.delete_sweep_outlined,
              title: l10n.clearCache,
              onTap: () => _clearCache(context, l10n),
            ),
            if (authState.isLoggedIn)
              _SettingRow(
                icon: Icons.person_remove_outlined,
                title: l10n.deleteAccount,
                isDestructive: true,
                onTap: () => _confirmDeleteAccount(context, ref, l10n),
              ),
          ]),
          const SizedBox(height: AppSpacing.lg),

          // 앱 정보 섹션
          _SectionHeader(label: l10n.settingsSectionAbout),
          _SettingGroup(children: [
            _SettingRow(
              icon: Icons.info_outline,
              title: l10n.version,
              value: _version,
              showChevron: false,
              onTap: () {},
            ),
          ]),
          const SizedBox(height: AppSpacing.xxl),

          // 로그아웃
          if (authState.isLoggedIn)
            OutlinedButton(
              onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
              child: Text(l10n.logout),
            ),
        ],
      ),
    );
  }

  void _showLocaleDialog(
    BuildContext context, WidgetRef ref, String current, AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(l10n.languageSelect),
        children: _localeLabels.entries.map((e) {
          return SimpleDialogOption(
            onPressed: () {
              ref.read(localeNotifierProvider.notifier).setLocale(e.key);
              Navigator.pop(context);
            },
            child: Text(
              e.value,
              style: TextStyle(
                fontWeight:
                    current == e.key ? FontWeight.bold : FontWeight.normal,
                color: current == e.key
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _clearCache(BuildContext context, AppLocalizations l10n) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(l10n.cacheDeleteConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.delete)),
        ],
      ),
    );
    if (confirm != true) return;

    int deletedBytes = 0;
    try {
      final tmpDir = await getTemporaryDirectory();
      if (tmpDir.existsSync()) {
        for (final entity in tmpDir.listSync()) {
          try {
            if (entity is File) {
              deletedBytes += await entity.length();
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.cacheDeleteFailed}: $e')));
      }
      return;
    }
    if (context.mounted) {
      final mb = (deletedBytes / 1024 / 1024).toStringAsFixed(1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cacheDeleteSuccess(mb))));
    }
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context, WidgetRef ref, AppLocalizations l10n,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: const Text('계정과 모든 데이터가 삭제됩니다.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(authNotifierProvider.notifier).signOut();
  }
}

// ── 프로필 카드 ────────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.email,
    required this.aura,
    required this.theme,
  });

  final String email;
  final AuraColors aura;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final displayName =
        email.contains('@') ? email.split('@').first : email;
    final initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'A';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: aura.brandWash,
        color: aura.surfaceContainer,
        border: Border.all(color: aura.cardBorder, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700)),
                Text(email,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: aura.onSurfaceMuted),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 섹션 헤더 ─────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final aura = context.auraColors;
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: aura.onSurfaceSubtle,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── 섹션 그룹 컨테이너 ────────────────────────────────────────────────────────
class _SettingGroup extends StatelessWidget {
  const _SettingGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final aura = context.auraColors;
    return Container(
      decoration: BoxDecoration(
        color: aura.surfaceContainer,
        border: Border.all(color: aura.cardBorder, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, color: aura.cardBorder),
          ],
        ],
      ),
    );
  }
}

// ── 설정 항목 Row ─────────────────────────────────────────────────────────────
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    this.isDestructive = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aura = context.auraColors;
    final cs = theme.colorScheme;
    final color = isDestructive ? AppColors.danger : AppColors.seed;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md - 2),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDestructive ? AppColors.danger : cs.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (value != null)
              Text(value!,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: aura.onSurfaceMuted)),
            if (showChevron) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.chevron_right,
                  size: 18, color: aura.onSurfaceSubtle),
            ],
          ],
        ),
      ),
    );
  }
}
