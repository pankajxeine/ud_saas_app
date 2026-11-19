import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ud_sass_app/data/layout_setting.dart';
import 'package:ud_sass_app/state/app_storage.dart';

import 'app_theme.dart';
import 'theme_app.dart';
import 'theme_app_edits.dart';

const kPrefsThemeMode = 'themeMode';
const kPrefsThemePresetId = 'themePresetId';
const kPrefsRadius = 'radius';
const kPrefsScaling = 'scaling';
const kPrefsSurfaceOpacity = 'surfaceOpacity';
const kPrefsSurfaceBlur = 'surfaceBlur';
const kPrefsDensityBaseContainerPadding = 'density.baseContainerPadding';
const kPrefsDensityBaseGap = 'density.baseGap';
const kPrefsDensityBaseContentPadding = 'density.baseContentPadding';

Future<LayoutSettings> loadSettings(SharedPreferences preferences) async {
  ThemeApp document;
  final savedDocument = preferences.getString(kAppThemeDocumentKey);
  if (savedDocument != null) {
    try {
      final decoded = jsonDecode(savedDocument);
      if (decoded is! Map)
        throw const FormatException('Invalid theme document');
      document = ThemeApp.fromJson(Map<String, Object?>.from(decoded));
    } catch (_) {
      document = ThemeApp.fromPreset('neutral');
    }
  } else {
    final preset = preferences.getString(kPrefsThemePresetId) ?? 'neutral';
    try {
      document = ThemeApp.fromPreset(preset == 'zinc' ? 'neutral' : preset);
    } catch (_) {
      document = ThemeApp.fromPreset('neutral');
    }
    final legacyDark = preferences.getString('colorSchemeDark');
    if (legacyDark != null) {
      try {
        final value = jsonDecode(legacyDark);
        if (value is Map && value['primary'] is String) {
          document = document.withDarkColor(
            'primary',
            value['primary'] as String,
          );
        }
      } catch (_) {}
    }
  }

  final mode = switch ((preferences.getString(kPrefsThemeMode) ?? 'system')
      .toLowerCase()) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
  final radius = preferences.getDouble(kPrefsRadius);
  if (radius != null && radius.isFinite && radius >= 0) {
    document = document.withRadiusPx(radius * 16);
  }
  final density = _density(preferences);
  return LayoutSettings(
    themeDocument: document,
    themeMode: mode,
    initialPath: preferences.getString('initialPath') ?? '/login',
    scaling: preferences.getDouble(kPrefsScaling) ?? 1,
    density: density,
  );
}

AppDensity _density(SharedPreferences preferences) {
  final container = preferences.getDouble(kPrefsDensityBaseContainerPadding);
  final gap = preferences.getDouble(kPrefsDensityBaseGap);
  final content = preferences.getDouble(kPrefsDensityBaseContentPadding);
  if (container == null || gap == null || content == null)
    return AppDensity.standard;
  return AppDensity(
    baseContainerPadding: container,
    baseGap: gap,
    baseContentPadding: content,
  );
}
