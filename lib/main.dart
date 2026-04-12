import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Release 빌드에서 Supabase 환경변수 미설정 시 즉시 실패
  // (kDebugMode에서는 경고만 출력하고 계속 진행)
  if (Env.supabaseUrl.isEmpty || Env.supabaseAnonKey.isEmpty) {
    if (!kDebugMode) {
      throw StateError(
        'SUPABASE_URL 또는 SUPABASE_ANON_KEY 가 설정되지 않았습니다.\n'
        'flutter build --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... 로 빌드하세요.',
      );
    } else {
      debugPrint(
        '[main] WARNING: SUPABASE_URL / SUPABASE_ANON_KEY not set. '
        'Supabase features will be unavailable.',
      );
    }
  }

  // Gemma 초기화
  await FlutterGemma.initialize();

  // Supabase 초기화
  if (Env.supabaseUrl.isNotEmpty && Env.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }

  runApp(const ProviderScope(child: AuraApp()));
}
