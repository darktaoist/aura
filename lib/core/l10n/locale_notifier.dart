import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_notifier.g.dart';

const _kSupported = ['ko', 'en', 'ja', 'zh'];

/// 디바이스 언어 → 지원 언어 매핑. 미지원 시 'en' 반환.
String _detectDeviceLocale() {
  final raw = Platform.localeName; // e.g. "ko_KR", "ja_JP", "zh_CN"
  final lang = raw.split('_').first.toLowerCase();
  return _kSupported.contains(lang) ? lang : 'en';
}

@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    _loadLocale();
    return const Locale('en'); // 비동기 로드 전 임시값
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String code;
    if (prefs.containsKey('locale')) {
      code = prefs.getString('locale')!;
    } else {
      // 첫 실행 — 디바이스 언어 자동 감지 후 저장
      code = _detectDeviceLocale();
      await prefs.setString('locale', code);
    }
    state = Locale(code);
  }

  Future<void> setLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', code);
    state = Locale(code);
  }
}
