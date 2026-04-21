import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// OAuth callback을 처리하는 페이지.
/// go_router가 /login-callback 경로를 잡아 에러 화면 대신 표시한다.
/// supabase_flutter의 자동 deep link 처리를 먼저 기다리고,
/// 3초 내 세션이 생기지 않으면 수동으로 getSessionFromUrl을 호출한다.
class AuthCallbackPage extends StatefulWidget {
  const AuthCallbackPage({super.key, required this.callbackUri});

  final Uri callbackUri;

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  StreamSubscription<AuthState>? _sub;
  Timer? _fallbackTimer;
  bool _handled = false;

  @override
  void initState() {
    super.initState();

    // 1) 자동 처리 대기: authStateChanges에서 session 수신 시 홈 이동
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.session != null && !_handled) {
        _handled = true;
        debugPrint('[AuthCallback] session received via authStateChanges');
        if (mounted) context.go('/home');
      }
    });

    // 2) 3초 후에도 세션 없으면 수동 처리
    _fallbackTimer = Timer(const Duration(seconds: 3), _manualExchange);
  }

  Future<void> _manualExchange() async {
    if (_handled) return;
    debugPrint('[AuthCallback] fallback: calling getSessionFromUrl manually');
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(widget.callbackUri);
      debugPrint('[AuthCallback] manual exchange succeeded');
    } catch (e) {
      debugPrint('[AuthCallback] manual exchange FAILED: $e');
    }
    if (!_handled && mounted) {
      _handled = true;
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
