// lib/core/theme/app_colors.dart
//
// Aura 디자인 시스템 — 컬러·간격·반경·애니메이션 토큰
// ─────────────────────────────────────────────────────────────────────────────
// • AppColors        : 브랜드/surface/border/shadow/glow/section accents 등
// • AuraColors       : Material ColorScheme가 커버하지 못하는 Aura 고유 토큰
//                      ThemeExtension. context.auraColors 로 접근.
// • AppSpacing/Radius/Duration : 레이아웃·애니메이션 수치 토큰 (기존 유지)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ───────────────────────────────────────────────────────────────────────────
  // 1. Brand seed & gradients
  // ───────────────────────────────────────────────────────────────────────────
  static const Color seed     = Color(0xFF6B5CE7);
  static const Color seedDark = Color(0xFF8B7CF8);

  static const Color gradStart = Color(0xFF6B5CE7);
  static const Color gradEnd   = Color(0xFF4EA8DE);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [gradStart, gradEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 카드·히어로 배경에 쓰는 아주 옅은 브랜드 워시.
  static const LinearGradient brandWashLight = LinearGradient(
    colors: [Color(0x146B5CE7), Color(0x0A4EA8DE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient brandWashDark = LinearGradient(
    colors: [Color(0x338B7CF8), Color(0x1A4EA8DE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ───────────────────────────────────────────────────────────────────────────
  // 2. Surface tiers (Light / Dark)
  //    surface < surfaceContainer < surfaceContainerHighest (L* 2~3%씩 차이)
  // ───────────────────────────────────────────────────────────────────────────
  static const Color surfaceLight                 = Color(0xFFFDFCFF);
  static const Color surfaceContainerLight        = Color(0xFFF7F5FB);
  static const Color surfaceContainerHighestLight = Color(0xFFEFEBF4);

  static const Color surfaceDark                  = Color(0xFF0F0E13);
  static const Color surfaceContainerDark         = Color(0xFF17161D);
  static const Color surfaceContainerHighestDark  = Color(0xFF1F1D27);

  // ───────────────────────────────────────────────────────────────────────────
  // 3. Card border & shadow (elevation 대체)
  // ───────────────────────────────────────────────────────────────────────────
  static const Color cardBorderLight       = Color(0x14000000); // black 8%
  static const Color cardBorderDark        = Color(0x1FFFFFFF); // white 12%
  static const Color cardBorderAccentLight = Color(0x336B5CE7); // seed 20%
  static const Color cardBorderAccentDark  = Color(0x4D8B7CF8); // seedDark 30%

  static const Color cardShadowLight = Color(0x0F1A1533); // deep violet 6%
  static const Color cardShadowDark  = Color(0x66000000); // black 40%

  static const Color scrimLight = Color(0x661A1533);
  static const Color scrimDark  = Color(0x99000000);

  // ───────────────────────────────────────────────────────────────────────────
  // 4. Glow / AI pulse (스트리밍·타이핑 인디케이터)
  // ───────────────────────────────────────────────────────────────────────────
  static const Color glowLight    = Color(0x406B5CE7); // seed 25%
  static const Color glowDark     = Color(0x668B7CF8); // seedDark 40%
  static const Color aiPulseLight = Color(0xFF6B5CE7);
  static const Color aiPulseDark  = Color(0xFF8B7CF8);

  // ───────────────────────────────────────────────────────────────────────────
  // 5. Section accents — 관상 6섹션 (harmonic neighbors of seed)
  //    oklch(0.62 0.12 H) 계열로 통일, hue만 5~15도씩 이동
  // ───────────────────────────────────────────────────────────────────────────
  static const Color sectionForehead = Color(0xFF7A6CEB); // 보라
  static const Color sectionEyes     = Color(0xFF6B7BE8); // 보라-블루
  static const Color sectionNose     = Color(0xFF5E89DD); // 블루
  static const Color sectionMouth    = Color(0xFF6F77D4); // 인디고
  static const Color sectionChin     = Color(0xFF8470D9); // 라일락
  static const Color sectionOverall  = Color(0xFF6B5CE7); // seed

  static const Map<String, Color> sectionAccents = <String, Color>{
    'forehead': sectionForehead,
    'eyes'    : sectionEyes,
    'nose'    : sectionNose,
    'mouth'   : sectionMouth,
    'chin'    : sectionChin,
    'overall' : sectionOverall,
  };

  /// 섹션 아이콘 배경용 연한 wash (accent @ 12% opacity).
  static Color sectionWash(Color accent) => accent.withValues(alpha: 0.12);

  /// 섹션 라벨(overline) 용 — accent를 살짝 명암 조정.
  static Color sectionLabel(Color accent, {bool dark = false}) => dark
      ? Color.alphaBlend(Colors.white.withValues(alpha: 0.15), accent)
      : Color.alphaBlend(Colors.black.withValues(alpha: 0.20), accent);

  // ───────────────────────────────────────────────────────────────────────────
  // 6. Semantic — success / warning / danger
  // ───────────────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF3FB27F);
  static const Color warning = Color(0xFFE0A020);
  static const Color danger  = Color(0xFFE05A6B);

  // ───────────────────────────────────────────────────────────────────────────
  // 7. On-surface text tiers
  // ───────────────────────────────────────────────────────────────────────────
  static const Color onSurfaceLight       = Color(0xFF1A1533);
  static const Color onSurfaceMutedLight  = Color(0xFF5A5470);
  static const Color onSurfaceSubtleLight = Color(0xFF8E89A2);

  static const Color onSurfaceDark        = Color(0xFFEDEAF5);
  static const Color onSurfaceMutedDark   = Color(0xFFB3AEC6);
  static const Color onSurfaceSubtleDark  = Color(0xFF7E7A90);

  // ───────────────────────────────────────────────────────────────────────────
  // 8. Camera overlay (기존 유지)
  // ───────────────────────────────────────────────────────────────────────────
  static const Color overlayMesh     = Color(0x4000FF88); // greenAccent 25%
  static const Color overlayKeyPoint = Color(0xFFFF4F4F); // 핵심 랜드마크
  static const Color overlayKeyLabel = Color(0xFFFFEB3B); // 레이블
  static const Color overlayStatusBg = Color(0x80000000); // 상태 배너 배경
}

// ═════════════════════════════════════════════════════════════════════════════
// AuraColors — ThemeExtension. Material ColorScheme가 커버하지 못하는
// 섹션 accent, glow, card border 등 Aura 고유 토큰을 담는다.
// 접근: `context.auraColors.xxx`
// ═════════════════════════════════════════════════════════════════════════════
class AuraColors extends ThemeExtension<AuraColors> {
  const AuraColors({
    required this.surfaceContainer,
    required this.surfaceContainerHighest,
    required this.cardBorder,
    required this.cardBorderAccent,
    required this.cardShadow,
    required this.glow,
    required this.aiPulse,
    required this.brandWash,
    required this.onSurfaceMuted,
    required this.onSurfaceSubtle,
    required this.sectionAccents,
  });

  final Color surfaceContainer;
  final Color surfaceContainerHighest;
  final Color cardBorder;
  final Color cardBorderAccent;
  final Color cardShadow;
  final Color glow;
  final Color aiPulse;
  final LinearGradient brandWash;
  final Color onSurfaceMuted;
  final Color onSurfaceSubtle;
  final Map<String, Color> sectionAccents;

  static const AuraColors light = AuraColors(
    surfaceContainer:        AppColors.surfaceContainerLight,
    surfaceContainerHighest: AppColors.surfaceContainerHighestLight,
    cardBorder:              AppColors.cardBorderLight,
    cardBorderAccent:        AppColors.cardBorderAccentLight,
    cardShadow:              AppColors.cardShadowLight,
    glow:                    AppColors.glowLight,
    aiPulse:                 AppColors.aiPulseLight,
    brandWash:               AppColors.brandWashLight,
    onSurfaceMuted:          AppColors.onSurfaceMutedLight,
    onSurfaceSubtle:         AppColors.onSurfaceSubtleLight,
    sectionAccents:          AppColors.sectionAccents,
  );

  static const AuraColors dark = AuraColors(
    surfaceContainer:        AppColors.surfaceContainerDark,
    surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
    cardBorder:              AppColors.cardBorderDark,
    cardBorderAccent:        AppColors.cardBorderAccentDark,
    cardShadow:              AppColors.cardShadowDark,
    glow:                    AppColors.glowDark,
    aiPulse:                 AppColors.aiPulseDark,
    brandWash:               AppColors.brandWashDark,
    onSurfaceMuted:          AppColors.onSurfaceMutedDark,
    onSurfaceSubtle:         AppColors.onSurfaceSubtleDark,
    sectionAccents:          AppColors.sectionAccents,
  );

  @override
  AuraColors copyWith({
    Color? surfaceContainer,
    Color? surfaceContainerHighest,
    Color? cardBorder,
    Color? cardBorderAccent,
    Color? cardShadow,
    Color? glow,
    Color? aiPulse,
    LinearGradient? brandWash,
    Color? onSurfaceMuted,
    Color? onSurfaceSubtle,
    Map<String, Color>? sectionAccents,
  }) {
    return AuraColors(
      surfaceContainer:        surfaceContainer        ?? this.surfaceContainer,
      surfaceContainerHighest: surfaceContainerHighest ?? this.surfaceContainerHighest,
      cardBorder:              cardBorder              ?? this.cardBorder,
      cardBorderAccent:        cardBorderAccent        ?? this.cardBorderAccent,
      cardShadow:              cardShadow              ?? this.cardShadow,
      glow:                    glow                    ?? this.glow,
      aiPulse:                 aiPulse                 ?? this.aiPulse,
      brandWash:               brandWash               ?? this.brandWash,
      onSurfaceMuted:          onSurfaceMuted          ?? this.onSurfaceMuted,
      onSurfaceSubtle:         onSurfaceSubtle         ?? this.onSurfaceSubtle,
      sectionAccents:          sectionAccents          ?? this.sectionAccents,
    );
  }

  @override
  AuraColors lerp(ThemeExtension<AuraColors>? other, double t) {
    if (other is! AuraColors) return this;
    return AuraColors(
      surfaceContainer:        Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerHighest: Color.lerp(surfaceContainerHighest, other.surfaceContainerHighest, t)!,
      cardBorder:              Color.lerp(cardBorder, other.cardBorder, t)!,
      cardBorderAccent:        Color.lerp(cardBorderAccent, other.cardBorderAccent, t)!,
      cardShadow:              Color.lerp(cardShadow, other.cardShadow, t)!,
      glow:                    Color.lerp(glow, other.glow, t)!,
      aiPulse:                 Color.lerp(aiPulse, other.aiPulse, t)!,
      brandWash:               LinearGradient.lerp(brandWash, other.brandWash, t)!,
      onSurfaceMuted:          Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      onSurfaceSubtle:         Color.lerp(onSurfaceSubtle, other.onSurfaceSubtle, t)!,
      sectionAccents:          t < 0.5 ? sectionAccents : other.sectionAccents,
    );
  }
}

/// `context.auraColors` 단축 접근자.
extension AuraColorsX on BuildContext {
  AuraColors get auraColors =>
      Theme.of(this).extension<AuraColors>() ?? AuraColors.light;
}

// ═════════════════════════════════════════════════════════════════════════════
// Layout & animation tokens (기존 유지)
// ═════════════════════════════════════════════════════════════════════════════
class AppSpacing {
  AppSpacing._();
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  AppRadius._();
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 24.0;
  static const double full = 100.0;
}

class AppDuration {
  AppDuration._();
  static const Duration transitionPage = Duration(milliseconds: 300);
  static const Duration transitionCard = Duration(milliseconds: 200);
  static const Duration overlayFade    = Duration(milliseconds: 150);
  static const Duration streamCursor   = Duration(milliseconds: 800);
  static const Duration progressUpdate = Duration(milliseconds: 100);
}
