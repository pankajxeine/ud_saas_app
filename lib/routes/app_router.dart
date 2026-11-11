import 'package:flutter/material.dart';

import 'allowed_paths.dart';
import '../core/config/app_logger.dart';
import '../core/config/environment.dart';
import '../core/layouts/app_layout.dart';
import '../core/widgets/common/app_not_found_page.dart';
import '../core/utils/security_utils.dart';
import '../core/navigation/app_route_definition.dart';
import '../core/navigation/app_route_location.dart';
import 'app_routes_constants.dart';

// Authentication pages
import '../features/auth/login_page.dart';

// Dashboard and application pages
import '../../features/dashboard/dashboard_page.dart';
import '../../features/cpanel/cpanel_category_page.dart';
import '../../features/cpanel/cpanel_module_page.dart';
import '../../features/example/data_grid_page.dart';
import '../../features/settings/settings_page.dart';

// Generated module routes
import 'generated_module_routes.dart';
import 'metadata_route_match.dart';

import '../metadata_designer/modules/modules.dart';
import '../metadata_designer/module/module.dart';
import '../metadata_designer/module_version/module_version.dart';

class AppRouter {
  AppRouter._();

  static final AppLogger _logger = AppLogger();

  // ------------------------------------------------------------
  // ROUTE CONFIGURATION
  // ------------------------------------------------------------

  static const Map<String, WidgetBuilder> routes = {};

  static final List<AppRouteDefinition> _generatedRoutes =
      List<AppRouteDefinition>.from(generatedModuleRoutes)
        ..sort((a, b) => b.specificity.compareTo(a.specificity));

  static const Duration _transitionDuration = Duration(milliseconds: 220);

  static const Curve _transitionCurve = Curves.easeOutCubic;

  // ------------------------------------------------------------
  // FLUTTER ROUTER CALLBACKS
  // ------------------------------------------------------------
  // ------------------------------------------------------------

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return _resolveRoute(settings);
  }

  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) {
    final route = _resolveRoute(RouteSettings(name: initialRoute));

    // Return one route. Flutter should not split nested deep links
    // into intermediate routes.
    return [route];
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    _logger.debug('Unknown route: ${settings.name}');

    return _buildPageRoute(
      settings: settings,
      page: const AppNotFoundPage(title: "Page Not Found"),
      useLayout: false,
    );
  }

  // ------------------------------------------------------------
  // MAIN ROUTE RESOLVER
  // ------------------------------------------------------------

  static Route<dynamic> _resolveRoute(RouteSettings settings) {
    final uri = _parseUri(settings.name);

    if (uri == null) {
      return _notFoundRoute(settings);
    }

    _logger.debug('Resolving route: ${uri.toString()}');

    // 1. Authentication and permission redirects.
    final redirect = _resolveRedirect(uri);

    if (redirect != null) {
      return _resolveRoute(RouteSettings(name: redirect));
    }

    // 2. Resolve page.
    final page = _resolvePage(uri);

    if (page == null) {
      return _notFoundRoute(settings);
    }

    // 3. Login is standalone; authenticated pages use shared layout.
    final useLayout = !_isAuthPath(uri.path);

    return _buildPageRoute(
      settings: settings,
      page: page,
      useLayout: useLayout,
      location: uri.path,
    );
  }
  // ------------------------------------------------------------
  // URI PARSING AND NORMALIZATION
  // ------------------------------------------------------------

  static Uri? _parseUri(String? location) {
    if (location == null || location.trim().isEmpty) {
      return Uri(path: ApplicationRoutesConstants.dashboard);
    }

    try {
      final parsed = Uri.parse(location);

      var path = parsed.path;

      // Normalize repeated trailing slashes.
      if (path.length > 1) {
        path = path.replaceFirst(RegExp(r'/+$'), '');
      }

      if (path.isEmpty) {
        path = '/';
      }

      return parsed.replace(path: path);
    } catch (error, stackTrace) {
      _logger.error(
        'Invalid route URI: $location , error: $error, stackTrace: $stackTrace',
      );

      return null;
    }
  }

  // ------------------------------------------------------------
  // AUTHENTICATION AND REDIRECTS
  // ------------------------------------------------------------

  static String? _resolveRedirect(Uri uri) {
    final path = uri.path;

    final isLogin = _isAuthPath(path);
    final isLoggedIn = SecurityUtils.isUserLoggedIn();

    // Unauthenticated user.
    if (!isLoggedIn && !isLogin) {
      return ApplicationRoutesConstants.login;
    }

    // Already authenticated.
    if (isLoggedIn && isLogin) {
      return ApplicationRoutesConstants.dashboard;
    }

    // Token expiry.
    if (isLoggedIn &&
        ProfileConstants.isProduction &&
        SecurityUtils.isTokenExpired()) {
      return ApplicationRoutesConstants.login;
    }

    // Route authorization.
    if (!isAllowedPath(path)) {
      return ApplicationRoutesConstants.dashboard;
    }

    return null;
  }

  static bool _isAuthPath(String path) {
    return path == ApplicationRoutesConstants.login;
  }

  // ------------------------------------------------------------
  // PAGE RESOLUTION
  // ------------------------------------------------------------

  static Widget? _resolvePage(Uri uri) {
    // 1. Metadata routes.
    final metadataPage = _resolveMetadataRoute(uri);

    if (metadataPage != null) {
      return metadataPage;
    }

    // 2. Generated module routes.
    final generatedPage = _resolveGeneratedRoute(uri);

    if (generatedPage != null) {
      return generatedPage;
    }

    // 3. Static routes.
    return _resolveStaticRoute(uri);
  }
  // ------------------------------------------------------------
  // METADATA ROUTES
  // ------------------------------------------------------------

  static Widget? _resolveMetadataRoute(Uri uri) {
    final match = MetadataRouteMatch.parse(uri);

    if (match == null) {
      return null;
    }

    switch (match.type) {
      case MetadataRouteType.moduleList:
        return const MetadataModules();

      case MetadataRouteType.createModule:
        return const MetadataModules();

      case MetadataRouteType.moduleDetails:
        return MetadataModule(
          key: ValueKey('metadata-module-${match.moduleId}'),
          moduleId: match.moduleId!,
        );

      case MetadataRouteType.createVersion:
        return const MetadataModules();

      case MetadataRouteType.versionDetails:
        return MetadataVersionDesign(
          key: ValueKey(
            'metadata-version-${match.moduleId}-${match.versionId}',
          ),
          moduleId: match.moduleId!,
          versionId: match.versionId!,
        );
    }
  }
  // ------------------------------------------------------------
  // GENERATED DATABASE-DRIVEN ROUTES
  // ------------------------------------------------------------

  static Widget? _resolveGeneratedRoute(Uri uri) {
    for (final route in _generatedRoutes) {
      if (!route.matches(uri)) {
        continue;
      }

      _logger.debug('Generated route matched: ${uri.path}');

      return route.build(uri);
    }

    return null;
  }
  // ------------------------------------------------------------
  // STATIC ROUTES
  // ------------------------------------------------------------

  static Widget? _resolveStaticRoute(Uri uri) {
    final path = uri.path;
    final segments = uri.pathSegments;

    switch (path) {
      case '/':
      case ApplicationRoutesConstants.dashboard:
        return const DashboardPage();

      case ApplicationRoutesConstants.login:
        return const LoginPage();

      case '/products':
        return const DataGridPage();

      case '/modules':
        return const MetadataModules();

      case '/settings':
        return const SettingsPage();
    }

    // Cpanel category route.
    if (segments.length == 2 &&
        segments[0] == 'cpanel' &&
        segments[1].isNotEmpty) {
      return CpanelCategoryPage(categorySlug: segments[1]);
    }

    // Cpanel module route.
    if (segments.length == 3 &&
        segments[0] == 'cpanel' &&
        segments[1].isNotEmpty &&
        segments[2].isNotEmpty) {
      return CpanelModulePage(moduleSlug: segments[2]);
    }

    return null;
  }

  // ------------------------------------------------------------
  // PAGE ROUTE BUILDER
  // ------------------------------------------------------------

  static Route<dynamic> _buildPageRoute({
    required RouteSettings settings,
    required Widget page,
    required bool useLayout,
    String? location,
  }) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: _transitionDuration,
      reverseTransitionDuration: _transitionDuration,

      pageBuilder: (context, animation, secondaryAnimation) {
        if (!useLayout) {
          return page;
        }

        return AppRouteLocation(
          location: location ?? settings.name ?? '/',
          child: AppLayout(body: page),
        );
      },

      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: _transitionCurve,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.015, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // NOT FOUND
  // ------------------------------------------------------------

  static Route<dynamic> _notFoundRoute(RouteSettings settings) {
    _logger.debug('No route matched: ${settings.name}');

    return _buildPageRoute(
      settings: settings,
      page: const AppNotFoundPage(title: "Page Not Found"),
      useLayout: false,
    );
  }
}
