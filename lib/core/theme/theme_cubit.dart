// import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ud_sass_app/ui/shadcn/components/layout/flex/flex.dart';
// import 'package:ud_sass_app/ui/shadcn/shared/theme/color_scheme.dart'
//     as shadcn_colors;
import 'package:ud_sass_app/ui/shadcn/shared/theme/preset_themes.dart';
import 'package:ud_sass_app/ui/shadcn/shared/theme/theme.dart' as shadcn_theme;
import 'app_theme.dart';

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
const String kPrefsFontSize = 'fontSize';

double normalizeDocsSurfaceOpacity(double opacity) {
  return opacity.clamp(kMinReadableSurfaceOpacity, 1.0);
}

class AppThemeCubit extends Cubit<AppThemeState> {
  AppThemeCubit(this.prefs) : super(_load(prefs));
  final SharedPreferences prefs;

  static AppThemeState _load(SharedPreferences p) {
    final brightness = p.getString(kPrefsThemeMode) == 'light'
        ? Brightness.light
        : Brightness.dark;
    // final schemeName = p.getString(kPrefsCustomScheme) ?? 'zinc';
    // final colorScheme = colorPresets.firstWhere((e) => e.name == schemeName,
    //     orElse: () => colorPresets.first);

    final densityName = p.getString(kPrefsDensityBaseGap) ?? 'normal';

    final density = AppDensity.values.firstWhere(
      (e) => e.name == densityName,
      orElse: () => AppDensity.normal,
    );
    final fontSizeName = p.getString(kPrefsFontSize) ?? 'medium';

    final fontSize = FontSize.values.firstWhere((e) => e.name == fontSizeName,
        orElse: () => FontSize.medium);

    final String presetId = p.getString(kPrefsThemePresetId) ?? 'default';

    final preset = colorPresets.firstWhere((e) => e.id == presetId,
        orElse: () => colorPresets.first);
    final tokens = tokensFor(presetId, brightness);
    return AppThemeState(
      brightness: brightness,
      preset: preset,
      radius: p.getDouble(kPrefsRadius) ?? 6.0,
      density: density,
      scaling: p.getDouble(kPrefsScaling) ?? 1.0,
      surfaceOpacity: p.getDouble(kPrefsSurfaceOpacity) ?? 1.0,
      surfaceBlur: p.getDouble(kPrefsSurfaceBlur) ?? 0.0,
      fontSize: fontSize,
      presetId: presetId,
      spacing: tokens.spacing,
      tracking: tokens.tracking,
      shadows: tokens.shadows,
    );
  }

  void setPreset(String id) {
    if (state.presetId == id) return;

    final preset = colorPresets.firstWhere((preset) => preset.id == id,
        orElse: () => colorPresets.first);
    final tokens = state.brightness == Brightness.dark
        ? preset.darkTokens
        : preset.lightTokens;

    final newData = state.copyWith(
        preset: preset,
        radius: tokens.radius,
        spacing: tokens.spacing,
        tracking: tokens.tracking,
        shadows: tokens.shadows,
        presetId: id);
    _persistDensity(tokens.density);
    prefs.setString(kPrefsThemePresetId, id);
    emit(newData);
  }

  // void toggleTheme() =>
  //     setBrightness(state.isDark ? Brightness.light : Brightness.dark);

  void setBrightness(Brightness brightness) {
    if (state.brightness == brightness) return;
    if (state.presetId == 'default') {
      //final storedScheme = prefs.getString(_customSchemeKey(brightness));
      final newData = state.copyWith(brightness: brightness);
      prefs.setString(kPrefsCustomScheme, 'default');
      emit(newData);
    } else {
      final preset = colorPresets.firstWhere(
          (preset) => preset.id == state.presetId,
          orElse: () => colorPresets.first);
      final tokens = brightness == Brightness.dark
          ? preset.darkTokens
          : preset.lightTokens;
      final newData = state.copyWith(
          preset: preset,
          radius: tokens.radius,
          spacing: tokens.spacing,
          tracking: tokens.tracking,
          shadows: tokens.shadows,
          brightness: brightness);
      _persistDensity(tokens.density);
      prefs.setString(
          kPrefsThemeMode, brightness == Brightness.dark ? 'dark' : 'light');
      prefs.setString(kPrefsCustomScheme, preset.name);

      emit(newData);
    }
  }

  void setCustomScheme(AppThemePreset preset) {
    final newData = state.copyWith(preset: preset, presetId: preset.id);
    prefs.setString(kPrefsThemePresetId, preset.id);
    prefs.setString(kPrefsCustomScheme, preset.name);
    // prefs.setString(_customSchemeKey(preset.colorScheme.brightness),
    //     _encodeScheme(preset.colorScheme));
    emit(newData);
  }

  void setRadius(double radius) {
    final newData = state.copyWith(radius: radius);
    prefs.setDouble(kPrefsRadius, radius);
    emit(newData);
  }

  void setScaling(double scaling) {
    final newData = state.copyWith(scaling: scaling);
    prefs.setDouble(kPrefsScaling, scaling);
    emit(newData);
  }

  void setFontSize(FontSize fontSize) {
    final newData = state.copyWith(fontSize: fontSize);
    prefs.setString(kPrefsFontSize, fontSize.name);
    emit(newData);
  }

  void setSurfaceOpacity(double surfaceOpacity) {
    final normalized = normalizeDocsSurfaceOpacity(surfaceOpacity);
    final newData = state.copyWith(surfaceOpacity: normalized);
    prefs.setDouble(kPrefsSurfaceOpacity, normalized);
    emit(newData);
  }

  void setSurfaceBlur(double surfaceBlur) {
    final newData = state.copyWith(
      surfaceBlur: surfaceBlur,
      surfaceOpacity: normalizeDocsSurfaceOpacity(state.surfaceOpacity),
    );
    prefs.setDouble(kPrefsSurfaceBlur, surfaceBlur);
    prefs.setDouble(kPrefsSurfaceOpacity, newData.surfaceOpacity);
    emit(state.copyWith(surfaceBlur: surfaceBlur));
  }

  void setDensity(AppDensity density) {
    final newData = state.copyWith(density: density);

    _persistDensity(AppDensity.values
        .firstWhere((e) => e.name == density.name,
            orElse: () => AppDensity.normal)
        .spacingMultiplier);
    emit(newData);
  }

  // Helpers
  RegistryThemePresetTokens _tokensFor(String id, Brightness brightness) {
    final preset = colorPresets.firstWhere((preset) => preset.id == id,
        orElse: () => colorPresets.first);
    return brightness == Brightness.dark
        ? preset.darkTokens
        : preset.lightTokens;
  }

  // String _encodeScheme(shadcn_colors.ColorScheme scheme) =>
  //     jsonEncode(scheme.toMap());

  // String _customSchemeKey(Brightness brightness) =>
  //     brightness == Brightness.dark
  //         ? kPrefsCustomSchemeDark
  //         : kPrefsCustomSchemeLight;

  void _persistDensity(shadcn_theme.Density density) {
    prefs.setDouble(
        kPrefsDensityBaseContainerPadding, density.baseContainerPadding);
    prefs.setDouble(kPrefsDensityBaseGap, density.baseGap);
    prefs.setDouble(
        kPrefsDensityBaseContentPadding, density.baseContentPadding);
  }

  void resetAppearance() {
    // Pick the default preset
    final defaultPreset = colorPresets.firstWhere(
      (preset) => preset.id == 'default',
      orElse: () => colorPresets.first,
    );
    // Build a default AppThemeData using dark brightness
    final tokens = _tokensFor(defaultPreset.id, Brightness.dark);

    final def = AppThemeState(
      preset: defaultPreset,
      radius: tokens.radius,
      density: AppDensity.normal,
      spacing: tokens.spacing,
      tracking: tokens.tracking,
      shadows: tokens.shadows,
      scaling: 1.0,
      surfaceOpacity: kMinReadableSurfaceOpacity,
      surfaceBlur: 0.0,
      fontSize: FontSize.medium,
      presetId: defaultPreset.id,
      brightness: Brightness.dark,
    );

    // Persist defaults into SharedPreferences
    prefs
      ..setString(kPrefsThemePresetId, def.presetId)
      ..setString(
          kPrefsThemeMode, def.brightness == Brightness.dark ? 'dark' : 'light')
      ..setString(kPrefsCustomScheme, 'default')
      ..setString(kPrefsFontSize, def.fontSize.name)
      ..setDouble(kPrefsRadius, def.radius ?? 0.25)
      ..setDouble(kPrefsScaling, def.scaling)
      ..setDouble(kPrefsSurfaceOpacity, def.surfaceOpacity)
      ..setDouble(kPrefsSurfaceBlur, def.surfaceBlur);

    _persistDensity(AppDensity.values
        .firstWhere((e) => e.name == def.density.name,
            orElse: () => AppDensity.normal)
        .spacingMultiplier);

    // Emit new state
    emit(def);
  }
}
