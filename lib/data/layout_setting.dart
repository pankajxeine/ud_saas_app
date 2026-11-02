import 'package:flutter/material.dart' show Brightness;

import 'package:ud_sass_app/core/theme/theme_app.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart' as dashcn;

/// App appearance and startup route, resolved from persisted preferences.
///
/// The theme document is the source of truth for both Dashcn themes, matching
/// the docs app's theme model.
class LayoutSettings {
  const LayoutSettings({
    required this.themeDocument,
    required this.themeMode,
    required this.initialPath,
    required this.scaling,
    required this.density,
  });

  final ThemeApp themeDocument;
  final dashcn.ThemeMode themeMode;
  final String initialPath;
  final double scaling;
  final dashcn.Density? density;

  String get presetId => themeDocument.id;

  dashcn.ThemeData get lightTheme => _resolveTheme(Brightness.light);

  dashcn.ThemeData get darkTheme => _resolveTheme(Brightness.dark);

  dashcn.ThemeData _resolveTheme(Brightness brightness) {
    final dashcn.ThemeData resolved = themeDocument.theme(brightness);
    return resolved.copyWith(
      scaling: () => scaling,
      density: density == null ? null : () => density!,
    );
  }
}
