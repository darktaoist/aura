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
      // KakaoTalk 로그인 실패 시 카카오계정(웹) 로그인으로 자동 폴백
      kakao.OAuthToken token;
      if (await kakao.isKakaoTalkInstalled()) {
        try {
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
        } catch (e) {
          debugPrint('[AuthRepository] KakaoTalk login failed, fallback to web: $e');
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 2. Edge Function 호출: kakao-auth
      // supabase_flutter FunctionsClient가 자동으로 anon key Authorization 헤더를 설정함
      final response = await _client.functions.invoke(
        'kakao-auth',
        body: {'access_token': token.accessToken},
      );

      if (response.status != 200) {
        throw Exception('Kakao auth failed: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;

      // 3. Supabase 세션 설정: generateLink의 email_otp로 verifyOTP
      final email = data['email'] as String?;
      final otpToken = data['token'] as String?;

      if (email == null || otpToken == null) {
        throw Exception('kakao-auth: missing token fields');
      }

      await _client.auth.verifyOTP(
        email: email,
        token: otpToken,
        type: OtpType.magiclink,
      );
    } catch (e, st) {
      debugPrint('[AuthRepository] Kakao sign-in error: $e\n$st');
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
