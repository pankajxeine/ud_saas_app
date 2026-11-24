import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ud_sass_app/data/layout_setting.dart';
import 'package:ud_sass_app/core/layouts/layout/app_layout_config.dart';
import 'package:ud_sass_app/state/app_storage.dart';

import 'app_theme.dart';
import 'app_theme_palette.dart';
import 'theme_app.dart';
import 'theme_app_edits.dart';

const kPrefsThemeMode = 'themeMode';
const kPrefsThemePresetId = 'themePresetId';
const kPrefsSeedColor = 'seedColor';
const kPrefsRadius = 'radius';
const kPrefsScaling = 'scaling';
const kPrefsSurfaceOpacity = 'surfaceOpacity';
const kPrefsSurfaceBlur = 'surfaceBlur';
const kPrefsDensityBaseContainerPadding = 'density.baseContainerPadding';
const kPrefsDensityBaseGap = 'density.baseGap';
const kPrefsDensityBaseContentPadding = 'density.baseContentPadding';
const kPrefsLayoutAppBar = 'layout.appBarLayout';
const kPrefsLayoutShowAppBar = 'layout.showAppBar';
const kPrefsLayoutShowSidebar = 'layout.showSidebar';
const kPrefsLayoutShowNavigationRail = 'layout.showNavigationRail';
const kPrefsLayoutShowBottomNavigation = 'layout.showBottomNavigation';
const kPrefsLayoutBackgroundGradient = 'layout.backgroundGradient';
const kPrefsLayoutSurfaceGradient = 'layout.surfaceGradient';

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
  final savedSeedColor = preferences.getInt(kPrefsSeedColor);
  return LayoutSettings(
    themeDocument: document,
    themeMode: mode,
    initialPath: preferences.getString('initialPath') ?? '/login',
    scaling: preferences.getDouble(kPrefsScaling) ?? 1,
    density: density,
    seedColor: savedSeedColor == null
        ? AppThemePalette.defaultColor
        : Color(savedSeedColor),
    layoutConfig: _layoutConfig(preferences),
  );
}

AppLayoutConfig? _layoutConfig(SharedPreferences preferences) {
  final hasSavedLayout = preferences.containsKey(kPrefsLayoutAppBar) ||
      preferences.containsKey(kPrefsLayoutShowAppBar) ||
      preferences.containsKey(kPrefsLayoutShowSidebar) ||
      preferences.containsKey(kPrefsLayoutShowNavigationRail) ||
      preferences.containsKey(kPrefsLayoutShowBottomNavigation) ||
      preferences.containsKey(kPrefsLayoutBackgroundGradient) ||
      preferences.containsKey(kPrefsLayoutSurfaceGradient);

  if (!hasSavedLayout) return null;

  final appBarLayout = switch (
    preferences.getString(kPrefsLayoutAppBar) ?? 'fullWidth'
  ) {
    'contentOnly' => AppBarLayout.contentOnly,
    _ => AppBarLayout.fullWidth,
  };

  return AppLayoutConfig(
    appBarLayout: appBarLayout,
    showAppBar: preferences.getBool(kPrefsLayoutShowAppBar) ?? true,
    showSidebar: preferences.getBool(kPrefsLayoutShowSidebar) ?? true,
    showNavigationRail:
        preferences.getBool(kPrefsLayoutShowNavigationRail) ?? true,
    showBottomNavigation:
        preferences.getBool(kPrefsLayoutShowBottomNavigation) ?? true,
    useBackgroundGradient:
        preferences.getBool(kPrefsLayoutBackgroundGradient) ?? true,
    useSurfaceGradient:
        preferences.getBool(kPrefsLayoutSurfaceGradient) ?? true,
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
