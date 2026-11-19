import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/navigation/app_router.dart';

import '../core/navigation/app_route_definition.dart';
import '../core/navigation/app_route_registry.dart';
import '../core/navigation/go_router_refresh_stream.dart';

import '../../core/utils/security_utils.dart';
import 'route_repository.dart';
import 'app_navigation_config.dart';

import '../features/auth/bloc/auth_login_bloc.dart';

class AppRoute {
  AppRoute._();

  static GoRouter? _router;
  static GoRouterRefreshStream? _authRefresh;

  /// Returns the initialized router.
  static GoRouter get router {
    final currentRouter = _router;

    if (currentRouter == null) {
      throw StateError(
        'AppRoute is not initialized. '
        'Call AppRoute.initialize() before accessing AppRoute.router.',
      );
    }

    return currentRouter;
  }

  static bool get isInitialized => _router != null;

  /// Initializes the application router.
  ///
  /// Static routes always come from AppNavigationConfig.routes.
  ///
  /// Dynamic routes are optional:
  /// - routeRepository == null: static routes only.
  /// - routeRepository != null: static + dynamic routes.
  ///
  /// If fetching dynamic routes fails, the error is propagated.
  static Future<GoRouter> initialize({
    required AuthLoginBloc authBloc,
    RouteRepository? routeRepository,
    String initialLocation = '/dashboard',
    String loginPath = '/login',
    String homePath = '/dashboard',
    GlobalKey<NavigatorState>? navigatorKey,
    List<NavigatorObserver> observers = const [],
  }) async {
    // 1. Register locally implemented dynamic page builders.
    AppNavigationConfig.registerPageBuilders();

    // 2. Fetch optional dynamic route definitions.
    final List<Map<String, dynamic>> dynamicJson;

    if (routeRepository != null) {
      dynamicJson = await routeRepository.getRoutes();
    } else {
      dynamicJson = const [];
    }

    debugPrint("****dynamicJson**** : $dynamicJson");
    // 3. Combine static and dynamic routes.
    final List<AppRouteDefinition> routes = AppNavigationConfig.buildRoutes(
      dynamicJson: dynamicJson,
    );

    // 4. Validate all route definitions.
    AppRouteRegistry.validate(routes);

    // 5. Validate essential route configuration.
    _validateConfiguration(
      routes: routes,
      loginPath: loginPath,
      homePath: homePath,
      initialLocation: initialLocation,
    );

    // 6. Create authentication stream listener.
    final newAuthRefresh = GoRouterRefreshStream(authBloc.stream);

    GoRouter? newRouter;
    for (final route in routes) {
      debugPrint(
        '******************'
        'ROUTE: ${route.name} | ${route.path} | '
        'pageType: ${route.pageType} | '
        'enabled: ${route.enabled} | '
        'auth: ${route.requiresAuth}'
        '***************',
      );
    }

    try {
      // 7. Create the new router.
      newRouter = AppRouter.create(
        routes: routes,
        initialLocation: initialLocation,
        loginPath: loginPath,
        homePath: homePath,
        navigatorKey: navigatorKey,
        observers: observers,

        // Important: automatically refresh auth redirects.
        refreshListenable: newAuthRefresh,

        isLoggedIn: SecurityUtils.isUserLoggedIn,
        isTokenExpired: SecurityUtils.isTokenExpired,
      );

      // 8. Replace previous router only after successful creation.
      final oldRouter = _router;
      final oldAuthRefresh = _authRefresh;

      _router = newRouter;
      _authRefresh = newAuthRefresh;

      // 9. Dispose previous resources.
      oldRouter?.dispose();
      oldAuthRefresh?.dispose();

      return newRouter;
    } catch (_) {
      newRouter?.dispose();
      newAuthRefresh.dispose();

      rethrow;
    }
  }

  /// Validates login, home and initial route configuration.
  static void _validateConfiguration({
    required List<AppRouteDefinition> routes,
    required String loginPath,
    required String homePath,
    required String initialLocation,
  }) {
    final enabledRoutes = routes.where((route) => route.enabled).toList();

    // Login route must exist and be public.
    final loginRoutes = enabledRoutes
        .where((route) => route.path == loginPath)
        .toList();

    if (loginRoutes.isEmpty) {
      throw StateError('Login route "$loginPath" is missing or disabled.');
    }

    if (loginRoutes.any((route) => route.requiresAuth)) {
      throw StateError(
        'Login route "$loginPath" must have requiresAuth: false.',
      );
    }

    // Home route must match an enabled route.
    final homeUri = Uri.parse(homePath);

    final hasHomeRoute = enabledRoutes.any(
      (route) => AppRouteRegistry.matchesPath(route.path, homeUri.path),
    );

    if (!hasHomeRoute) {
      throw StateError(
        'Home route "$homePath" does not match an enabled route.',
      );
    }

    // Initial location must match an enabled route.
    final initialUri = Uri.parse(initialLocation);

    final hasInitialRoute = enabledRoutes.any(
      (route) => AppRouteRegistry.matchesPath(route.path, initialUri.path),
    );

    if (!hasInitialRoute) {
      throw StateError(
        'Initial location "$initialLocation" does not match '
        'an enabled route.',
      );
    }
  }

  /// Disposes router and authentication listener.
  static void dispose() {
    final currentRouter = _router;
    final currentAuthRefresh = _authRefresh;

    _router = null;
    _authRefresh = null;

    currentRouter?.dispose();
    currentAuthRefresh?.dispose();
  }
}
