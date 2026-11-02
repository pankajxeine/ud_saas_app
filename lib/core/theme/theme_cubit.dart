import 'package:flutter/material.dart' show Brightness;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ud_sass_app/core/theme/theme_app.dart';
import 'package:ud_sass_app/core/theme/theme_app_edits.dart';
import 'package:ud_sass_app/core/theme/app_fonts.dart';
import 'package:ud_sass_app/core/theme/theme_state.dart';
import 'package:ud_sass_app/core/theme/theme_utils.dart'
    show
        kPrefsDensityBaseContainerPadding,
        kPrefsDensityBaseContentPadding,
        kPrefsDensityBaseGap,
        kPrefsRadius,
        kPrefsScaling,
        kPrefsSurfaceBlur,
        kPrefsSurfaceOpacity,
        kPrefsThemeMode,
        kPrefsThemePresetId,
        loadSettings;
import 'package:ud_sass_app/data/layout_setting.dart';
import 'package:ud_sass_app/state/app_storage.dart' show kAppThemeDocumentKey;
import 'package:ud_sass_app/ui/dashcn/theme.dart' as dashcn;

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({
    required LayoutSettings initialSettings,
    required this.preferences,
  }) : super(ThemeState(settings: initialSettings));

  final SharedPreferences preferences;

  Future<void> setThemeMode(dashcn.ThemeMode themeMode) async {
    if (themeMode == state.themeMode) {
      return;
    }

    final String storedMode = switch (themeMode) {
      dashcn.ThemeMode.light => 'light',
      dashcn.ThemeMode.dark => 'dark',
      dashcn.ThemeMode.system => 'system',
    };
    final bool saved = await preferences.setString(kPrefsThemeMode, storedMode);
    if (!saved) {
      throw StateError('Failed to save the selected theme mode.');
    }

    emit(
      state.copyWith(
        settings: _copySettings(state.settings, themeMode: themeMode),
      ),
    );
  }

  Future<void> setBrightness(Brightness brightness) => setThemeMode(
    brightness == Brightness.dark
        ? dashcn.ThemeMode.dark
        : dashcn.ThemeMode.light,
  );

  Future<void> toggleTheme() => setThemeMode(
    state.themeMode == dashcn.ThemeMode.light
        ? dashcn.ThemeMode.dark
        : dashcn.ThemeMode.light,
  );

  Future<void> setPreset(String presetId) =>
      _saveThemeDocument(ThemeApp.fromPreset(presetId));

  Future<void> editTheme(ThemeApp Function(ThemeApp document) edit) =>
      _saveThemeDocument(edit(state.settings.themeDocument));

  Future<void> setRadius(double radius) async {
    if (!radius.isFinite || radius < 0) {
      throw ArgumentError.value(
        radius,
        'radius',
        'Must be finite and non-negative.',
      );
    }
    await _saveThemeDocument(
      state.settings.themeDocument.withRadiusPx(radius * 16),
    );
  }

  Future<void> setSurfaceOpacity(double opacity) async {
    if (!opacity.isFinite || opacity < 0 || opacity > 1) {
      throw ArgumentError.value(opacity, 'opacity', 'Must be between 0 and 1.');
    }
    await _saveThemeDocument(
      state.settings.themeDocument.withSurfaceOpacity(opacity),
    );
  }

  Future<void> setSurfaceBlur(double blur) async {
    if (!blur.isFinite || blur < 0) {
      throw ArgumentError.value(
        blur,
        'blur',
        'Must be finite and non-negative.',
      );
    }
    await _saveThemeDocument(
      state.settings.themeDocument.withSurfaceBlur(blur),
    );
  }

  Future<void> setScaling(double scaling) async {
    if (!scaling.isFinite || scaling <= 0) {
      throw ArgumentError.value(
        scaling,
        'scaling',
        'Must be finite and positive.',
      );
    }
    if (!await preferences.setDouble(kPrefsScaling, scaling)) {
      throw StateError('Failed to save the selected interface scaling.');
    }
    emit(
      state.copyWith(settings: _copySettings(state.settings, scaling: scaling)),
    );
  }

  Future<void> setDensity(dashcn.Density density) async {
    if (!await preferences.setDouble(
      kPrefsDensityBaseContainerPadding,
      density.baseContainerPadding,
    )) {
      throw StateError('Failed to save the selected container density.');
    }
    if (!await preferences.setDouble(kPrefsDensityBaseGap, density.baseGap)) {
      throw StateError('Failed to save the selected gap density.');
    }
    if (!await preferences.setDouble(
      kPrefsDensityBaseContentPadding,
      density.baseContentPadding,
    )) {
      throw StateError('Failed to save the selected content density.');
    }
    emit(
      state.copyWith(settings: _copySettings(state.settings, density: density)),
    );
  }

  Future<void> resetAppearance() async {
    const List<String> keys = <String>[
      kAppThemeDocumentKey,
      kPrefsThemePresetId,
      kPrefsThemeMode,
      kPrefsRadius,
      kPrefsScaling,
      kPrefsSurfaceOpacity,
      kPrefsSurfaceBlur,
      kPrefsDensityBaseContainerPadding,
      kPrefsDensityBaseGap,
      kPrefsDensityBaseContentPadding,
      'colorScheme',
      'colorSchemeLight',
      'colorSchemeDark',
    ];
    for (final String key in keys) {
      if (!await preferences.remove(key)) {
        throw StateError('Failed to reset saved appearance preference "$key".');
      }
    }
    emit(state.copyWith(settings: await loadSettings(preferences)));
  }

  Future<void> _saveThemeDocument(ThemeApp themeDocument) async {
    for (final String family in themeDocument.fonts.values) {
      await loadAppFonts(family);
    }
    if (!await preferences.setString(
      kAppThemeDocumentKey,
      themeDocument.json,
    )) {
      throw StateError('Failed to save the theme document.');
    }
    if (!await preferences.setString(kPrefsThemePresetId, themeDocument.id)) {
      throw StateError('Failed to save the selected theme preset.');
    }
    emit(
      state.copyWith(
        settings: _copySettings(state.settings, themeDocument: themeDocument),
      ),
    );
  }

  LayoutSettings _copySettings(
    LayoutSettings settings, {
    ThemeApp? themeDocument,
    dashcn.ThemeMode? themeMode,
    double? scaling,
    dashcn.Density? density,
  }) => LayoutSettings(
    themeDocument: themeDocument ?? settings.themeDocument,
    themeMode: themeMode ?? settings.themeMode,
    initialPath: settings.initialPath,
    scaling: scaling ?? settings.scaling,
    density: density ?? settings.density,
  );
}
