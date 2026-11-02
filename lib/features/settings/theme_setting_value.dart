import 'package:ud_sass_app/ui/dashcn/theme.dart' as dashcn;

const Map<String, dashcn.ThemeMode> themeModes = {
  'Light': dashcn.ThemeMode.light,
  'Dark': dashcn.ThemeMode.dark,
  'System': dashcn.ThemeMode.system,
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

const Map<String, dashcn.Density> densityOptions = {
  'Compact': dashcn.Density.compactDensity,
  'Reduced': dashcn.Density.reducedDensity,
  'Default': dashcn.Density.defaultDensity,
  'Spacious': dashcn.Density.spaciousDensity,
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
