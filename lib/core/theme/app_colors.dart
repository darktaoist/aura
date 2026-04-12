import 'package:flutter/material.dart';

/// Aura 브랜드 색상 토큰
class AppColors {
  // 시드 컬러
  static const Color seed = Color(0xFF6B5CE7);
  static const Color seedDark = Color(0xFF8B7CF8);

  // 그라데이션
  static const Color gradStart = Color(0xFF6B5CE7);
  static const Color gradEnd = Color(0xFF4EA8DE);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [gradStart, gradEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 카메라 오버레이 전용 (하드코딩 허용 영역)
  static const Color overlayMesh = Color(0x4000FF88);   // greenAccent 25%
  static const Color overlayKeyPoint = Color(0xFFFF4F4F); // 핵심 17점
  static const Color overlayKeyLabel = Color(0xFFFFEB3B); // 레이블
  static const Color overlayStatusBg = Color(0x80000000); // 상태 배너 배경

  AppColors._();
}

/// 간격 토큰
class AppSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;

  AppSpacing._();
}

/// 반경 토큰
class AppRadius {
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 24.0;
  static const double full = 100.0;

  AppRadius._();
}

/// 애니메이션 토큰
class AppDuration {
  static const Duration transitionPage  = Duration(milliseconds: 300);
  static const Duration transitionCard  = Duration(milliseconds: 200);
  static const Duration overlayFade     = Duration(milliseconds: 150);
  static const Duration streamCursor    = Duration(milliseconds: 800);
  static const Duration progressUpdate  = Duration(milliseconds: 100);

  AppDuration._();
}
