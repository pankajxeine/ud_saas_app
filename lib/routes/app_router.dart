import 'package:flutter/material.dart';

import '../core/config/allowed_paths.dart';
import '../core/config/app_logger.dart';
import '../core/config/environment.dart';
import '../core/navigation/app_route_definition.dart';
import '../core/navigation/app_route_location.dart';
import '../core/utils/security_utils.dart';
import '../core/layouts/app_layout.dart';
import '../core/widgets/common/app_not_found_page.dart';
import '../features/auth/login_page.dart';
import '../features/cpanel/cpanel_category_page.dart';
import '../features/cpanel/cpanel_module_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/example/data_grid_page.dart';
// import '../features/example/onboarding_page.dart';
import '../features/settings/settings.dart';
import 'app_routes_constants.dart';
import 'generated_module_routes.dart';

/// Imperative route configuration shared by DashcnApp and app navigation.
class AppRouteConfig {
  static final _log = AppLogger.getLogger('AppRouteConfig');
  static const _pageTransitionDuration = Duration(milliseconds: 180);
  static const _pageReverseTransitionDuration = Duration(milliseconds: 120);
  static final List<AppRouteDefinition> _prioritizedGeneratedRoutes =
      List<AppRouteDefinition>.of(generatedModuleRoutes)..sort(
        (AppRouteDefinition first, AppRouteDefinition second) =>
            second.specificity.compareTo(first.specificity),
      );

  /// Dynamic routes are resolved by [onGenerateRoute], including module IDs.
  static const Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{};

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) =>
      _routeForLocation(settings.name, settings: settings);

  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) {
    final RouteSettings settings = RouteSettings(name: initialRoute);
    final Route<dynamic>? route = _routeForLocation(
      initialRoute,
      settings: settings,
    );
    return <Route<dynamic>>[route ?? onUnknownRoute(settings)!];
  }

  static Route<dynamic>? onUnknownRoute(RouteSettings settings) => _pageRoute(
    settings,
    (_) => const AppNotFoundPage(title: 'Page not found'),
  );

  static PageRoute<T> pageRouteBuilder<T>(
    RouteSettings settings,
    WidgetBuilder builder,
  ) => _pageRoute<T>(settings, builder);

  static Route<dynamic>? _routeForLocation(
    String? location, {
    required RouteSettings settings,
  }) {
    if (location == null || location.isEmpty) {
      return null;
    }

    final Uri uri = Uri.parse(location);
    final String path = uri.path.isEmpty ? '/' : uri.path;
    final String? redirectedLocation = _redirectLocation(uri);
    if (redirectedLocation != null) {
      return _routeForLocation(
        redirectedLocation,
        settings: RouteSettings(name: redirectedLocation),
      );
    }

    if (path == ApplicationRoutesConstants.login) {
      return _pageRoute(settings, (_) => LoginPage());
    }

    Widget? page = _buildGeneratedModulePage(uri);
    page ??= _buildStaticPage(uri);
    if (page == null) {
      return null;
    }

    return _pageRoute(
      settings,
      (_) => AppRouteLocation(
        location: path,
        child: AppLayout(body: page!),
      ),
    );
  }

  static String? _redirectLocation(Uri uri) {
    final String path = uri.path.isEmpty ? '/' : uri.path;
    _log.debug('BEGIN: redirect');
    _log.debug('redirect - uri: $uri');
    _log.debug('authPaths: $authPaths');

    if (authPaths.any((String authPath) => path.startsWith(authPath))) {
      _log.debug('END: redirect null - with authPaths');
      return null;
    }

    _log.debug('isUserLoggedIn: ${SecurityUtils.isUserLoggedIn()}');
    if (!SecurityUtils.isUserLoggedIn() &&
        !SecurityUtils.isAllowedPath(uri.toString())) {
      _log.debug('END: isUserLoggedIn is false and isAllowedPath is false');
      if (uri.toString() != ApplicationRoutesConstants.login) {
        return ApplicationRoutesConstants.login;
      }
      return null;
    }

    if (ProfileConstants.isProduction &&
        SecurityUtils.isTokenExpired() &&
        uri.toString() != ApplicationRoutesConstants.login) {
      _log.debug('END: redirect - jwtToken is expired');
      return ApplicationRoutesConstants.login;
    }

    _log.debug('END: redirect return null');
    return null;
  }

  static Widget? _buildGeneratedModulePage(Uri uri) {
    for (final AppRouteDefinition route in _prioritizedGeneratedRoutes) {
      final Widget? page = route.build(uri);
      if (page != null) {
        return page;
      }
    }
    return null;
  }

  static Widget? _buildStaticPage(Uri uri) {
    final List<String> segments = uri.pathSegments;
    final String path = uri.path.isEmpty ? '/' : uri.path;

    if (path == '/' ||
        path == ApplicationRoutesConstants.dashboard ||
        path == '/dashboard') {
      return const DashboardPage();
    }
    if (segments.length == 2 && segments.first == 'cpanel') {
      return CpanelCategoryPage(categorySlug: segments[1]);
    }
    if (segments.length == 3 &&
        segments[0] == 'cpanel' &&
        segments[1] == 'modules') {
      return CpanelModulePage(moduleSlug: segments[2]);
    }
    // if (path == '/orders') {
    //   return const DataGridPage();
    // }
    if (path == '/products') {
      return const DataGridPage();
    }
    // if (path == R.forms) {
    //   return const DynamicFormPage();
    // }
    if (path == R.components) {
      return const DataGridPage();
    }
    if (path == '/settings') {
      return const SettingsPage();
    }
    if (path == '/installation') {
      return const DataGridPage();
    }
    return null;
  }

  static PageRoute<T> _pageRoute<T>(
    RouteSettings settings,
    WidgetBuilder builder,
  ) => PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: _pageTransitionDuration,
    reverseTransitionDuration: _pageReverseTransitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final CurvedAnimation curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(curve),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
  );
}
