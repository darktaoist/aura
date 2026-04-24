// lib/app.dart
//
// Aura 앱 루트 — MaterialApp.router + ThemeData (Light/Dark)
// ─────────────────────────────────────────────────────────────────────────────
// 변경 요약
// • Pretendard(fallback: NotoSansKR) 기반 typography — google_fonts 사용
// • ColorScheme.fromSeed 를 Aura surface 토큰으로 오버라이드 (Light/Dark)
// • CardTheme: elevation=0, 1px outlined border + subtle shadow (Container 래핑)
// • FilledButton / OutlinedButton / AppBar / Input / Chip 기본값 정리
// • AuraColors ThemeExtension 주입 → context.auraColors 로 섹션 accent 접근
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/router/app_router.dart';
import 'l10n/app_localizations.dart';

class AuraApp extends ConsumerWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Aura',
      debugShowCheckedModeBanner: false,

      // ── Theme ────────────────────────────────────────────────────────────
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,

      // ── L10n ─────────────────────────────────────────────────────────────
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // ── Router ───────────────────────────────────────────────────────────
      routerConfig: router,

      builder: (context, child) {
        // 상태바·네비바 색상을 theme 에 맞춰 런타임 주입.
        final brightness = Theme.of(context).brightness;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                brightness == Brightness.light ? Brightness.dark : Brightness.light,
            systemNavigationBarColor:
                Theme.of(context).colorScheme.surface,
            systemNavigationBarIconBrightness:
                brightness == Brightness.light ? Brightness.dark : Brightness.light,
          ),
        );
        // 시스템 폰트 스케일 0.85~1.2 로 clamp — 리포트 카드 깨짐 방지
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ThemeData builder
// ═════════════════════════════════════════════════════════════════════════════
ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  // ── ColorScheme ────────────────────────────────────────────────────────────
  final base = ColorScheme.fromSeed(
    seedColor: isDark ? AppColors.seedDark : AppColors.seed,
    brightness: brightness,
  );

  final colorScheme = base.copyWith(
    primary:             isDark ? AppColors.seedDark : AppColors.seed,
    onPrimary:           Colors.white,
    surface:             isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
    onSurface:           isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
    surfaceContainer:    isDark ? AppColors.surfaceContainerDark : AppColors.surfaceContainerLight,
    surfaceContainerHighest:
        isDark ? AppColors.surfaceContainerHighestDark : AppColors.surfaceContainerHighestLight,
    outline:             isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
    outlineVariant:      isDark ? const Color(0x14FFFFFF) : const Color(0x0A000000),
    error:               AppColors.danger,
    scrim:               isDark ? AppColors.scrimDark : AppColors.scrimLight,
  );

  // ── Typography — Pretendard (fallback NotoSansKR) ─────────────────────────
  // google_fonts 는 'Pretendard' 를 직접 제공하지 않으므로 NotoSansKR 을 기본
  // 타이포로 쓰되, 플랫폼에 Pretendard 가 등록되어 있다면 fontFamily 로
  // 덮어쓸 수 있게 TextTheme 을 따로 합성한다.
  final baseText = GoogleFonts.notoSansKrTextTheme(
    ThemeData(brightness: brightness).textTheme,
  );

  final onSurface = colorScheme.onSurface;
  final onMuted = isDark ? AppColors.onSurfaceMutedDark : AppColors.onSurfaceMutedLight;
  final onSubtle = isDark ? AppColors.onSurfaceSubtleDark : AppColors.onSurfaceSubtleLight;

  final textTheme = baseText.copyWith(
    // Display — 히어로 타이틀
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

    // Body — 리포트 본문 (line-height 1.7 요구사항)
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

    // Label — 버튼 / 오버라인
    labelLarge: baseText.labelLarge?.copyWith(
      fontSize: 14, height: 1.2, letterSpacing: 0.2,
      fontWeight: FontWeight.w600, color: onSurface,
    ),
    labelMedium: baseText.labelMedium?.copyWith(
      fontSize: 12, height: 1.2, letterSpacing: 0.4,
      fontWeight: FontWeight.w600, color: onMuted,
    ),
    labelSmall: baseText.labelSmall?.copyWith(
      // overline — 섹션 라벨 (ex. "이마·상부")
      fontSize: 11, height: 1.2, letterSpacing: 1.2,
      fontWeight: FontWeight.w700, color: onMuted,
    ),
  ).apply(
    // Pretendard 가 시스템에 등록된 경우 여기서 덮어쓰기.
    // 등록되어 있지 않으면 NotoSansKR 로 자연스럽게 fallback.
    fontFamilyFallback: const ['Pretendard', 'NotoSansKR', 'Noto Sans KR'],
  );

  // ── 최종 ThemeData ────────────────────────────────────────────────────────
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
    splashFactory: InkSparkle.splashFactory,
    textTheme: textTheme,
    primaryTextTheme: textTheme,

    // 카드: elevation 없음 + 1px border. CardTheme 만으로는 border 지정이
    // 제한적이므로 아래 CardTheme 에서 shape 로 border 를 지정한다.
    cardTheme: CardTheme(
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
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),
      actionsIconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.primary.withOpacity(0.35),
        disabledForegroundColor: colorScheme.onPrimary.withOpacity(0.8),
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
      backgroundColor:
          isDark ? AppColors.surfaceContainerHighestDark : AppColors.surfaceContainerHighestLight,
      selectedColor: colorScheme.primary.withOpacity(0.12),
      disabledColor: colorScheme.onSurface.withOpacity(0.06),
      labelStyle: textTheme.labelMedium!,
      secondaryLabelStyle: textTheme.labelMedium!.copyWith(
        color: colorScheme.primary,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
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
        horizontal: AppSpacing.md, vertical: AppSpacing.md),
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
      linearTrackColor: colorScheme.primary.withOpacity(0.16),
      circularTrackColor: colorScheme.primary.withOpacity(0.16),
    ),

    // ── Aura 고유 토큰 주입 ────────────────────────────────────────────────
    extensions: <ThemeExtension<dynamic>>[
      isDark ? AuraColors.dark : AuraColors.light,
    ],
  );
}
