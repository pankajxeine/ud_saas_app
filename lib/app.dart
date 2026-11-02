import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:ud_sass_app/data/layout_setting.dart';
import 'package:ud_sass_app/core/theme/theme_utils.dart';
import 'package:ud_sass_app/core/theme/theme_cubit.dart';
import 'package:ud_sass_app/core/theme/theme_state.dart';
import 'package:ud_sass_app/ui/dashcn/components/app.dart';
import 'package:ud_sass_app/ui/dashcn/primitives.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart' as dashcn;

import 'i10n/i10n.dart';
import 'core/motion/motion_scope.dart';
import 'routes/app_router.dart';
import 'web_bridge.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  Brightness? _lastBrightness;
  dashcn.ThemeColors? _lastColors;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (BuildContext context, ThemeState state) {
        final LayoutSettings settings = state.settings;
        final Brightness effectiveBrightness = switch (settings.themeMode) {
          dashcn.ThemeMode.light => Brightness.light,
          dashcn.ThemeMode.dark => Brightness.dark,
          dashcn.ThemeMode.system =>
            WidgetsBinding.instance.platformDispatcher.platformBrightness,
        };
        final dashcn.ThemeData effectiveTheme =
            effectiveBrightness == Brightness.dark
            ? settings.darkTheme
            : settings.lightTheme;
        _notifyWebThemeChanged(effectiveTheme);

        return DashcnApp(
          debugShowCheckedModeBanner: false,
          title: 'shadcn/ui Registry Flutter Widget',
          color: settings.lightTheme.colors.primary,
          theme: settings.lightTheme,
          darkTheme: settings.darkTheme,
          themeMode: settings.themeMode,
          // The fixed route table stays empty because generated module routes
          // contain path parameters and are resolved by onGenerateRoute.
          routes: AppRouteConfig.routes,
          // Selects the saved startup location, including browser deep links.
          initialRoute: settings.initialPath,
          // Resolves named navigation requests and dynamic module paths.
          onGenerateRoute: AppRouteConfig.onGenerateRoute,
          // Treats an initial deep link as one route instead of splitting it into
          // intermediate Navigator routes that do not exist in this app.
          onGenerateInitialRoutes: AppRouteConfig.onGenerateInitialRoutes,
          // Shows the app's not-found page for unknown named routes.
          onUnknownRoute: AppRouteConfig.onUnknownRoute,
          // Applies the same page transition to generated and fixed routes.
          pageRouteBuilder: AppRouteConfig.pageRouteBuilder,
          localizationsDelegates: const [
            S.delegate,
            DashcnLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: const Locale('en'),
          supportedLocales: S.supportedLocales,
          builder: (BuildContext context, Widget? child) =>
              MotionScope(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }

  void _notifyWebThemeChanged(dashcn.ThemeData data) {
    if (!kIsWeb) return;
    final dashcn.ThemeColors colors = data.colors;
    if (_lastBrightness == colors.brightness && _lastColors == colors) {
      return;
    }
    _lastBrightness = colors.brightness;
    _lastColors = colors;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      dispatchWebThemeChanged({
        'background': toHexColor(colors.background),
        'foreground': toHexColor(colors.foreground),
        'primary': toHexColor(colors.primary),
      });
    });
  }
}
