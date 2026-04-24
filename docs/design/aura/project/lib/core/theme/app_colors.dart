// lib/core/theme/app_colors.dart
//
// Aura 디자인 시스템 — 컬러 토큰 (확장본)
// ─────────────────────────────────────────────────────────────────────────────
// 변경 요약
// • surface 계층 3단계 (surface / surfaceContainer / surfaceContainerHighest)
//   를 Light·Dark 양쪽에 정의
// • 섹션 accent 6종 (forehead·eyes·nose·mouth·chin·overall) — 채도 차이 최소,
//   브랜드 보라 기반 유사색 조합
// • card border, subtle shadow, glow(스트리밍 인디케이터용) 토큰 추가
// • 기존 seed / gradient 토큰은 그대로 보존
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ───────────────────────────────────────────────────────────────────────────
  // 1. Brand seed & gradient (기존 유지)
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

  /// 카드·히어로 배경에 쓰는 아주 옅은 브랜드 워시 (2~4% opacity).
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
  // 2. Surface tiers — Light
  // ───────────────────────────────────────────────────────────────────────────
  //  surface                  : 최하위 배경 (Scaffold)
  //  surfaceContainer         : 기본 카드 배경
  //  surfaceContainerHighest  : 강조 카드 / 선택 상태 / 입력 필드
  //
  //  L* (oklch lightness) 차이 ~2-3%씩만 두어 계단식 리듬을 만듦.
  // ───────────────────────────────────────────────────────────────────────────
  static const Color surfaceLight                 = Color(0xFFFDFCFF);
  static const Color surfaceContainerLight        = Color(0xFFF7F5FB);
  static const Color surfaceContainerHighestLight = Color(0xFFEFEBF4);

  // Surface tiers — Dark
  static const Color surfaceDark                  = Color(0xFF0F0E13);
  static const Color surfaceContainerDark         = Color(0xFF17161D);
  static const Color surfaceContainerHighestDark  = Color(0xFF1F1D27);

  // ───────────────────────────────────────────────────────────────────────────
  // 3. Card border & subtle shadow
  // ───────────────────────────────────────────────────────────────────────────
  /// 카드 1px border. elevation을 대체하는 hair-line.
  static const Color cardBorderLight = Color(0x14000000); // black @ 8%
  static const Color cardBorderDark  = Color(0x1FFFFFFF); // white @ 12%

  /// 강조 카드 border (예: 선택 상태, 현재 스트리밍 중 섹션).
  static const Color cardBorderAccentLight = Color(0x336B5CE7); // seed @ 20%
  static const Color cardBorderAccentDark  = Color(0x4D8B7CF8); // seedDark @ 30%

  /// 카드 아래로 깔리는 아주 얇은 그림자.
  static const Color cardShadowLight = Color(0x0F1A1533); // deep violet @ 6%
  static const Color cardShadowDark  = Color(0x66000000); // black @ 40%

  /// Scrim / overlay 배경 (BottomSheet, 모달).
  static const Color scrimLight = Color(0x661A1533);
  static const Color scrimDark  = Color(0x99000000);

  // ───────────────────────────────────────────────────────────────────────────
  // 4. Glow — streaming / AI activity indicators
  // ───────────────────────────────────────────────────────────────────────────
  /// 스트리밍 중 카드 테두리에 숨 쉬듯 퍼지는 glow.
  static const Color glowLight = Color(0x406B5CE7); // seed @ 25%
  static const Color glowDark  = Color(0x668B7CF8); // seedDark @ 40%

  /// AI 타이핑 dot / 커서 색.
  static const Color aiPulseLight = Color(0xFF6B5CE7);
  static const Color aiPulseDark  = Color(0xFF8B7CF8);

  // ───────────────────────────────────────────────────────────────────────────
  // 5. Section accents (관상 6섹션)
  // ───────────────────────────────────────────────────────────────────────────
  // oklch(0.62 0.12 H) 계열로 통일 — 채도/명도 동일, 색상(hue)만 5~15도씩 이동
  // 무지개처럼 튀지 않고, 브랜드 보라를 중심으로 한 "harmonic neighbors"
  // ───────────────────────────────────────────────────────────────────────────
  static const Color sectionForehead = Color(0xFF7A6CEB); // H ~ 285 (보라)
  static const Color sectionEyes     = Color(0xFF6B7BE8); // H ~ 265 (보라-블루)
  static const Color sectionNose     = Color(0xFF5E89DD); // H ~ 245 (블루)
  static const Color sectionMouth    = Color(0xFF6F77D4); // H ~ 275 (인디고)
  static const Color sectionChin     = Color(0xFF8470D9); // H ~ 295 (라일락)
  static const Color sectionOverall  = Color(0xFF6B5CE7); // seed와 동일

  /// 섹션 accent 맵 — 키는 리포트 섹션 id와 1:1.
  static const Map<String, Color> sectionAccents = <String, Color>{
    'forehead': sectionForehead,
    'eyes'    : sectionEyes,
    'nose'    : sectionNose,
    'mouth'   : sectionMouth,
    'chin'    : sectionChin,
    'overall' : sectionOverall,
  };

  /// 섹션 아이콘 배경용 연한 wash (accent @ 12% opacity).
  static Color sectionWash(Color accent) => accent.withOpacity(0.12);

  /// 섹션 라벨(overline) 용 — accent를 살짝 어둡게.
  static Color sectionLabel(Color accent, {bool dark = false}) =>
      dark
          ? Color.alphaBlend(Colors.white.withOpacity(0.15), accent)
          : Color.alphaBlend(Colors.black.withOpacity(0.20), accent);

  // ───────────────────────────────────────────────────────────────────────────
  // 6. Semantic — success / warning / danger (보조)
  // ───────────────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF3FB27F);
  static const Color warning = Color(0xFFE0A020);
  static const Color danger  = Color(0xFFE05A6B);

  // ───────────────────────────────────────────────────────────────────────────
  // 7. On-surface text tiers
  // ───────────────────────────────────────────────────────────────────────────
  static const Color onSurfaceLight         = Color(0xFF1A1533);
  static const Color onSurfaceMutedLight    = Color(0xFF5A5470);
  static const Color onSurfaceSubtleLight   = Color(0xFF8E89A2);

  static const Color onSurfaceDark          = Color(0xFFEDEAF5);
  static const Color onSurfaceMutedDark     = Color(0xFFB3AEC6);
  static const Color onSurfaceSubtleDark    = Color(0xFF7E7A90);
}

// ═════════════════════════════════════════════════════════════════════════════
// ThemeExtension — ThemeData에 얹어서 Theme.of(context).extension<...>() 로
// 접근 가능하게 한다. Material의 ColorScheme가 커버하지 못하는 Aura 고유
// 토큰(섹션 accent, glow, card border 등)을 담는다.
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

// ═════════════════════════════════════════════════════════════════════════════
// 편의 extension — context.auraColors 로 짧게 접근
// ═════════════════════════════════════════════════════════════════════════════
extension AuraColorsX on BuildContext {
  AuraColors get auraColors =>
      Theme.of(this).extension<AuraColors>() ?? AuraColors.light;
}
