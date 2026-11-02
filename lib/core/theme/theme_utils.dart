import 'dart:convert';

import 'package:flutter/material.dart' show Brightness, Color;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ud_sass_app/core/theme/theme_app.dart';
import 'package:ud_sass_app/core/theme/theme_app_edits.dart';
import 'package:ud_sass_app/core/theme/app_preset_sources.dart';
import 'package:ud_sass_app/state/app_storage.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart' as dashcn;

import 'package:ud_sass_app/data/layout_setting.dart';

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

dashcn.Density? densityFromPrefs(SharedPreferences prefs) {
  final container = prefs.getDouble(kPrefsDensityBaseContainerPadding);
  final gap = prefs.getDouble(kPrefsDensityBaseGap);
  final content = prefs.getDouble(kPrefsDensityBaseContentPadding);
  if (container == null || gap == null || content == null) {
    return null;
  }
  return dashcn.Density(
    baseContainerPadding: container,
    baseGap: gap,
    baseContentPadding: content,
  );
}

Future<LayoutSettings> loadSettings(SharedPreferences prefs) async {
  final String? storedDocument = prefs.getString(kAppThemeDocumentKey);
  final String storedPresetId = prefs.getString(kPrefsThemePresetId) ?? 'zinc';
  final String presetId = switch (storedPresetId) {
    'zinc' || 'custom' => 'neutral',
    _ => storedPresetId,
  };
  final ThemeApp themeDocument;
  if (storedDocument != null) {
    final Object? decoded = jsonDecode(storedDocument);
    if (decoded is! Map) {
      throw const FormatException('The saved theme document must be a JSON object.');
    }
    themeDocument = ThemeApp.fromJson(
      decoded.map(
        (Object? key, Object? value) => MapEntry(key.toString(), value),
      ),
    );
  } else {
    if (!kPresetSources.containsKey(presetId)) {
      throw FormatException('Unsupported saved Dashcn theme preset: $presetId');
    }

    ThemeApp document = _applyLegacyColors(
      prefs,
      ThemeApp.fromPreset(presetId),
    );

    if (prefs.containsKey(kPrefsRadius)) {
      final double radius = prefs.getDouble(kPrefsRadius)!;
      if (!radius.isFinite || radius < 0) {
        throw const FormatException('Saved theme radius must be finite and non-negative.');
      }
      document = document.withRadiusPx(radius * 16);
    }
    if (prefs.containsKey(kPrefsSurfaceOpacity)) {
      document = document.withSurfaceOpacity(
        normalizeDocsSurfaceOpacity(prefs.getDouble(kPrefsSurfaceOpacity)!),
      );
    }
    if (prefs.containsKey(kPrefsSurfaceBlur)) {
      final double blur = prefs.getDouble(kPrefsSurfaceBlur)!;
      if (!blur.isFinite || blur < 0) {
        throw const FormatException('Saved surface blur must be finite and non-negative.');
      }
      document = document.withSurfaceBlur(blur);
    }
    themeDocument = document;
  }

  final dashcn.Density? savedDensity = densityFromPrefs(prefs);
  final double scaling = prefs.getDouble(kPrefsScaling) ?? 1;
  if (!scaling.isFinite || scaling <= 0) {
    throw const FormatException('Saved theme scaling must be finite and positive.');
  }

  final String? storedMode = prefs.getString(kPrefsThemeMode);
  final dashcn.ThemeMode themeMode = switch (storedMode) {
    'light' => dashcn.ThemeMode.light,
    'system' => dashcn.ThemeMode.system,
    'dark' || null => dashcn.ThemeMode.dark,
    _ => throw FormatException('Unsupported saved theme mode: $storedMode'),
  };

  return LayoutSettings(
    themeDocument: themeDocument,
    themeMode: themeMode,
    initialPath: prefs.getString('initialPath') ?? '/login',
    scaling: scaling,
    density: savedDensity,
  );
}

ThemeApp _applyLegacyColors(
  SharedPreferences prefs,
  ThemeApp document,
) {
  final Brightness brightness =
      prefs.getString(kPrefsThemeMode) == 'light'
      ? Brightness.light
      : Brightness.dark;
  final String? raw =
      prefs.getString(
        brightness == Brightness.dark
            ? kPrefsCustomSchemeDark
            : kPrefsCustomSchemeLight,
      ) ??
      prefs.getString(kPrefsCustomScheme);
  if (raw == null) {
    return document;
  }

  final Object? decoded = jsonDecode(raw);
  if (decoded is! Map) {
    throw const FormatException('The saved custom color scheme must be a JSON object.');
  }
  ThemeApp updated = document;
  for (final String token in kAppColorTokenKeys) {
    final Object? value = decoded[token];
    if (value == null) {
      continue;
    }
    if (value is! String || !kAppHexColorPattern.hasMatch(value)) {
      throw FormatException('Saved custom color "$token" is not a valid hex color.');
    }
    updated = updated.withModeColor(token, value, brightness);
  }
  return updated;
}
