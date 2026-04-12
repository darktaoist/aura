import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) =>
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
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
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

      // 3. Supabase 세션 설정
      await _client.auth.setSession(data['access_token'] as String);
    } catch (e) {
      debugPrint('[AuthRepository] Kakao sign-in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// 회원 탈퇴: Storage 이미지 삭제 → Supabase user 삭제 (cascade)
  Future<void> deleteAccount() async {
    final uid = currentUser?.id;
    if (uid == null) return;

    // Storage readings/{uid}/ 폴더 내 파일 목록 조회 및 삭제
    try {
      final files = await _client.storage
          .from('readings')
          .list(path: uid);
      if (files.isNotEmpty) {
        final paths = files.map((f) => '$uid/${f.name}').toList();
        await _client.storage.from('readings').remove(paths);
      }
    } catch (e) {
      debugPrint('[AuthRepository] storage cleanup error: $e');
    }

    await _client.auth.admin.deleteUser(uid);
    await signOut();
  }
}
