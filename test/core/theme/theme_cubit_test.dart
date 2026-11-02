import 'package:flutter/material.dart' show Brightness;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ud_sass_app/core/theme/theme_app_edits.dart';
import 'package:ud_sass_app/core/theme/theme_cubit.dart';
import 'package:ud_sass_app/core/theme/theme_utils.dart';
import 'package:ud_sass_app/state/app_storage.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart' as dashcn;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists and emits the selected theme mode', () async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final settings = await loadSettings(preferences);
    final ThemeCubit cubit = ThemeCubit(
      initialSettings: settings,
      preferences: preferences,
    );
    addTearDown(cubit.close);

    await cubit.setThemeMode(dashcn.ThemeMode.light);

    expect(cubit.state.themeMode, dashcn.ThemeMode.light);
    expect(cubit.state.settings.initialPath, settings.initialPath);
    expect(preferences.getString(kPrefsThemeMode), 'light');
  });

  test('toggleTheme alternates between light and dark modes', () async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final settings = await loadSettings(preferences);
    final ThemeCubit cubit = ThemeCubit(
      initialSettings: settings,
      preferences: preferences,
    );
    addTearDown(cubit.close);

    await cubit.toggleTheme();
    expect(cubit.state.themeMode, dashcn.ThemeMode.light);

    await cubit.toggleTheme();
    expect(cubit.state.themeMode, dashcn.ThemeMode.dark);
    expect(preferences.getString(kPrefsThemeMode), 'dark');
  });

  test(
    'appearance controls update and persist the migrated theme settings',
    () async {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final settings = await loadSettings(preferences);
      final ThemeCubit cubit = ThemeCubit(
        initialSettings: settings,
        preferences: preferences,
      );
      addTearDown(cubit.close);

      await cubit.setPreset('amber-minimal');
      await cubit.setRadius(0.75);
      await cubit.setSurfaceOpacity(0.94);
      await cubit.setSurfaceBlur(8);
      await cubit.setScaling(1.15);
      await cubit.setDensity(dashcn.Density.compactDensity);

      expect(cubit.state.settings.presetId, 'amber-minimal');
      expect(cubit.state.settings.themeDocument.radius, 0.75);
      expect(cubit.state.settings.themeDocument.surfaceOpacity, 0.94);
      expect(cubit.state.settings.themeDocument.surfaceBlur, 8);
      expect(cubit.state.settings.scaling, 1.15);
      expect(cubit.state.settings.density, dashcn.Density.compactDensity);
      expect(
        preferences.getString(kAppThemeDocumentKey),
        cubit.state.settings.themeDocument.json,
      );

      final reloaded = await loadSettings(preferences);
      expect(reloaded.presetId, 'amber-minimal');
      expect(reloaded.themeDocument.radius, 0.75);
      expect(reloaded.themeDocument.surfaceOpacity, 0.94);
      expect(reloaded.themeDocument.surfaceBlur, 8);
      expect(reloaded.scaling, 1.15);
      expect(reloaded.density, dashcn.Density.compactDensity);
    },
  );

  test('theme edits persist color and typography tokens', () async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final settings = await loadSettings(preferences);
    final ThemeCubit cubit = ThemeCubit(
      initialSettings: settings,
      preferences: preferences,
    );
    addTearDown(cubit.close);

    await cubit.editTheme(
      (document) => document
          .withModeColor('primary', '#123456', Brightness.light)
          .withFont('heading', 'GeistSans')
          .withSpacingRem(0.75)
          .withTracking('wide', 0.05),
    );

    expect(cubit.state.settings.themeDocument.light['primary'], '#123456');
    expect(cubit.state.settings.themeDocument.headingFont, 'GeistSans');
    expect(cubit.state.settings.themeDocument.spacing, 0.75);
    expect(cubit.state.settings.themeDocument.tracking['wide'], 0.05);

    final reloaded = await loadSettings(preferences);
    expect(reloaded.themeDocument.light['primary'], '#123456');
    expect(reloaded.themeDocument.headingFont, 'GeistSans');
    expect(reloaded.themeDocument.spacing, 0.75);
    expect(reloaded.themeDocument.tracking['wide'], 0.05);
  });

  test('resetAppearance clears saved values and restores defaults', () async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final settings = await loadSettings(preferences);
    final ThemeCubit cubit = ThemeCubit(
      initialSettings: settings,
      preferences: preferences,
    );
    addTearDown(cubit.close);

    await cubit.setThemeMode(dashcn.ThemeMode.light);
    await cubit.setPreset('amber-minimal');
    await cubit.setScaling(1.15);
    await cubit.setDensity(dashcn.Density.compactDensity);

    await cubit.resetAppearance();

    expect(cubit.state.settings.presetId, 'neutral');
    expect(cubit.state.themeMode, dashcn.ThemeMode.dark);
    expect(cubit.state.settings.scaling, 1);
    expect(cubit.state.settings.density, isNull);
    expect(preferences.getString(kAppThemeDocumentKey), isNull);
  });
}
