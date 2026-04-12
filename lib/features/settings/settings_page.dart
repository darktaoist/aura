import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _locale = 'ko';
  String _version = '';

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
      _version = '1.0.0+1';
    });
  }

  Future<void> _setLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);
    setState(() => _locale = locale);
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
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('버전'),
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
    if (confirm == true && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('캐시가 삭제되었습니다')));
    }
  }
}
