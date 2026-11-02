import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ud_sass_app/core/theme/theme_app.dart';
import 'package:ud_sass_app/data/layout_setting.dart';
import 'package:ud_sass_app/state/app_storage.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart' as dashcn;

import 'package:ud_sass_app/core/theme/theme_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('loads the neutral Dashcn theme when no preference is saved', () async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final LayoutSettings settings = await loadSettings(preferences);

    expect(settings.presetId, 'neutral');
    expect(settings.themeMode, dashcn.ThemeMode.dark);
    expect(settings.initialPath, '/login');
    expect(settings.darkTheme.colors.brightness, Brightness.dark);
    expect(settings.lightTheme.colors.brightness, Brightness.light);
  });

  test('restores a saved Dashcn theme document and mode', () async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final ThemeApp document = ThemeApp.fromPreset('amber-minimal');
    await preferences.setString(kAppThemeDocumentKey, document.json);
    await preferences.setString('themeMode', 'light');

    final LayoutSettings settings = await loadSettings(preferences);

    expect(settings.presetId, 'amber-minimal');
    expect(settings.themeMode, dashcn.ThemeMode.light);
    expect(
      settings.lightTheme.colors.primary,
      document.theme(Brightness.light).colors.primary,
    );
    expect(settings.darkTheme.colors.brightness, Brightness.dark);
  });

  test('maps the legacy zinc preset to the Dashcn neutral preset', () async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('themePresetId', 'zinc');
    await preferences.setDouble('radius', 0.75);
    await preferences.setDouble('scaling', 1.15);

    final LayoutSettings settings = await loadSettings(preferences);

    expect(settings.presetId, 'neutral');
    expect(settings.lightTheme.radius, 0.75);
    expect(settings.darkTheme.scaling, 1.15);
  });

  test('migrates a legacy custom color into the Dashcn theme document', () async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('themePresetId', 'custom');
    await preferences.setString(
      'colorSchemeDark',
      '{"primary":"#123456"}',
    );

    final LayoutSettings settings = await loadSettings(preferences);

    expect(settings.presetId, 'neutral');
    expect(settings.darkTheme.colors.primary, const Color(0xFF123456));
  });
}
