import 'package:ud_sass_app/ui/shadcn/shared/theme/theme.dart';

const Map<String, String> themeModes = {
  'Light': 'light',
  'Dark': 'dark',
};

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

const Map<String, Density> densityOptions = {
  'Compact': Density.compactDensity,
  'Reduced': Density.reducedDensity,
  'Default': Density.defaultDensity,
  'Spacious': Density.spaciousDensity,
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

// List<ThemePreset> get _presetOptions => DocsThemeController.presets;
