// lib/core/theme/app_theme.dart
//
// Aura ThemeData — Light / Dark
// ─────────────────────────────────────────────────────────────────────────────
// • google_fonts Noto Sans KR 기반 타이포그래피 (Pretendard fallback)
// • ColorScheme.fromSeed 를 Aura surface 토큰으로 오버라이드
// • CardTheme: elevation 0, 1px border + subtle shadow (elevation 대체)
// • FilledButton/OutlinedButton/IconButton/Chip/Input/BottomSheet/SnackBar 정리
// • AuraColors ThemeExtension 주입 → `context.auraColors` 로 접근
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _buildTheme(Brightness.light);
  static ThemeData dark()  => _buildTheme(Brightness.dark);
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  // ── ColorScheme ───────────────────────────────────────────────────────────
  final base = ColorScheme.fromSeed(
    seedColor: isDark ? AppColors.seedDark : AppColors.seed,
    brightness: brightness,
  );

  final colorScheme = base.copyWith(
    primary:   isDark ? AppColors.seedDark : AppColors.seed,
    onPrimary: Colors.white,
    surface:   isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
    onSurface: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
    surfaceContainer:
        isDark ? AppColors.surfaceContainerDark : AppColors.surfaceContainerLight,
    surfaceContainerHighest: isDark
        ? AppColors.surfaceContainerHighestDark
        : AppColors.surfaceContainerHighestLight,
    outline:        isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
    outlineVariant: isDark ? const Color(0x14FFFFFF) : const Color(0x0A000000),
    error:          AppColors.danger,
    scrim:          isDark ? AppColors.scrimDark : AppColors.scrimLight,
  );

  // ── Typography (Noto Sans KR + Pretendard fallback) ───────────────────────
  final baseText = GoogleFonts.notoSansKrTextTheme(
    ThemeData(brightness: brightness).textTheme,
  );

  final onSurface = colorScheme.onSurface;
  final onMuted   = isDark ? AppColors.onSurfaceMutedDark : AppColors.onSurfaceMutedLight;
  final onSubtle  = isDark ? AppColors.onSurfaceSubtleDark : AppColors.onSurfaceSubtleLight;

  final textTheme = baseText.copyWith(
    // Display — 히어로
    displayLarge: baseText.displayLarge?.copyWith(
      fontSize: 40, height: 1.15, letterSpacing: -0.8,
      fontWeight: FontWeight.w700, color: onSurface,
    ),
    displayMedium: baseText.displayMedium?.copyWith(
      fontSize: 32, height: 1.2, letterSpacing: -0.6,
      fontWeight: FontWeight.w700, color: onSurface,
    ),
    displaySmall: baseText.displaySmall?.copyWith(
      fontSize: 26, height: 1.25, letterSpacing: -0.4,
      fontWeight: FontWeight.w600, color: onSurface,
    ),

    // Headline — 섹션 타이틀
    headlineLarge: baseText.headlineLarge?.copyWith(
      fontSize: 24, height: 1.3, letterSpacing: -0.3,
      fontWeight: FontWeight.w700, color: onSurface,
    ),
    headlineMedium: baseText.headlineMedium?.copyWith(
      fontSize: 20, height: 1.35, letterSpacing: -0.2,
      fontWeight: FontWeight.w600, color: onSurface,
    ),
    headlineSmall: baseText.headlineSmall?.copyWith(
      fontSize: 18, height: 1.4, letterSpacing: -0.1,
      fontWeight: FontWeight.w600, color: onSurface,
    ),

    // Title — 카드 헤더
    titleLarge: baseText.titleLarge?.copyWith(
      fontSize: 17, height: 1.4,
      fontWeight: FontWeight.w600, color: onSurface,
    ),
    titleMedium: baseText.titleMedium?.copyWith(
      fontSize: 15, height: 1.45,
      fontWeight: FontWeight.w600, color: onSurface,
    ),
    titleSmall: baseText.titleSmall?.copyWith(
      fontSize: 13, height: 1.5,
      fontWeight: FontWeight.w600, color: onMuted,
    ),

    // Body — 리포트 본문 (line-height 1.7)
    bodyLarge: baseText.bodyLarge?.copyWith(
      fontSize: 16, height: 1.7, letterSpacing: 0.1,
      fontWeight: FontWeight.w400, color: onSurface,
    ),
    bodyMedium: baseText.bodyMedium?.copyWith(
      fontSize: 14, height: 1.65, letterSpacing: 0.1,
      fontWeight: FontWeight.w400, color: onMuted,
    ),
    bodySmall: baseText.bodySmall?.copyWith(
      fontSize: 12, height: 1.55, letterSpacing: 0.2,
      fontWeight: FontWeight.w400, color: onSubtle,
    ),

    // Label — 버튼 / overline
    labelLarge: baseText.labelLarge?.copyWith(
      fontSize: 14, height: 1.2, letterSpacing: 0.2,
      fontWeight: FontWeight.w600, color: onSurface,
    ),
    labelMedium: baseText.labelMedium?.copyWith(
      fontSize: 12, height: 1.2, letterSpacing: 0.4,
      fontWeight: FontWeight.w600, color: onMuted,
    ),
    labelSmall: baseText.labelSmall?.copyWith(
      // overline
      fontSize: 11, height: 1.2, letterSpacing: 1.2,
      fontWeight: FontWeight.w700, color: onMuted,
    ),
  ).apply(
    fontFamilyFallback: const ['Pretendard', 'NotoSansKR', 'Noto Sans KR'],
  );

  // ── ThemeData ─────────────────────────────────────────────────────────────
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
    splashFactory: InkSparkle.splashFactory,
    textTheme: textTheme,
    primaryTextTheme: textTheme,

    cardTheme: CardThemeData(
      color: isDark ? AppColors.surfaceContainerDark : AppColors.surfaceContainerLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),
      actionsIconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.35),
        disabledForegroundColor: colorScheme.onPrimary.withValues(alpha: 0.8),
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontSize: 15, fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        minimumSize: const Size(0, 52),
        side: BorderSide(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: isDark
          ? AppColors.surfaceContainerHighestDark
          : AppColors.surfaceContainerHighestLight,
      selectedColor: colorScheme.primary.withValues(alpha: 0.12),
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.06),
      labelStyle: textTheme.labelMedium!,
      secondaryLabelStyle: textTheme.labelMedium!.copyWith(color: colorScheme.primary),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: 1,
        ),
      ),
      side: BorderSide.none,
      showCheckmark: false,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? AppColors.surfaceContainerHighestDark
          : AppColors.surfaceContainerHighestLight,
      hintStyle: textTheme.bodyMedium?.copyWith(color: onSubtle),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colorScheme.error, width: 1),
      ),
    ),

    dividerTheme: DividerThemeData(
      color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
      space: 1, thickness: 1,
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark
          ? AppColors.surfaceContainerHighestDark
          : AppColors.onSurfaceLight,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: isDark ? AppColors.onSurfaceDark : Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.primary.withValues(alpha: 0.16),
      circularTrackColor: colorScheme.primary.withValues(alpha: 0.16),
    ),

    // ── Aura 고유 토큰 주입 ────────────────────────────────────────────────
    extensions: <ThemeExtension<dynamic>>[
      isDark ? AuraColors.dark : AuraColors.light,
    ],
  );
}
