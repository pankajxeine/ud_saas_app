import 'package:flutter/material.dart';
import 'package:ud_sass_app/ui/shadcn/shared/theme/color_scheme.dart'
    as shadcn_colors;
import 'package:ud_sass_app/ui/shadcn/shared/theme/theme.dart' as shadcn_theme;
import 'package:ud_sass_app/ui/shadcn/shared/theme/preset_themes.dart';
import 'app_theme.dart';

enum AppDensity {
  compact,
  normal,
  spacious,
  reduced;

  String get displayName => name[0].toUpperCase() + name.substring(1);

  shadcn_theme.Density get spacingMultiplier => switch (this) {
        compact => shadcn_theme.Density.compactDensity,
        normal => shadcn_theme.Density.defaultDensity,
        spacious => shadcn_theme.Density.spaciousDensity,
        reduced => shadcn_theme.Density.reducedDensity,
      };
}

const Map<String, double> radiusOptions = {
  'Sharp': 0.0,
  'Subtle': 0.25,
  'Default': 0.5,
  'Rounded': 0.75,
  'Pill': 1.5,
};

const Map<String, double> scalingOptions = {
  'Compact': 0.85,
  'Default': 1.0,
  'Large': 1.15,
};

const Map<String, FontSize> fontSizeOptions = {
  'Small': FontSize.small,
  'Default': FontSize.medium,
  'Large': FontSize.large,
};

const Map<String, double> surfaceOpacityOptions = {
  'Solid': 1.0,
  'Frosted': 0.94,
  'Translucent': 0.86,
  'Ghosted': 0.78,
};

const Map<String, double> surfaceBlurOptions = {
  'None': 0.0,
  'Soft': 4.0,
  'Medium': 8.0,
  'Strong': 12.0,
};

const shadcn_theme.ThemeData _baseTheme = shadcn_theme.ThemeData();
final RegistryThemePresetTokens _defaultTokens = RegistryThemePresetTokens(
  radius: _baseTheme.radius,
  spacing: _baseTheme.spacing,
  tracking: _baseTheme.tracking,
  shadows: _baseTheme.shadows,
);

final List<AppThemePreset> colorPresets = [
  AppThemePreset(
    id: 'default',
    name: 'Default',
    light: shadcn_colors.ColorSchemes.lightDefaultColor,
    dark: shadcn_colors.ColorSchemes.darkDefaultColor,
    lightTokens: _defaultTokens,
    darkTokens: _defaultTokens,
  ),
  ...registryThemePresets.map(
    (preset) => AppThemePreset(
      id: preset.id,
      name: preset.name,
      light: preset.light,
      dark: preset.dark,
      lightTokens: preset.lightTokens,
      darkTokens: preset.darkTokens,
    ),
  ),
];

RegistryThemePresetTokens tokensFor(String id, Brightness brightness) {
  final preset = colorPresets.firstWhere((preset) => preset.id == id,
      orElse: () => colorPresets.first);
  return brightness == Brightness.dark ? preset.darkTokens : preset.lightTokens;
}

shadcn_colors.ColorScheme schemeFor(String id, Brightness brightness) {
  final preset = colorPresets.firstWhere((preset) => preset.id == id,
      orElse: () => colorPresets.first);
  return brightness == Brightness.dark ? preset.dark : preset.light;
}

class AppThemeState {
  final AppThemePreset preset;
  final double? radius;
  final double scaling;
  final double surfaceOpacity;
  final double surfaceBlur;
  final FontSize fontSize;
  final AppDensity density;
  final shadcn_theme.SpacingScale spacing;
  final shadcn_theme.TrackingScale tracking;
  final shadcn_theme.ShadowScale shadows;
  final String presetId;
  final Brightness brightness;

  const AppThemeState({
    required this.presetId,
    required this.brightness,
    required this.preset,
    required this.scaling,
    required this.surfaceOpacity,
    required this.surfaceBlur,
    required this.fontSize,
    required this.density,
    required this.spacing,
    required this.tracking,
    required this.shadows,
    this.radius,
  });

  AppThemeState copyWith({
    AppThemePreset? preset,
    double? radius,
    double? scaling,
    double? surfaceOpacity,
    double? surfaceBlur,
    FontSize? fontSize,
    AppDensity? density,
    shadcn_theme.SpacingScale? spacing,
    shadcn_theme.TrackingScale? tracking,
    shadcn_theme.ShadowScale? shadows,
    String? presetId,
    Brightness? brightness,
  }) {
    return AppThemeState(
      preset: preset ?? this.preset,
      radius: radius ?? this.radius,
      scaling: scaling ?? this.scaling,
      surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
      surfaceBlur: surfaceBlur ?? this.surfaceBlur,
      fontSize: fontSize ?? this.fontSize,
      density: density ?? this.density,
      spacing: spacing ?? this.spacing,
      tracking: tracking ?? this.tracking,
      shadows: shadows ?? this.shadows,
      presetId: presetId ?? this.presetId,
      brightness: brightness ?? this.brightness,
    );
  }
}

class AppThemePreset {
  final String id;
  final String name;
  final shadcn_colors.ColorScheme light;
  final shadcn_colors.ColorScheme dark;
  final RegistryThemePresetTokens lightTokens;
  final RegistryThemePresetTokens darkTokens;

  const AppThemePreset({
    required this.id,
    required this.name,
    required this.light,
    required this.dark,
    required this.lightTokens,
    required this.darkTokens,
  });

  /// Build an AppThemeState from this preset and brightness
  AppThemeState toState(Brightness brightness) {
    final scheme = brightness == Brightness.dark ? dark : light;
    final tokens = brightness == Brightness.dark ? darkTokens : lightTokens;

    final myPreset = AppThemePreset(
      id: 'default',
      name: 'Default',
      light: scheme,
      dark: scheme,
      lightTokens: tokens,
      darkTokens: _defaultTokens,
    );
    return AppThemeState(
      presetId: id,
      brightness: brightness,
      preset: myPreset,
      radius: tokens.radius,
      scaling: 1.0, // default scaling
      surfaceOpacity: 1.0,
      surfaceBlur: 0.0,
      fontSize: FontSize.medium, // default font size
      density: AppDensity.normal, // default density
      spacing: tokens.spacing,
      tracking: tokens.tracking,
      shadows: tokens.shadows,
    );
  }
}
