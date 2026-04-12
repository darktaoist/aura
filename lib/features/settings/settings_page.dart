import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _locale = 'ko';
  // 버전은 pubspec.yaml 과 동기화 — 자동화는 package_info_plus 추가 후 진행
  static const _version = '1.0.0+1';

  static const _localeLabels = {
    'ko': '한국어',
    'en': 'English',
    'ja': '日本語',
    'zh': '中文',
  };

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _locale = prefs.getString('locale') ?? 'ko';
    });
  }

  Future<void> _setLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);
    if (mounted) setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          // 언어 설정
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('언어'),
            subtitle: Text(_localeLabels[_locale] ?? _locale),
            onTap: () => _showLocaleDialog(context),
          ),
          const Divider(height: 1),
          // 테마 (TODO Phase 7: Riverpod themeNotifier 연결)
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('테마'),
            subtitle: const Text('시스템 설정 따름'),
            onTap: () {},
          ),
          const Divider(height: 1),
          // AI 모델
          ListTile(
            leading: const Icon(Icons.memory_outlined),
            title: const Text('AI 모델'),
            subtitle: const Text('Gemma 4 E2B'),
            onTap: () {},
          ),
          const Divider(height: 1),
          // 캐시 삭제
          ListTile(
            leading: Icon(Icons.delete_outline, color: cs.error),
            title: Text('캐시 삭제', style: TextStyle(color: cs.error)),
            onTap: () => _clearCache(context),
          ),
          const Divider(height: 1),
          // 버전
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('버전'),
            subtitle: Text(_version),
          ),
        ],
      ),
    );
  }

  void _showLocaleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('언어 선택'),
        children: _localeLabels.entries
            .map(
              (e) => SimpleDialogOption(
                onPressed: () {
                  _setLocale(e.key);
                  Navigator.pop(context);
                },
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontWeight:
                        _locale == e.key ? FontWeight.bold : FontWeight.normal,
                    color: _locale == e.key
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

  Future<void> _clearCache(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('캐시 삭제'),
        content: const Text('앱 캐시를 삭제하시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제')),
        ],
      ),
    );

    if (confirm != true) return;

    int deletedBytes = 0;
    try {
      // 임시 디렉토리 삭제
      final tmpDir = await getTemporaryDirectory();
      if (tmpDir.existsSync()) {
        final entities = tmpDir.listSync();
        for (final entity in entities) {
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
          SnackBar(content: Text('캐시 삭제 실패: $e')),
        );
      }
      return;
    }

    if (context.mounted) {
      final mb = (deletedBytes / 1024 / 1024).toStringAsFixed(1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('캐시 삭제 완료 (${mb}MB)')),
      );
    }
  }
}
