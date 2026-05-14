import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/supabase/auth_repository.dart';

part 'auth_notifier.g.dart';

/// supabase_flutter.AuthState 와 이름 충돌을 피하기 위해 AuthUiState 사용
class AuthUiState {
  const AuthUiState({this.user, this.isLoading = false, this.error});

  final User? user;
  final bool isLoading;
  final String? error;

  bool get isLoggedIn => user != null;

  AuthUiState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) =>
      AuthUiState(
        user: clearUser ? null : user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthUiState build() {
    final repo = ref.watch(authRepositoryProvider);

    // authStateChanges 구독 — ref.onDispose로 반드시 해제
    final sub = repo.authStateChanges.listen(
      (event) {
        // tokenRefreshed 이벤트는 user 변경 없으므로 무시
        if (event.event == AuthChangeEvent.tokenRefreshed) return;

        state = state.copyWith(
          user: event.session?.user,
          clearUser: event.session == null,
          clearError: true,
          isLoading: false, // 어떤 auth 이벤트든 로딩 종료
        );
      },
      onError: (Object e, StackTrace st) {
        // Supabase SDK가 notifyException으로 스트림에 에러를 추가할 때 처리
        // onError 없으면 Unhandled Exception으로 앱 크래시 발생
        debugPrint('[AuthNotifier] authStateChanges error: $e');
        state = state.copyWith(isLoading: false, error: e.toString());
      },
    );
    ref.onDispose(sub.cancel);

    // OAuth 브라우저에서 돌아왔을 때 isLoading stuck 방지:
    // 외부 브라우저(Google OAuth)를 닫고 앱으로 복귀하면 resumed 이벤트가 발생한다.
    // supabase_flutter가 딥링크를 자동 처리하면 authStateChanges 가 발생하고 isLoading 해제됨.
    // 딥링크 없이 복귀(사용자 취소)한 경우엔 2초 대기 후 isLoading 강제 해제.
    final observer = _ResumeObserver(() {
      if (!state.isLoading) return;
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (state.isLoading && state.user == null) {
          debugPrint('[AuthNotifier] resumed without session — clearing isLoading');
          state = state.copyWith(isLoading: false);
        }
      });
    });
    WidgetsBinding.instance.addObserver(observer);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(observer));

    return AuthUiState(user: repo.currentUser);
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      // 세션은 authStateChanges 리스너에서 수신 → isLoading 자동 해제
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithKakao() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).signInWithKakao();
      // authStateChanges 리스너에서 user 설정 및 isLoading 해제
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthUiState();
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      state = const AuthUiState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

class _ResumeObserver extends WidgetsBindingObserver {
  _ResumeObserver(this.onResumed);
  final VoidCallback onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResumed();
  }
}
