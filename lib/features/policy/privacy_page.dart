import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/l10n/generated/app_localizations.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  String _content = '';
  String? _loadedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (locale != _loadedLocale) {
      _loadedLocale = locale;
      _load(locale);
    }
  }

  Future<void> _load(String locale) async {
    try {
      final text = await rootBundle.loadString('assets/legal/$locale/privacy.md');
      if (mounted) setState(() => _content = text);
    } catch (_) {
      try {
        final text = await rootBundle.loadString('assets/legal/ko/privacy.md');
        if (mounted) setState(() => _content = text);
      } catch (_) {
        if (mounted) setState(() => _content = '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicy)),
      body: _content.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Markdown(data: _content),
    );
  }
}
