import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/landmark_result.dart';
import '../../domain/entities/palm_result.dart';
import '../../features/auth/auth_callback_page.dart';
import '../../features/auth/auth_page.dart';
import '../../features/consultation/analysis_picker_screen.dart';
import '../../features/consultation/consultation_chat_screen.dart';
import '../../features/consultation/consultation_list_screen.dart';
import '../../features/face_reading/camera/face_camera_page.dart';
import '../../features/face_reading/result/face_result_page.dart';
import '../../features/history/history_page.dart';
import '../../features/home/home_page.dart';
import '../../features/language_select/language_select_page.dart';
import '../../features/model_setup/model_setup_screen.dart';
import '../../features/palm_reading/camera/palm_camera_page.dart';
import '../../features/palm_reading/result/palm_result_page.dart';
import '../../features/policy/privacy_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/terms/terms_page.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // OAuth 콜백: io.supabase.gwansang://login-callback/?code=...
      // go_router는 host=login-callback, path=/ 로 파싱 → 수동 리다이렉트
      final uri = state.uri;
      final code = uri.queryParameters['code'];
      if (code != null &&
          (uri.host == 'login-callback' ||
              uri.toString().contains('login-callback'))) {
        return '/login-callback?code=${Uri.encodeComponent(code)}';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: '/model_setup',
        builder: (context, __) => ModelSetupScreen(
          onComplete: () => GoRouter.of(context).go('/home'),
        ),
      ),
      GoRoute(
        path: '/language_select',
        builder: (_, __) => const LanguageSelectPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'];
          return AuthPage(returnPath: from);
        },
      ),
      GoRoute(
        path: '/login-callback',
        builder: (_, state) => AuthCallbackPage(callbackUri: state.uri),
      ),
      GoRoute(
        path: '/face/camera',
        builder: (_, __) => const FaceCameraPage(),
      ),
      GoRoute(
        path: '/face/result',
        builder: (context, state) {
          // extra가 없거나 잘못된 타입이면 카메라로 돌아감
          if (state.extra is! FaceLandmarkResult) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('분석 데이터가 없습니다'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => GoRouter.of(context).go('/face/camera'),
                      child: const Text('다시 촬영'),
                    ),
                  ],
                ),
              ),
            );
          }
          return FaceResultPage(result: state.extra! as FaceLandmarkResult);
        },
      ),
      GoRoute(
        path: '/palm/camera',
        builder: (_, __) => const PalmCameraPage(),
      ),
      GoRoute(
        path: '/palm/result',
        builder: (context, state) {
          if (state.extra is! PalmLandmarkResult) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('분석 데이터가 없습니다'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => GoRouter.of(context).go('/palm/camera'),
                      child: const Text('다시 촬영'),
                    ),
                  ],
                ),
              ),
            );
          }
          return PalmResultPage(result: state.extra! as PalmLandmarkResult);
        },
      ),
      GoRoute(
        path: '/history',
        builder: (_, __) => const HistoryPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsPage(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (_, __) => const PrivacyPage(),
      ),
      GoRoute(
        path: '/terms',
        builder: (_, __) => const TermsPage(),
      ),
      GoRoute(
        path: '/consultation',
        builder: (_, __) => const ConsultationListScreen(),
      ),
      GoRoute(
        path: '/consultation/picker',
        builder: (_, __) => const AnalysisPickerScreen(),
      ),
      GoRoute(
        path: '/consultation/:id',
        builder: (_, state) => ConsultationChatScreen(
          consultationId: state.pathParameters['id']!,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('페이지를 찾을 수 없습니다: ${state.uri}')),
    ),
  );
}
