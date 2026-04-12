import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static String get _font => GoogleFonts.notoSansKr().fontFamily!;

  static const FlexSchemeColor _lightColors = FlexSchemeColor(
    primary: Color(0xFF6B5CE7),
    primaryContainer: Color(0xFFEAE6FF),
    secondary: Color(0xFF4EA8DE),
    secondaryContainer: Color(0xFFDCF0FF),
    tertiary: Color(0xFF9C6ADE),
  );

  static const FlexSchemeColor _darkColors = FlexSchemeColor(
    primary: Color(0xFF8B7CF8),
    primaryContainer: Color(0xFF2D1F6E),
    secondary: Color(0xFF6DC2F0),
    secondaryContainer: Color(0xFF1A3D58),
    tertiary: Color(0xFFB994F5),
  );

  static const FlexSubThemesData _subThemes = FlexSubThemesData(
    cardRadius: AppRadius.md,
    elevatedButtonRadius: AppRadius.md,
    inputDecoratorRadius: AppRadius.sm,
    bottomSheetRadius: AppRadius.xl,
    navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
  );

  static ThemeData light() => FlexThemeData.light(
        colors: _lightColors,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: _subThemes,
        fontFamily: _font,
        useMaterial3: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
      );

  static ThemeData dark() => FlexThemeData.dark(
        colors: _darkColors,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: _subThemes,
        fontFamily: _font,
        useMaterial3: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
      );
}
