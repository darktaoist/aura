import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  String _content = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final text = await rootBundle.loadString('assets/legal/ko/privacy.md');
      setState(() => _content = text);
    } catch (_) {
      setState(() => _content = '# 개인정보처리방침\n\n준비 중입니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('개인정보처리방침')),
      body: _content.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Markdown(data: _content),
    );
  }
}
