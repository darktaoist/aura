import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/l10n/locale_notifier.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _version = '1.0.0+1';

  static const _localeLabels = {
    'ko': '한국어',
    'en': 'English',
    'ja': '日本語',
    'zh': '中文',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeNotifierProvider).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.language),
            subtitle: Text(_localeLabels[locale] ?? locale),
            onTap: () => _showLocaleDialog(context, ref, locale),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: Text(l10n.theme),
            subtitle: Text(l10n.themeSystem),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.memory_outlined),
            title: Text(l10n.model),
            subtitle: const Text('Gemma 4 E2B'),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.delete_outline, color: cs.error),
            title: Text(l10n.clearCache, style: TextStyle(color: cs.error)),
            onTap: () => _clearCache(context, l10n),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.version),
            subtitle: const Text(_version),
          ),
        ],
      ),
    );
  }

  void _showLocaleDialog(BuildContext context, WidgetRef ref, String current) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(l10n.languageSelect),
        children: _localeLabels.entries
            .map(
              (e) => SimpleDialogOption(
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
              ),
            )
            .toList(),
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
          SnackBar(content: Text('${l10n.cacheDeleteFailed}: $e')),
        );
      }
      return;
    }

    if (context.mounted) {
      final mb = (deletedBytes / 1024 / 1024).toStringAsFixed(1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cacheDeleteSuccess(mb))),
      );
    }
  }
}
