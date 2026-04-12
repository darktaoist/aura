import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(supabaseClientProvider));

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Google OAuth (Supabase 네이티브 지원)
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.gwansang://login-callback/',
    );
  }

  /// Kakao 인증: SDK → access token → Edge Function kakao-auth → Supabase JWT
  Future<void> signInWithKakao() async {
    try {
      // 1. Kakao 로그인 → access token 획득
      kakao.OAuthToken token;
      if (await kakao.isKakaoTalkInstalled()) {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 2. Edge Function 호출: kakao-auth
      final response = await _client.functions.invoke(
        'kakao-auth',
        body: {'access_token': token.accessToken},
      );

      if (response.status != 200) {
        throw Exception('Kakao auth failed: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;

      // 3. Supabase 세션 설정 (refresh token 기반)
      //    Edge Function은 {access_token, refresh_token} 반환
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;

      if (accessToken == null || refreshToken == null) {
        throw Exception('kakao-auth: missing token fields');
      }

      await _client.auth.setSession(refreshToken);
    } catch (e) {
      debugPrint('[AuthRepository] Kakao sign-in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// 회원 탈퇴: Edge Function delete-account 호출 (service_role 서버측 전용)
  Future<void> deleteAccount() async {
    final uid = currentUser?.id;
    if (uid == null) return;

    final response = await _client.functions.invoke('delete-account');

    if (response.status != 200) {
      final err = (response.data as Map<String, dynamic>?)?['error'] ?? 'Unknown error';
      throw Exception('Account deletion failed: $err');
    }

    // 로컬 세션 정리
    await _client.auth.signOut();
  }
}
