import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ud_sass_app/ui/shadcn/shared/theme/color_scheme.dart'
    as shadcn_colors;
import 'package:ud_sass_app/ui/shadcn/shared/theme/theme.dart' as shadcn_theme;
import 'package:ud_sass_app/ui/shadcn/shared/theme/preset_themes.dart';

import 'package:ud_sass_app/data/layout_setting.dart';

import 'theme_state.dart';

const String kPrefsThemePresetId = 'themePresetId';
const String kPrefsThemeMode = 'themeMode';
const String kPrefsCustomScheme = 'colorScheme';
const String kPrefsCustomSchemeLight = 'colorSchemeLight';
const String kPrefsCustomSchemeDark = 'colorSchemeDark';
const String kPrefsRadius = 'radius';
const String kPrefsScaling = 'scaling';
const String kPrefsSurfaceOpacity = 'surfaceOpacity';
const String kPrefsSurfaceBlur = 'surfaceBlur';
const String kPrefsDensityBaseContainerPadding = 'densityBaseContainerPadding';
const String kPrefsDensityBaseGap = 'densityBaseGap';
const String kPrefsDensityBaseContentPadding = 'densityBaseContentPadding';
const double kMinReadableSurfaceOpacity = 0.78;

double normalizeDocsSurfaceOpacity(double opacity) {
  return opacity.clamp(kMinReadableSurfaceOpacity, 1.0);
}

String toHexColor(Color color) {
  final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
  return '#${value.substring(2)}';
}

shadcn_colors.ColorScheme _schemeForPreset(
  String presetId,
  Brightness brightness,
) {
  final preset = colorPresets.firstWhere(
    (preset) => preset.id == presetId,
    orElse: () => colorPresets.first,
  );
  return brightness == Brightness.dark ? preset.dark : preset.light;
}

RegistryThemePresetTokens tokensForPreset(
  String presetId,
  Brightness brightness,
) {
  final preset = colorPresets.firstWhere(
    (preset) => preset.id == presetId,
    orElse: () => colorPresets.first,
  );
  return brightness == Brightness.dark ? preset.darkTokens : preset.lightTokens;
}

shadcn_theme.Density? densityFromPrefs(SharedPreferences prefs) {
  final container = prefs.getDouble(kPrefsDensityBaseContainerPadding);
  final gap = prefs.getDouble(kPrefsDensityBaseGap);
  final content = prefs.getDouble(kPrefsDensityBaseContentPadding);
  if (container == null || gap == null || content == null) {
    return null;
  }
  return shadcn_theme.Density(
    baseContainerPadding: container,
    baseGap: gap,
    baseContentPadding: content,
  );
}

Future<LayoutSettings> loadSettings(SharedPreferences prefs) async {
  final presetId = prefs.getString(kPrefsThemePresetId) ?? 'zinc';
  final themeMode = prefs.getString(kPrefsThemeMode) ?? 'dark';
  final brightness = themeMode == 'dark' ? Brightness.dark : Brightness.light;
  shadcn_colors.ColorScheme scheme;
  final customRaw = prefs.getString(
        brightness == Brightness.dark
            ? kPrefsCustomSchemeDark
            : kPrefsCustomSchemeLight,
      ) ??
      prefs.getString(kPrefsCustomScheme);
  if (presetId == 'custom' && customRaw != null) {
    scheme = shadcn_colors.ColorScheme.fromMap(
      jsonDecode(customRaw) as Map<String, dynamic>,
    );
  } else {
    scheme = _schemeForPreset(presetId, brightness);
  }
  final hasRadiusPref = prefs.containsKey(kPrefsRadius);
  final presetTokens = tokensForPreset(presetId, brightness);
  final resolvedRadius = hasRadiusPref
      ? (prefs.getDouble(kPrefsRadius) ?? presetTokens.radius)
      : (presetId == 'custom' ? 0.1 : presetTokens.radius);
  final resolvedDensity = densityFromPrefs(prefs) ?? presetTokens.density;
  final storedPath = prefs.getString('initialPath');
  return LayoutSettings(
    colorScheme: scheme,
    radius: resolvedRadius,
    scaling: prefs.getDouble(kPrefsScaling) ?? 1.0,
    surfaceOpacity: normalizeDocsSurfaceOpacity(
      prefs.getDouble(kPrefsSurfaceOpacity) ?? 1.0,
    ),
    surfaceBlur: prefs.getDouble(kPrefsSurfaceBlur) ?? 0.0,
    density: resolvedDensity,
    initialPath: storedPath ?? '/',
    presetId: presetId,
    brightness: brightness,
  );
}
