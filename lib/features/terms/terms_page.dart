import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  String _content = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final text = await rootBundle.loadString('assets/legal/ko/terms.md');
      setState(() => _content = text);
    } catch (_) {
      setState(() => _content = '# 이용약관\n\n준비 중입니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이용약관')),
      body: _content.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Markdown(data: _content),
    );
  }
}
