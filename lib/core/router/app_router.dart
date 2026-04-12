import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/landmark_result.dart';
import '../../features/auth/auth_page.dart';
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
        builder: (_, __) => const PalmResultPage(),
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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('페이지를 찾을 수 없습니다: ${state.uri}')),
    ),
  );
}
