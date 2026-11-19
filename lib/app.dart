import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ud_sass_app/routes/route_repository.dart';

import 'core/motion/motion_scope.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_cubit.dart';
import 'core/theme/bloc/theme_state.dart';
import 'features/auth/bloc/auth_login_bloc.dart';
import 'i10n/i10n.dart';
import 'routes/app_route.dart';
import 'web_bridge.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late Future<GoRouter> _routerFuture;

  bool _webReadyNotified = false;

  @override
  void initState() {
    super.initState();
    _initializeRouter();
  }

  void _initializeRouter() {
    _routerFuture = AppRoute.initialize(
      routeRepository: RouteRepository(),
      authBloc: context.read<AuthLoginBloc>(),
      initialLocation: '/dashboard',

      // Enable this when using database-driven routes.
      // routeRepository: RouteRepository(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return FutureBuilder<GoRouter>(
          future: _routerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _buildLoadingApp(state);
            }

            if (snapshot.hasError) {
              return _buildErrorApp(state, snapshot.error);
            }

            final router = snapshot.data!;

            _notifyWebReadyOnce();

            return _buildApplication(state: state, router: router);
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Application
  // ---------------------------------------------------------------------------

  Widget _buildApplication({
    required ThemeState state,
    required GoRouter router,
  }) {
    final settings = state.settings;

    final isCupertino = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    if (isCupertino) {
      return CupertinoApp.router(
        debugShowCheckedModeBanner: false,
        title: 'UD SaaS',
        theme: settings.cupertinoTheme(AppTheme.brightness(settings.themeMode)),
        routerConfig: router,
        localizationsDelegates: const [
          S.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        locale: const Locale('en'),
        supportedLocales: S.supportedLocales,
        builder: (context, child) {
          return MotionScope(child: child ?? const SizedBox.shrink());
        },
      );
    }

    final activeTheme = settings.lightTheme;

    _notifyWebThemeChanged(activeTheme);

    debugPrint("settings.themeMode : $settings.themeMode");
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'UD SaaS',
      // theme: settings.lightTheme,
      // darkTheme: settings.darkTheme,
      theme: AppTheme.lightMaterialFor(seedColor: settings.seedColor),
      darkTheme: AppTheme.darkMaterialFor(seedColor: settings.seedColor),
      themeMode: AppTheme.materialMode(settings.themeMode),
      routerConfig: router,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('en'),
      supportedLocales: S.supportedLocales,
      builder: (context, child) {
        return MotionScope(child: child ?? const SizedBox.shrink());
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  Widget _buildLoadingApp(ThemeState state) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: state.settings.lightTheme,
      darkTheme: state.settings.darkTheme,
      themeMode: AppTheme.materialMode(state.settings.themeMode),
      home: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }

  // ---------------------------------------------------------------------------
  // Error
  // ---------------------------------------------------------------------------

  Widget _buildErrorApp(ThemeState state, Object? error) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: state.settings.lightTheme,
      darkTheme: state.settings.darkTheme,
      themeMode: AppTheme.materialMode(state.settings.themeMode),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Unable to initialize application',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  error?.toString() ?? 'Unknown error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    setState(_initializeRouter);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Web bridge
  // ---------------------------------------------------------------------------

  void _notifyWebThemeChanged(ThemeData theme) {
    if (!kIsWeb) return;

    final colors = theme.colorScheme;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      dispatchWebThemeChanged({
        'background': AppTheme.colorHex(colors.surface),
        'foreground': AppTheme.colorHex(colors.onSurface),
        'primary': AppTheme.colorHex(colors.primary),
      });
    });
  }

  void _notifyWebReadyOnce() {
    if (!kIsWeb || _webReadyNotified) return;

    _webReadyNotified = true;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      dispatchWebAppReady();
    });
  }
}
