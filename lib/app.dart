import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ud_sass_app/core/theme/theme_cubit.dart';
import 'package:ud_sass_app/core/theme/theme_state.dart';
import 'package:ud_sass_app/data/layout_setting.dart';
import 'package:ud_sass_app/ui/shadcn/components/layout/app/app.dart';
import 'package:ud_sass_app/ui/shadcn/components/display/keyboard_shortcut/keyboard_shortcut.dart';
import 'package:ud_sass_app/ui/shadcn/components/form/history/history.dart';
import 'package:ud_sass_app/ui/shadcn/components/overlay/drawer/drawer.dart';
import 'package:ud_sass_app/ui/shadcn/components/overlay/eye_dropper/eye_dropper.dart';
import 'package:ud_sass_app/ui/shadcn/components/utility/error_system/error_system.dart';
import 'package:ud_sass_app/ui/shadcn/components/utility/shadcn_localizations/shadcn_localizations.dart';
import 'package:ud_sass_app/ui/shadcn/shared/theme/color_scheme.dart'
    as shadcn_colors;
import 'i10n/i10n.dart';
import 'web_bridge.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_utils.dart';

import 'routes/app_router.dart';

class AppRoot extends StatefulWidget {
  final Map<String, Object?> appConfig;
  final LayoutSettings settings;
  final SharedPreferences prefs;

  const AppRoot(
      {super.key,
      required this.appConfig,
      required this.settings,
      required this.prefs,
      ss});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late final AppThemeCubit themeCubit;
  late GoRouter router;
  late final HubAppScope _appErrorScope = HubAppScope('docs.app');
  Brightness? _lastBrightness;
  shadcn_colors.ColorScheme? _lastScheme;

  AppThemeData _themeDataFromState(AppThemeState state) {
    return AppThemeData(
      colorScheme: state.brightness == Brightness.dark
          ? state.preset.dark
          : state.preset.light,
      radius: state.radius ?? 0.25,
      scaling: state.scaling,
      surfaceOpacity: state.surfaceOpacity,
      surfaceBlur: state.surfaceBlur,
      fontSize: state.fontSize,
      density: state.density.spacingMultiplier,
      spacing: state.spacing,
      tracking: state.tracking,
      shadows: state.shadows,
    );
  }

  @override
  void initState() {
    super.initState();
    themeCubit = AppThemeCubit(widget.prefs);
    router = AppGoRouterConfig.testRouter;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppThemeCubit>.value(
      value: themeCubit,
      child: BlocBuilder<AppThemeCubit, AppThemeState>(
        builder: (context, state) {
          final data = _themeDataFromState(state);
          _notifyWebThemeChanged(data);
          return AppThemeScope(
            data: data,
            child: ShadcnApp.router(
              debugShowCheckedModeBanner: false,
              title: 'shadcn/ui Registry Flutter Widget',
              theme: data.toShadcnTheme(),
              routeInformationProvider: router.routeInformationProvider,
              routeInformationParser: router.routeInformationParser,
              routerDelegate: router.routerDelegate,
              backButtonDispatcher: router.backButtonDispatcher,
              localizationsDelegates: const [
                S.delegate,
                ShadcnLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              locale: const Locale("en"),
              supportedLocales: S.supportedLocales,
              builder: (context, child) => KeyboardShortcutDisplayMapper(
                child: AppErrorGate.scope(
                  scope: _appErrorScope,
                  child: Stack(
                    children: [
                      DrawerOverlay(
                        child: RecentColorsScope(
                          child: EyeDropperLayer(
                            child: Material(
                              type: MaterialType.transparency,
                              child: child ?? const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: AppErrorBanner(
                              watchScopes: ['docs.app.banner'],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _notifyWebThemeChanged(AppThemeData data) {
    if (!kIsWeb) return;
    final brightness = data.colorScheme.brightness;
    if (_lastBrightness == brightness && _lastScheme == data.colorScheme) {
      return;
    }
    _lastBrightness = brightness;
    _lastScheme = data.colorScheme;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _dispatchWebThemeEvent(data);
    });
  }

  void _dispatchWebThemeEvent(AppThemeData data) {
    if (!kIsWeb) return;
    dispatchWebThemeChanged({
      'background': toHexColor(data.colorScheme.background),
      'foreground': toHexColor(data.colorScheme.foreground),
      'primary': toHexColor(data.colorScheme.primary),
    });
  }
}
