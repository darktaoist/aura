// lib/core/theme/app_colors.dart
//
// Aura 디자인 시스템 — Obsidian + Gold Leaf 팔레트
// design source: claude.ai/design → aura/project/src/tokens.jsx
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Obsidian surface layers (warm-cool tilt) ──────────────────────────────
  static const Color bg0 = Color(0xFF07060B); // deepest
  static const Color bg1 = Color(0xFF0D0B14); // page base
  static const Color bg2 = Color(0xFF141120); // card base
  static const Color bg3 = Color(0xFF1B1729); // elevated card
  static const Color bg4 = Color(0xFF24202F); // modals / sheets

  // ── Gold family — antique, desaturated ───────────────────────────────────
  static const Color gold      = Color(0xFFC9A449);
  static const Color goldLight = Color(0xFFE6C877);
  static const Color goldDeep  = Color(0xFF8E6F2C);
  static const Color goldGlow  = Color(0x59C9A449); // 35% opacity

  // Gold hairline borders
  static const Color hair  = Color(0x2EC9A449); // 18% gold
  static const Color hair2 = Color(0x14F4E9D0); // 8% ivory

  // ── Ivory foreground family ───────────────────────────────────────────────
  static const Color ivory      = Color(0xFFF4E9D0);
  static const Color ivoryMid   = Color(0xFFC8BFA6);
  static const Color ivoryDim   = Color(0xFF8A8476);
  static const Color ivoryFaint = Color(0xFF5A5548);

  // ── Per-reading accent (subtle) ───────────────────────────────────────────
  static const Color face = Color(0xFFB49A6E); // muted sand — 관상
  static const Color palm = Color(0xFF6E8C7A); // faded jade — 손금
  static const Color chat = Color(0xFF8A6EA0); // ink violet — 상담

  // ── Section accent (result tabs) ─────────────────────────────────────────
  static const Color sectionOverall  = Color(0xFFC9A449);
  static const Color sectionForehead = Color(0xFFD4A854);
  static const Color sectionEyes     = Color(0xFFB5A87E);
  static const Color sectionNose     = Color(0xFF9EAB8C);
  static const Color sectionMouth    = Color(0xFFA89070);
  static const Color sectionChin     = Color(0xFF7B9490);

  static const Map<String, Color> sectionAccents = {
    'overall'  : sectionOverall,
    'forehead' : sectionForehead,
    'eyes'     : sectionEyes,
    'nose'     : sectionNose,
    'mouth'    : sectionMouth,
    'chin'     : sectionChin,
  };

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color ok      = Color(0xFF86A77E);
  static const Color success = ok; // legacy alias
  static const Color danger  = Color(0xFFC56B52);
  static const Color warning = Color(0xFFD4A027);

  // ── Section wash helper ───────────────────────────────────────────────────
  static Color sectionWash(Color accent) =>
      accent.withValues(alpha: 0.08);

  // ── Camera overlay ────────────────────────────────────────────────────────
  static const Color overlayMesh     = Color(0x40C9A449);
  static const Color overlayKeyPoint = Color(0xFFC9A449);
  static const Color overlayKeyLabel = Color(0xFFE6C877);
  static const Color overlayStatusBg = Color(0x80000000);

  // ── Legacy aliases (backward compat) ─────────────────────────────────────
  static const Color seed     = gold;
  static const Color seedDark = goldLight;
  static const LinearGradient brandGradient = LinearGradient(
    colors: [goldLight, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF50), Color(0xFF8E6F2C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy surface aliases
  static const Color surfaceDark                  = bg1;
  static const Color surfaceContainerDark         = bg2;
  static const Color surfaceContainerHighestDark  = bg3;
  static const Color surfaceLight                 = bg1;
  static const Color surfaceContainerLight        = bg2;
  static const Color surfaceContainerHighestLight = bg3;
  static const Color cardBorderLight              = hair;
  static const Color cardBorderDark               = hair;
  static const Color cardBorderAccentLight        = Color(0x59C9A449);
  static const Color cardBorderAccentDark         = Color(0x59C9A449);
  static const Color cardShadowLight              = Color(0x66000000);
  static const Color cardShadowDark               = Color(0x66000000);
  static const Color scrimLight                   = Color(0x99000000);
  static const Color scrimDark                    = Color(0x99000000);
  static const Color glowLight                    = goldGlow;
  static const Color glowDark                     = goldGlow;
  static const Color aiPulseLight                 = gold;
  static const Color aiPulseDark                  = gold;
  static const LinearGradient brandWashLight = LinearGradient(
    colors: [Color(0x33C9A449), Color(0x1A8E6F2C)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient brandWashDark = brandWashLight;
  static const Color onSurfaceMutedLight   = ivoryMid;
  static const Color onSurfaceMutedDark    = ivoryMid;
  static const Color onSurfaceSubtleLight  = ivoryDim;
  static const Color onSurfaceSubtleDark   = ivoryDim;
  static const Color onSurfaceLight        = ivory;
  static const Color onSurfaceDark         = ivory;
}

// ═════════════════════════════════════════════════════════════════════════════
// AuraColors — ThemeExtension
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

  static const AuraColors dark = AuraColors(
    surfaceContainer:        AppColors.bg2,
    surfaceContainerHighest: AppColors.bg3,
    cardBorder:              AppColors.hair,
    cardBorderAccent:        Color(0x59C9A449),
    cardShadow:              Color(0x66000000),
    glow:                    AppColors.goldGlow,
    aiPulse:                 AppColors.gold,
    brandWash: LinearGradient(
      colors: [Color(0x33C9A449), Color(0x1A8E6F2C)],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
    onSurfaceMuted:  AppColors.ivoryMid,
    onSurfaceSubtle: AppColors.ivoryDim,
    sectionAccents:  AppColors.sectionAccents,
  );
  static const AuraColors light = dark;

  @override
  AuraColors copyWith({
    Color? surfaceContainer, Color? surfaceContainerHighest,
    Color? cardBorder, Color? cardBorderAccent, Color? cardShadow,
    Color? glow, Color? aiPulse, LinearGradient? brandWash,
    Color? onSurfaceMuted, Color? onSurfaceSubtle,
    Map<String, Color>? sectionAccents,
  }) => AuraColors(
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

extension AuraColorsX on BuildContext {
  AuraColors get auraColors =>
      Theme.of(this).extension<AuraColors>() ?? AuraColors.dark;
}

// ═════════════════════════════════════════════════════════════════════════════
// Layout & animation tokens
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
  static const double xs   = 2.0;
  static const double sm   = 4.0;
  static const double md   = 8.0;
  static const double lg   = 12.0;
  static const double xl   = 16.0;
  static const double pill = 999.0;
  static const double full = pill; // legacy alias
}

class AppDuration {
  AppDuration._();
  static const Duration transitionPage = Duration(milliseconds: 600);
  static const Duration transitionCard = Duration(milliseconds: 500);
  static const Duration overlayFade    = Duration(milliseconds: 300);
  static const Duration streamCursor   = Duration(milliseconds: 800);
  static const Duration progressUpdate = Duration(milliseconds: 100);
  static const Duration ceremonial     = Duration(milliseconds: 900);
}
