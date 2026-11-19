import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_route_definition.dart';
import 'app_route_registry.dart';
import '../layouts/app_layout.dart';
import '../layouts/layout/app_layout_config.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create({
    required List<AppRouteDefinition> routes,
    required String initialLocation,
    required FutureOr<bool> Function() isLoggedIn,
    required FutureOr<bool> Function() isTokenExpired,
    Listenable? refreshListenable,
    GlobalKey<NavigatorState>? navigatorKey,
    List<NavigatorObserver> observers = const [],
    String loginPath = '/login',
    String homePath = '/dashboard',
  }) {
    AppRouteRegistry.validate(routes);

    final enabledRoutes = routes.where((route) => route.enabled).toList();

    final publicRoutes = enabledRoutes
        .where((route) => !route.requiresAuth)
        .toList();

    final protectedRoutes = enabledRoutes
        .where((route) => route.requiresAuth)
        .toList();

    // Temporary diagnostics.
    debugPrint('========== APP ROUTER ==========');
    debugPrint('Initial location: $initialLocation');
    debugPrint('Public routes: ${publicRoutes.map((e) => e.path).toList()}');
    debugPrint(
      'Protected routes: ${protectedRoutes.map((e) => e.path).toList()}',
    );
    debugPrint('================================');

    final goRoutes = <RouteBase>[
      ...AppRouteRegistry.toGoRoutes(publicRoutes),

      if (protectedRoutes.isNotEmpty)
        ShellRoute(
          builder: (context, state, child) {
            return AppLayout(
              body: child,
              routesList: protectedRoutes,
              config: const AppLayoutConfig(
                appBarLayout: AppBarLayout.fullWidth,
                showAppBar: true,
                useBackgroundGradient: true,
                useSurfaceGradient: true,
              ),
            );
          },
          routes: AppRouteRegistry.toGoRoutes(protectedRoutes),
        ),
    ];

    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: initialLocation,
      observers: observers,
      refreshListenable: refreshListenable,
      routes: goRoutes,

      redirect: (context, state) async {
        final currentPath = state.uri.path;

        debugPrint('Router requested URI: ${state.uri}');
        debugPrint('Router requested path: $currentPath');

        final loggedIn = await isLoggedIn();
        final tokenExpired = loggedIn ? await isTokenExpired() : false;
        final authenticated = loggedIn && !tokenExpired;

        final isLoginPage = currentPath == loginPath;

        final isPublicRoute =
            isLoginPage ||
            publicRoutes.any(
              (route) => AppRouteRegistry.matchesPath(route.path, currentPath),
            );

        if (!authenticated) {
          if (isPublicRoute) return null;

          return Uri(
            path: loginPath,
            queryParameters: {'from': state.uri.toString()},
          ).toString();
        }

        if (isLoginPage) {
          final requestedPath = state.uri.queryParameters['from'];

          if (_isSafeInternalPath(requestedPath, loginPath: loginPath)) {
            return requestedPath;
          }

          return homePath;
        }

        return null;
      },
    );
  }

  /// Prevents external and unsafe redirects after login.
  static bool _isSafeInternalPath(String? path, {required String loginPath}) {
    if (path == null || path.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(path);

    if (uri == null) {
      return false;
    }

    if (!path.startsWith('/') || path.startsWith('//')) {
      return false;
    }

    if (uri.hasScheme || uri.hasAuthority) {
      return false;
    }

    if (uri.path == loginPath) {
      return false;
    }

    return true;
  }
}
