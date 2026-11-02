import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ud_sass_app/core/theme/theme_cubit.dart';
import 'package:ud_sass_app/core/theme/theme_utils.dart';
import 'package:ud_sass_app/features/settings/settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('renders the theme and layout settings sections', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final settings = await loadSettings(preferences);
    final ThemeCubit cubit = ThemeCubit(
      initialSettings: settings,
      preferences: preferences,
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider<ThemeCubit>.value(
        value: cubit,
        child: const MaterialApp(home: Scaffold(body: SettingsPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Theme settings'), findsOneWidget);
    expect(find.text('Live theme preview'), findsOneWidget);
    expect(find.text('Color tokens'), findsOneWidget);
    expect(find.text('Typography'), findsOneWidget);
    expect(find.text('Layout & shape'), findsOneWidget);
    expect(find.text('Surfaces & shadows'), findsOneWidget);
    expect(find.text('Motion'), findsOneWidget);

    await tester.ensureVisible(find.text('Foundation and actions'));
    await tester.tap(find.text('Foundation and actions'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Choose color').first);
    await tester.tap(find.byTooltip('Choose color').first);
    await tester.pumpAndSettle();
    expect(find.text('Edit color'), findsOneWidget);
  });

  testWidgets('keeps the settings scroll position after a theme update', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final settings = await loadSettings(preferences);
    final ThemeCubit cubit = ThemeCubit(
      initialSettings: settings,
      preferences: preferences,
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider<ThemeCubit>.value(
        value: cubit,
        child: const MaterialApp(home: Scaffold(body: SettingsPage())),
      ),
    );
    await tester.pumpAndSettle();

    final Finder controlsScroll = find.byKey(
      const ValueKey<String>('settings-controls-scroll'),
    );
    await tester.drag(controlsScroll, const Offset(0, -600));
    await tester.pumpAndSettle();

    final Finder scrollable = find.descendant(
      of: controlsScroll,
      matching: find.byType(Scrollable),
    );
    final double scrollBefore = tester
        .state<ScrollableState>(scrollable.first)
        .position
        .pixels;
    expect(scrollBefore, greaterThan(0));

    await cubit.setScaling(1.1);
    await tester.pumpAndSettle();

    final double scrollAfter = tester
        .state<ScrollableState>(scrollable.first)
        .position
        .pixels;
    expect(scrollAfter, scrollBefore);
  });

  testWidgets('opens settings in a mobile bottom sheet', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final settings = await loadSettings(preferences);
    final ThemeCubit cubit = ThemeCubit(
      initialSettings: settings,
      preferences: preferences,
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider<ThemeCubit>.value(
        value: cubit,
        child: const MaterialApp(home: Scaffold(body: SettingsPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Appearance & layout'), findsOneWidget);
    expect(find.text('Live theme preview'), findsOneWidget);
    expect(find.text('Color tokens'), findsNothing);

    await tester.tap(find.text('Customize appearance'));
    await tester.pumpAndSettle();

    expect(find.text('Color tokens'), findsOneWidget);
    expect(find.byTooltip('Close settings'), findsOneWidget);

    await tester.ensureVisible(find.text('Foundation and actions'));
    await tester.tap(find.text('Foundation and actions'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Choose color').first);
    await tester.tap(find.byTooltip('Choose color').first);
    await tester.pumpAndSettle();
    expect(find.text('Edit color'), findsOneWidget);
  });
}
