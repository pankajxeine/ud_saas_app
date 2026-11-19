import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ud_sass_app/core/theme/app_preset_sources.dart';
import 'package:ud_sass_app/core/theme/app_theme.dart';

import 'theme_app_schema.dart';

export 'theme_app_schema.dart'
    show AppShadowAtoms, ThemeAppException, appColorOf, formatAppHexColor,
        jsonNumber, kAppChartTokenKeys, kAppColorTokenKeys, kAppFontSlots,
        kAppHexColorPattern, kAppTrackingSteps, parseAppHexColor,
        MotionIntensity, MotionCurveName;

/// Immutable persisted application theme document.
///
/// This model is the single source for preset JSON, runtime Material themes,
/// font settings, color tokens, shadows, radius, surface effects, and motion.
@immutable
class ThemeApp {
  const ThemeApp({
    required this.id,
    required this.name,
    required this.light,
    required this.dark,
    required this.radius,
    required this.spacing,
    required this.tracking,
    required this.lightShadow,
    required this.darkShadow,
    required this.fonts,
    this.surfaceOpacity,
    this.surfaceBlur,
    this.motionEnabled,
    this.motionIntensity,
    this.motionCustomDurationMultiplier,
    this.motionCustomPressScale,
    this.motionCustomEnterOffset,
    this.motionCustomCurve,
    this.schema,
    this.shadowsDerived,
  });

  factory ThemeApp.fromPreset(String presetId) {
    final source = kPresetSources[presetId];
    if (source == null) throw ThemeAppException('Unknown preset: $presetId');
    return ThemeApp.fromJson(jsonDecode(source.json) as Map<String, Object?>);
  }

  factory ThemeApp.fromJson(Map<String, Object?> json) {
    final id = _string(json, 'id') ?? '';
    if (!RegExp(r'^[a-z0-9][a-z0-9-]*$').hasMatch(id)) {
      throw const ThemeAppException('preset.id must be lower-case kebab-case');
    }
    if ((json['schemaVersion'] as num?)?.toInt() != 2) {
      throw const ThemeAppException('preset.schemaVersion must be 2');
    }
    final radius = _number(json, 'radius') ?? 0;
    final spacing = _number(json, 'spacing') ?? 0;
    if (radius < 0 || spacing <= 0) {
      throw const ThemeAppException('preset.radius and spacing must be positive');
    }
    final shadow = _map(json['shadow'], 'preset.shadow');
    final motion = _parseMotion(json['motion']);
    final opacity = _number(json, 'surfaceOpacity');
    final blur = _number(json, 'surfaceBlur');
    if (opacity != null && (opacity < 0 || opacity > 1)) {
      throw const ThemeAppException('preset.surfaceOpacity must be in 0..1');
    }
    if (blur != null && blur < 0) {
      throw const ThemeAppException('preset.surfaceBlur must be non-negative');
    }
    return ThemeApp(
      schema: _string(json, r'$schema'),
      id: id,
      name: _string(json, 'name') ?? id,
      light: _colors(json['light'], 'light'),
      dark: _colors(json['dark'], 'dark'),
      radius: radius,
      spacing: spacing,
      tracking: _tracking(json['tracking']),
      lightShadow: AppShadowAtoms.fromJson(_map(shadow['light'], 'lightShadow'), path: 'preset.shadow.light'),
      darkShadow: AppShadowAtoms.fromJson(_map(shadow['dark'], 'darkShadow'), path: 'preset.shadow.dark'),
      fonts: _fonts(json['fonts']),
      surfaceOpacity: opacity,
      surfaceBlur: blur,
      motionEnabled: motion.enabled,
      motionIntensity: motion.intensity,
      motionCustomDurationMultiplier: motion.durationMultiplier,
      motionCustomPressScale: motion.pressScale,
      motionCustomEnterOffset: motion.enterOffset,
      motionCustomCurve: motion.curve,
      shadowsDerived: _string(json, 'shadowsDerived'),
    );
  }

  final String? schema;
  final String id;
  final String name;
  final Map<String, String> light;
  final Map<String, String> dark;
  final double radius;
  final double spacing;
  final Map<String, double> tracking;
  final AppShadowAtoms lightShadow;
  final AppShadowAtoms darkShadow;
  final Map<String, String> fonts;
  final double? surfaceOpacity;
  final double? surfaceBlur;
  final bool? motionEnabled;
  final MotionIntensity? motionIntensity;
  final double? motionCustomDurationMultiplier;
  final double? motionCustomPressScale;
  final double? motionCustomEnterOffset;
  final MotionCurveName? motionCustomCurve;
  final String? shadowsDerived;

  String? get headingFont => fonts['heading'];
  String? get bodyFont => fonts['body'] ?? fonts['sans'];
  String? get monoFont => fonts['mono'];
  bool get hasFonts => fonts.isNotEmpty;
  bool get hasMotion => motionEnabled != null || motionIntensity != null || motionCustomDurationMultiplier != null || motionCustomPressScale != null || motionCustomEnterOffset != null || motionCustomCurve != null;
  double get radiusPx => radius * 16;

  String colorOf(String token, Brightness brightness) => (brightness == Brightness.dark ? dark : light)[token]!;
  AppShadowAtoms shadowOf(Brightness brightness) => brightness == Brightness.dark ? darkShadow : lightShadow;
  String? fontOf(String slot) => fonts[slot];

  ThemeData theme(Brightness brightness, {AppDensity? density}) {
    final shadow = shadowOf(brightness);
    return AppTheme.materialFor(
      brightness: brightness,
      colorTokens: brightness == Brightness.dark ? dark : light,
      radius: radiusPx.clamp(0, 40).toDouble(),
      fontFamily: bodyFont,
      surfaceOpacity: surfaceOpacity,
      surfaceBlur: surfaceBlur,
      shadowColor: Color(shadow.color),
      shadowOpacity: shadow.opacity,
      shadowBlur: shadow.blur,
      density: density,
    );
  }

  Map<String, Object?> toJson() => {
    if (schema != null) r'$schema': schema,
    'id': id, 'name': name, 'schemaVersion': 2,
    'light': light, 'dark': dark,
    if (hasFonts) 'fonts': fonts,
    'radius': jsonNumber(radius), 'spacing': jsonNumber(spacing),
    'tracking': {for (final entry in tracking.entries) entry.key: jsonNumber(entry.value)},
    'shadow': {'light': lightShadow.toJson(), 'dark': darkShadow.toJson()},
    if (surfaceOpacity != null) 'surfaceOpacity': jsonNumber(surfaceOpacity!),
    if (surfaceBlur != null) 'surfaceBlur': jsonNumber(surfaceBlur!),
    if (hasMotion) 'motion': {
      if (motionEnabled != null) 'enabled': motionEnabled,
      if (motionIntensity != null) 'intensity': motionIntensity!.name,
      if (motionCustomDurationMultiplier != null) 'durationMultiplier': jsonNumber(motionCustomDurationMultiplier!),
      if (motionCustomPressScale != null) 'pressScale': jsonNumber(motionCustomPressScale!),
      if (motionCustomEnterOffset != null) 'enterOffset': jsonNumber(motionCustomEnterOffset!),
      if (motionCustomCurve != null) 'curve': motionCustomCurve!.wireName,
    },
    if (shadowsDerived != null) 'shadowsDerived': shadowsDerived,
  };

  String get json => const JsonEncoder.withIndent('  ').convert(toJson());
}

Map<String, Object?> _map(Object? value, String path) {
  if (value is! Map) throw ThemeAppException('$path must be an object');
  return {for (final entry in value.entries) entry.key.toString(): entry.value};
}

String? _string(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value == null) return null;
  if (value is! String) throw ThemeAppException('preset.$key must be a string');
  return value;
}

double? _number(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value == null) return null;
  if (value is! num) throw ThemeAppException('preset.$key must be a number');
  return value.toDouble();
}

Map<String, String> _colors(Object? value, String mode) {
  final map = _map(value, 'preset.$mode');
  final result = <String, String>{};
  for (final token in kAppColorTokenKeys) {
    final color = map[token];
    if (color is! String || !kAppHexColorPattern.hasMatch(color)) {
      throw ThemeAppException('preset.$mode.$token must be a valid hex color');
    }
    result[token] = color.toUpperCase();
  }
  return {for (final token in kAppColorTokenKeys) token: result[token]!};
}

Map<String, double> _tracking(Object? value) {
  final map = _map(value, 'preset.tracking');
  final result = <String, double>{};
  for (final step in kAppTrackingSteps) {
    final number = map[step];
    if (number != null) {
      if (number is! num) throw ThemeAppException('preset.tracking.$step must be a number');
      result[step] = number.toDouble();
    }
  }
  if (!result.containsKey('normal')) throw const ThemeAppException('preset.tracking.normal is required');
  return result;
}

Map<String, String> _fonts(Object? value) {
  if (value == null) return {};
  final map = _map(value, 'preset.fonts');
  return {
    for (final slot in kAppFontSlots)
      if (map[slot] is String && (map[slot] as String).isNotEmpty) slot: map[slot] as String,
  };
}

({bool? enabled, MotionIntensity? intensity, double? durationMultiplier, double? pressScale, double? enterOffset, MotionCurveName? curve}) _parseMotion(Object? value) {
  if (value == null) return (enabled: null, intensity: null, durationMultiplier: null, pressScale: null, enterOffset: null, curve: null);
  final map = _map(value, 'preset.motion');
  final rawIntensity = map['intensity']?.toString();
  final intensity = rawIntensity == null ? null : MotionIntensity.values.firstWhere((item) => item.name == rawIntensity, orElse: () => throw ThemeAppException('Invalid motion intensity: $rawIntensity'));
  final rawCurve = map['curve']?.toString();
  return (
    enabled: map['enabled'] as bool?, intensity: intensity,
    durationMultiplier: (map['durationMultiplier'] as num?)?.toDouble(),
    pressScale: (map['pressScale'] as num?)?.toDouble(),
    enterOffset: (map['enterOffset'] as num?)?.toDouble(),
    curve: rawCurve == null ? null : MotionCurveName.parse(rawCurve),
  );
}
