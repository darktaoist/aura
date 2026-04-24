import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/l10n/generated/app_localizations.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
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
      final text = await rootBundle.loadString('assets/legal/$locale/terms.md');
      if (mounted) setState(() => _content = text);
    } catch (_) {
      try {
        final text = await rootBundle.loadString('assets/legal/ko/terms.md');
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
      appBar: AppBar(title: Text(l10n.termsOfService)),
      body: _content.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Markdown(data: _content),
    );
  }
}
