import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:ud_sass_app/core/theme/app_theme.dart';
import 'package:ud_sass_app/core/theme/theme_app.dart';
import '../core/theme/app_theme_palette.dart';

/// Persisted application appearance and startup settings.
class LayoutSettings {
  const LayoutSettings({
    required this.themeDocument,
    required this.themeMode,
    required this.initialPath,
    required this.scaling,
    required this.density,
    this.seedColor = AppThemePalette.defaultColor,
  });

  final ThemeApp themeDocument;
  final ThemeMode themeMode;
  final String initialPath;
  final double scaling;
  final AppDensity? density;

  /// Selected accent/seed color for generating color schemes.
  final Color seedColor;

  String get presetId => themeDocument.id;

  ThemeData get lightTheme => AppTheme.materialFor(
    brightness: Brightness.light,
    seedColor: seedColor,
    colorTokens: themeDocument.light,
    radius: themeDocument.radiusPx.clamp(0.0, 40.0).toDouble(),
    fontFamily: themeDocument.bodyFont,
    surfaceOpacity: themeDocument.surfaceOpacity,
    surfaceBlur: themeDocument.surfaceBlur,
    shadowColor: Color(themeDocument.lightShadow.color),
    shadowOpacity: themeDocument.lightShadow.opacity,
    shadowBlur: themeDocument.lightShadow.blur,
    density: density,
  );

  ThemeData get darkTheme => AppTheme.materialFor(
    brightness: Brightness.dark,
    seedColor: seedColor,
    colorTokens: themeDocument.dark,
    radius: themeDocument.radiusPx.clamp(0.0, 40.0).toDouble(),
    fontFamily: themeDocument.bodyFont,
    surfaceOpacity: themeDocument.surfaceOpacity,
    surfaceBlur: themeDocument.surfaceBlur,
    shadowColor: Color(themeDocument.darkShadow.color),
    shadowOpacity: themeDocument.darkShadow.opacity,
    shadowBlur: themeDocument.darkShadow.blur,
    density: density,
  );

  CupertinoThemeData cupertinoTheme(Brightness brightness) =>
      AppTheme.cupertino(
        brightness,
        seedColor: seedColor,
        colorTokens: brightness == Brightness.dark
            ? themeDocument.dark
            : themeDocument.light,
        fontFamily: themeDocument.bodyFont,
      );
}
