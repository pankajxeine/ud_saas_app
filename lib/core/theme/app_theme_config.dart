import 'package:flutter/widgets.dart';

import 'theme_state.dart';

class AppThemeConfig extends InheritedWidget {
  const AppThemeConfig({
    super.key,
    required this.density,
    required this.surfaceOpacity,
    required this.surfaceBlue,
    required super.child,
  });

  final AppDensity density;
  final double surfaceOpacity;
  final double surfaceBlue;

  static AppThemeConfig of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppThemeConfig>();
    assert(result != null, 'no AppThemeConfig found in context');
    return result!;
  }

  static AppThemeConfig? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppThemeConfig>();
  //double spacing(double base) => base * density.spacingMultiplier;

  @override
  bool updateShouldNotify(AppThemeConfig old) =>
      density != old.density ||
      surfaceOpacity != old.surfaceOpacity ||
      surfaceBlue != old.surfaceBlue;
}
