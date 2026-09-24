import 'package:flutter_test/flutter_test.dart';
import 'package:ud_sass_app/core/theme/app_theme.dart';
import 'package:ud_sass_app/ui/shadcn/shared/theme/color_scheme.dart'
    as shadcn_colors;
import 'package:ud_sass_app/ui/shadcn/shared/theme/theme.dart' as shadcn_theme;

void main() {
  test('font size selection scales the shadcn typography', () {
    final baseTheme = shadcn_theme.ThemeData();

    final smallTheme = AppThemeData(
      colorScheme: shadcn_colors.ColorSchemes.lightDefaultColor,
      radius: 0.5,
      scaling: 1.0,
      surfaceOpacity: 1.0,
      surfaceBlur: 0.0,
      fontSize: FontSize.small,
      density: baseTheme.density,
      spacing: baseTheme.spacing,
      tracking: baseTheme.tracking,
      shadows: baseTheme.shadows,
    ).toShadcnTheme();

    expect(smallTheme.typography.p.fontSize, 14.0);

    final largeTheme = AppThemeData(
      colorScheme: shadcn_colors.ColorSchemes.lightDefaultColor,
      radius: 0.5,
      scaling: 1.0,
      surfaceOpacity: 1.0,
      surfaceBlur: 0.0,
      fontSize: FontSize.large,
      density: baseTheme.density,
      spacing: baseTheme.spacing,
      tracking: baseTheme.tracking,
      shadows: baseTheme.shadows,
    ).toShadcnTheme();

    expect(largeTheme.typography.p.fontSize, 18.0);
  });
}
