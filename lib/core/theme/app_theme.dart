// lib/core/theme/app_theme.dart
//
// Aura ThemeData — Obsidian + Gold (always dark)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // App은 항상 dark. light()는 호환용으로 dark()와 동일 반환.
  static ThemeData light() => _buildTheme(Brightness.dark);
  static ThemeData dark()  => _buildTheme(Brightness.dark);
}

ThemeData _buildTheme(Brightness brightness) {
  const isDark = true;

  // ── ColorScheme ───────────────────────────────────────────────────────────
  final base = ColorScheme.fromSeed(
    seedColor: AppColors.gold,
    brightness: Brightness.dark,
  );

  final colorScheme = base.copyWith(
    primary:   AppColors.gold,
    onPrimary: AppColors.bg0,
    secondary: AppColors.goldLight,
    onSecondary: AppColors.bg0,
    surface:   AppColors.bg1,
    onSurface: AppColors.ivory,
    surfaceContainer:         AppColors.bg2,
    surfaceContainerHighest:  AppColors.bg3,
    outline:        AppColors.hair,
    outlineVariant: AppColors.hair2,
    error:          AppColors.danger,
    scrim:          const Color(0x99000000),
    brightness: Brightness.dark,
  );

  // ── Typography (Noto Sans KR) ─────────────────────────────────────────────
  final baseText = GoogleFonts.notoSansKrTextTheme(
    ThemeData(brightness: Brightness.dark).textTheme,
  );

  const onSurface = AppColors.ivory;
  const onMuted   = AppColors.ivoryMid;
  const onSubtle  = AppColors.ivoryDim;

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
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.bg1,
    canvasColor: AppColors.bg1,
    splashFactory: InkRipple.splashFactory,
    textTheme: textTheme,
    primaryTextTheme: textTheme,

    cardTheme: const CardThemeData(
      color: AppColors.bg2,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.xs)),
        side: BorderSide(color: AppColors.hair, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg1,
      foregroundColor: AppColors.ivory,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: AppColors.ivory, fontWeight: FontWeight.w500, letterSpacing: 0.5,
      ),
      iconTheme: const IconThemeData(color: AppColors.ivory, size: 22),
      actionsIconTheme: const IconThemeData(color: AppColors.ivoryMid, size: 22),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.goldDeep.withValues(alpha: 0.4);
          }
          return AppColors.gold;
        }),
        foregroundColor: WidgetStateProperty.all(AppColors.bg0),
        overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
        minimumSize: WidgetStateProperty.all(const Size(0, 52)),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        ),
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.xs)),
          ),
        ),
        textStyle: WidgetStateProperty.all(
          textTheme.labelLarge?.copyWith(
            fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5,
          ),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        minimumSize: const Size(0, 52),
        side: BorderSide(
          color: AppColors.hair,
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
      backgroundColor: AppColors.bg3,
      selectedColor: AppColors.gold.withValues(alpha: 0.2),
      disabledColor: AppColors.bg2,
      labelStyle: textTheme.labelMedium!,
      secondaryLabelStyle: textTheme.labelMedium!.copyWith(color: AppColors.gold),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
        side: BorderSide(color: AppColors.hair, width: 1),
      ),
      side: BorderSide.none,
      showCheckmark: false,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg2,
      hintStyle: textTheme.bodyMedium?.copyWith(color: onSubtle),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        borderSide: BorderSide(color: AppColors.hair, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
        borderSide: BorderSide(color: colorScheme.error, width: 1),
      ),
    ),

    dividerTheme: const DividerThemeData(color: AppColors.hair, space: 1, thickness: 1),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.bg3,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.bg3,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.ivory),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
      ),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.gold,
      linearTrackColor: AppColors.gold.withValues(alpha: 0.16),
      circularTrackColor: AppColors.gold.withValues(alpha: 0.16),
    ),

    extensions: const <ThemeExtension<dynamic>>[AuraColors.dark],
  );
}
