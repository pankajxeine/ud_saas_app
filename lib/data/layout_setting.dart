import 'package:flutter/material.dart';
import 'package:ud_sass_app/ui/shadcn/shared/theme/color_scheme.dart'
    as shadcn_colors;
import 'package:ud_sass_app/ui/shadcn/shared/theme/theme.dart' as shadcn_theme;

class LayoutSettings {
  final shadcn_colors.ColorScheme colorScheme;
  final double radius;
  final double scaling;
  final double surfaceOpacity;
  final double surfaceBlur;
  final shadcn_theme.Density density;
  final String initialPath;
  final String presetId;
  final Brightness brightness;

  const LayoutSettings({
    required this.colorScheme,
    required this.radius,
    required this.scaling,
    required this.surfaceOpacity,
    required this.surfaceBlur,
    required this.density,
    required this.initialPath,
    required this.presetId,
    required this.brightness,
  });
}
