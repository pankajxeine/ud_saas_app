import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ud_sass_app/core/theme/theme_app.dart';
import 'package:ud_sass_app/core/theme/theme_app_edits.dart';
import 'package:ud_sass_app/core/theme/app_fonts.dart';
import 'package:ud_sass_app/core/theme/app_theme.dart';
import 'package:ud_sass_app/core/theme/bloc/theme_state.dart';
import 'package:ud_sass_app/core/theme/theme_utils.dart'
    show
        kPrefsDensityBaseContainerPadding,
        kPrefsDensityBaseContentPadding,
        kPrefsDensityBaseGap,
        kPrefsLayoutAppBar,
        kPrefsLayoutShowAppBar,
        kPrefsLayoutShowSidebar,
        kPrefsLayoutShowNavigationRail,
        kPrefsLayoutShowBottomNavigation,
        kPrefsLayoutBackgroundGradient,
        kPrefsLayoutSurfaceGradient,
        kPrefsSeedColor,
        kPrefsRadius,
        kPrefsScaling,
        kPrefsSurfaceBlur,
        kPrefsSurfaceOpacity,
        kPrefsThemeMode,
        kPrefsThemePresetId,
        loadSettings;
import 'package:ud_sass_app/core/layouts/layout/app_layout_config.dart';
import 'package:ud_sass_app/data/layout_setting.dart';
import 'package:ud_sass_app/state/app_storage.dart' show kAppThemeDocumentKey;

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({
    required LayoutSettings initialSettings,
    required this.preferences,
  }) : super(ThemeState(settings: initialSettings));

  final SharedPreferences preferences;

  Future<void> setSeedColor(Color color) async {
    if (!await preferences.setInt(kPrefsSeedColor, color.toARGB32())) {
      throw StateError('Failed to save the selected theme palette.');
    }
    emit(
      state.copyWith(settings: _copySettings(state.settings, seedColor: color)),
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (themeMode == state.themeMode) {
      return;
    }

    final String storedMode = switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
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
    brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
  );

  Future<void> setSystemMode() => setThemeMode(ThemeMode.system);

  Future<void> toggleTheme() => setThemeMode(
    state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
  );

  Future<void> setPreset(String presetId) =>
      _saveThemeDocument(ThemeApp.fromPreset(presetId));

  Future<void> setColorToken(String token, String hex) =>
      editTheme((document) => document.withColor(token, hex));

  Future<void> setModeColor(String token, String hex, Brightness brightness) =>
      editTheme((document) => document.withModeColor(token, hex, brightness));

  Future<void> setShadow(Brightness brightness, AppShadowAtoms shadow) =>
      editTheme((document) => document.withShadow(brightness, shadow));

  Future<void> setSpacing(double rem) {
    if (!rem.isFinite || rem <= 0) {
      throw ArgumentError.value(rem, 'rem', 'Must be finite and positive.');
    }
    return editTheme((document) => document.withSpacingRem(rem));
  }

  Future<void> editTheme(ThemeApp Function(ThemeApp document) edit) =>
      _saveThemeDocument(edit(state.settings.themeDocument));

  /// Updates the application body font and persists the theme document.
  ///
  /// Passing `null` removes the custom font and returns to the platform/theme
  /// default configured by the Material theme.
  Future<void> setFontFamily(String? family) =>
      editTheme((document) => document.withFont('body', family));

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

  Future<void> setDensity(AppDensity density) async {
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

  Future<void> setLayoutConfig(AppLayoutConfig config) async {
    final values = <String, bool>{
      kPrefsLayoutShowAppBar: config.showAppBar,
      kPrefsLayoutShowSidebar: config.showSidebar,
      kPrefsLayoutShowNavigationRail: config.showNavigationRail,
      kPrefsLayoutShowBottomNavigation: config.showBottomNavigation,
      kPrefsLayoutBackgroundGradient: config.useBackgroundGradient,
      kPrefsLayoutSurfaceGradient: config.useSurfaceGradient,
    };

    for (final entry in values.entries) {
      if (!await preferences.setBool(entry.key, entry.value)) {
        throw StateError('Failed to save layout preference "${entry.key}".');
      }
    }

    if (!await preferences.setString(
      kPrefsLayoutAppBar,
      config.appBarLayout.name,
    )) {
      throw StateError('Failed to save the application bar layout.');
    }

    emit(
      state.copyWith(
        settings: _copySettings(state.settings, layoutConfig: config),
      ),
    );
  }

  Future<void> resetAppearance() async {
    const List<String> keys = <String>[
      kAppThemeDocumentKey,
      kPrefsThemePresetId,
      kPrefsSeedColor,
      kPrefsThemeMode,
      kPrefsRadius,
      kPrefsScaling,
      kPrefsSurfaceOpacity,
      kPrefsSurfaceBlur,
      kPrefsDensityBaseContainerPadding,
      kPrefsDensityBaseGap,
      kPrefsDensityBaseContentPadding,
      kPrefsLayoutAppBar,
      kPrefsLayoutShowAppBar,
      kPrefsLayoutShowSidebar,
      kPrefsLayoutShowNavigationRail,
      kPrefsLayoutShowBottomNavigation,
      kPrefsLayoutBackgroundGradient,
      kPrefsLayoutSurfaceGradient,
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
    ThemeMode? themeMode,
    double? scaling,
    AppDensity? density,
    Color? seedColor,
    AppLayoutConfig? layoutConfig,
  }) => LayoutSettings(
    themeDocument: themeDocument ?? settings.themeDocument,
    themeMode: themeMode ?? settings.themeMode,
    initialPath: settings.initialPath,
    scaling: scaling ?? settings.scaling,
    density: density ?? settings.density,
    seedColor: seedColor ?? settings.seedColor,
    layoutConfig: layoutConfig ?? settings.layoutConfig,
  );
}
