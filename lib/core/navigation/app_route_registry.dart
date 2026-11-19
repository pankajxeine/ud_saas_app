import 'package:go_router/go_router.dart';

import 'app_route_definition.dart';

class AppRouteRegistry {
  AppRouteRegistry._();

  // ---------------------------------------------------------------------------
  // Dynamic page builder registration
  // ---------------------------------------------------------------------------

  static final Map<String, DynamicPageBuilder> _pageBuilders = {};

  /// Register a page type once during application initialization.
  ///
  /// Example:
  /// registerPageType('module', (context, state, config) {
  ///   final id = state.pathParameters['id']!;
  ///   return ModulePage(id: id);
  /// });
  static void registerPageType(
    String pageType,
    DynamicPageBuilder builder, {
    bool replace = false,
  }) {
    final key = pageType.trim();

    if (key.isEmpty) {
      throw ArgumentError('Page type cannot be empty.');
    }

    if (_pageBuilders.containsKey(key) && !replace) {
      throw StateError('Page type already registered: $key');
    }

    _pageBuilders[key] = builder;
  }

  static void registerPageTypes(
    Map<String, DynamicPageBuilder> builders, {
    bool replace = false,
  }) {
    for (final entry in builders.entries) {
      registerPageType(entry.key, entry.value, replace: replace);
    }
  }

  static bool hasPageType(String pageType) {
    return _pageBuilders.containsKey(pageType);
  }

  static void unregisterPageType(String pageType) {
    _pageBuilders.remove(pageType);
  }

  // ---------------------------------------------------------------------------
  // Convert database JSON to route definitions
  // ---------------------------------------------------------------------------

  static AppRouteDefinition fromJson(Map<String, dynamic> json) {
    final name = _requiredString(json, 'name');
    final path = _requiredString(json, 'path');
    final pageType = _requiredString(json, 'pageType');

    final pageBuilder = _pageBuilders[pageType];

    if (pageBuilder == null) {
      throw StateError(
        'No Flutter page builder registered for pageType: $pageType',
      );
    }

    final rawConfig = json['pageConfig'];

    final pageConfig = rawConfig is Map
        ? Map<String, dynamic>.from(rawConfig)
        : <String, dynamic>{};

    return AppRouteDefinition(
      name: name,
      path: path,
      pageType: pageType,
      pageConfig: pageConfig,
      builder: (context, state) {
        return pageBuilder(context, state, pageConfig);
      },
      label: _optionalString(json['label']),
      localizationKey: _optionalString(json['localizationKey']),
      parentName: _optionalString(json['parentName']),
      icon: _optionalInt(json['icon']),
      selectedIcon: _optionalInt(json['selectedIcon']),
      section: _optionalString(json['section']),
      showInSidebar: _boolValue(json['showInSidebar']),
      showInRail: _boolValue(json['showInRail']),
      showInBottomBar: _boolValue(json['showInBottomBar']),
      showInBreadcrumb: json['showInBreadcrumb'] == null
          ? true
          : _boolValue(json['showInBreadcrumb']),
      bottomBarOrder: _intValue(json['bottomBarOrder']),
      permission: _optionalString(json['permission']),
      isDynamic: true,
      enabled: json['enabled'] == null ? true : _boolValue(json['enabled']),
      requiresAuth: json['requiresAuth'] == false ? false : true,
    );
  }

  static bool matchesPath(String template, String actualPath) {
    return _matches(_normalize(template), _normalize(actualPath));
  }

  /// Converts a list of API route JSON objects.
  ///
  /// Invalid routes throw an error instead of silently creating broken routes.
  static List<AppRouteDefinition> fromJsonList(List<dynamic> jsonList) {
    final routes = <AppRouteDefinition>[];

    for (final item in jsonList) {
      if (item is! Map) {
        throw const FormatException('Each route must be a JSON object.');
      }

      routes.add(fromJson(Map<String, dynamic>.from(item)));
    }

    return routes.where((route) => route.enabled).toList();
  }

  // ---------------------------------------------------------------------------
  // Route filtering
  // ---------------------------------------------------------------------------

  static List<AppRouteDefinition> sidebarRoutes(
    List<AppRouteDefinition> routes,
  ) {
    return routes
        .where((route) => route.enabled && route.showInSidebar)
        .toList();
  }

  static List<AppRouteDefinition> railRoutes(List<AppRouteDefinition> routes) {
    return routes.where((route) => route.enabled && route.showInRail).toList();
  }

  static List<AppRouteDefinition> bottomBarRoutes(
    List<AppRouteDefinition> routes,
  ) {
    final result = routes
        .where((route) => route.enabled && route.showInBottomBar)
        .toList();

    result.sort(
      (a, b) => (a.bottomBarOrder ?? 999).compareTo(b.bottomBarOrder ?? 999),
    );

    return result;
  }

  // ---------------------------------------------------------------------------
  // Route lookup
  // ---------------------------------------------------------------------------

  static AppRouteDefinition? byName(
    List<AppRouteDefinition> routes,
    String name,
  ) {
    for (final route in routes) {
      if (route.name == name && route.enabled) {
        return route;
      }
    }

    return null;
  }

  /// Finds a route by its actual URL.
  ///
  /// Example:
  /// Template: /modules/:id/version/:versionId
  /// Actual:   /modules/10/version/2
  static AppRouteDefinition? byPath(
    List<AppRouteDefinition> routes,
    String actualPath,
  ) {
    final normalizedActual = _normalize(actualPath);

    final matches = routes.where((route) {
      return route.enabled && _matches(route.path, normalizedActual);
    }).toList();

    if (matches.isEmpty) return null;

    matches.sort(
      (a, b) => _specificity(b.path).compareTo(_specificity(a.path)),
    );

    return matches.first;
  }

  /// Generates a concrete URL from a route name.
  ///
  /// Example:
  /// pathFor(routes, 'module', parameters: {'id': '123'})
  /// returns /modules/123
  static String pathFor(
    List<AppRouteDefinition> routes,
    String name, {
    Map<String, String> parameters = const {},
  }) {
    final route = byName(routes, name);

    if (route == null) {
      throw StateError('Route not found: $name');
    }

    final segments = _segments(route.path);
    final result = <String>[];

    for (final segment in segments) {
      if (segment.startsWith(':')) {
        final parameterName = segment.substring(1);
        final value = parameters[parameterName];

        if (value == null || value.isEmpty) {
          throw ArgumentError('Missing route parameter: $parameterName');
        }

        result.add(Uri.encodeComponent(value));
      } else {
        result.add(segment);
      }
    }

    return '/${result.join('/')}';
  }

  // ---------------------------------------------------------------------------
  // Navigation active state
  // ---------------------------------------------------------------------------

  static bool isActive(AppRouteDefinition destination, String currentPath) {
    final current = _normalize(currentPath);
    final target = _normalize(destination.path);

    if (_matches(target, current)) {
      return true;
    }

    // A static parent route remains selected for its child pages.
    if (!target.contains(':') &&
        target != '/' &&
        current.startsWith('$target/')) {
      return true;
    }

    return false;
  }

  // ---------------------------------------------------------------------------
  // Breadcrumbs
  // ---------------------------------------------------------------------------

  static List<AppRouteDefinition> breadcrumbs(
    List<AppRouteDefinition> routes,
    String currentPath,
  ) {
    final currentRoute = byPath(routes, currentPath);

    if (currentRoute == null) return [];

    final result = <AppRouteDefinition>[];
    final visited = <String>{};

    AppRouteDefinition? current = currentRoute;

    while (current != null) {
      if (!visited.add(current.name)) {
        throw StateError('Circular route parent reference: ${current.name}');
      }

      if (current.showInBreadcrumb) {
        result.insert(0, current);
      }

      final parentName = current.parentName;

      if (parentName == null) break;

      current = byName(routes, parentName);
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // GoRouter conversion
  // ---------------------------------------------------------------------------

  static List<RouteBase> toGoRoutes(
    List<AppRouteDefinition> routes, {
    bool validateRoutes = true,
  }) {
    final enabledRoutes = routes.where((route) => route.enabled).toList();

    if (validateRoutes) {
      validate(enabledRoutes);
    }

    return enabledRoutes.map((route) {
      return GoRoute(
        name: route.name,
        path: route.path,
        builder: route.builder,
        redirect: route.redirect,
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  static void validate(List<AppRouteDefinition> routes) {
    final names = <String>{};
    final paths = <String>{};

    for (final route in routes) {
      if (route.name.trim().isEmpty) {
        throw StateError('Route name cannot be empty.');
      }

      if (!route.path.startsWith('/')) {
        throw StateError('Route path must start with "/": ${route.path}');
      }

      if (!names.add(route.name)) {
        throw StateError('Duplicate route name: ${route.name}');
      }

      final normalizedPath = _normalize(route.path);

      if (!paths.add(normalizedPath)) {
        throw StateError('Duplicate route path: ${route.path}');
      }

      _validatePathParameters(route.path);
    }

    for (final route in routes) {
      final parentName = route.parentName;

      if (parentName != null && !names.contains(parentName)) {
        throw StateError(
          'Parent route "$parentName" not found for "${route.name}".',
        );
      }
    }

    _validateParentCycles(routes);
  }

  static void _validateParentCycles(List<AppRouteDefinition> routes) {
    final routeMap = {for (final route in routes) route.name: route};

    for (final route in routes) {
      final visited = <String>{};
      AppRouteDefinition? current = route;

      while (current?.parentName != null) {
        final parentName = current!.parentName!;

        if (!visited.add(parentName)) {
          throw StateError(
            'Circular parent route hierarchy detected at $parentName.',
          );
        }

        current = routeMap[parentName];
      }
    }
  }

  static void _validatePathParameters(String path) {
    final parameterNames = <String>{};

    for (final segment in _segments(path)) {
      if (!segment.startsWith(':')) continue;

      final name = segment.substring(1);

      if (name.isEmpty) {
        throw FormatException('Empty route parameter in path: $path');
      }

      if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(name)) {
        throw FormatException('Invalid route parameter "$name" in path: $path');
      }

      if (!parameterNames.add(name)) {
        throw FormatException(
          'Duplicate route parameter "$name" in path: $path',
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Internal matching helpers
  // ---------------------------------------------------------------------------

  static bool _matches(String template, String actualPath) {
    final templateSegments = _segments(template);
    final actualSegments = _segments(actualPath);

    if (templateSegments.length != actualSegments.length) {
      return false;
    }

    for (var i = 0; i < templateSegments.length; i++) {
      final templateSegment = templateSegments[i];
      final actualSegment = actualSegments[i];

      if (templateSegment.startsWith(':')) {
        if (actualSegment.isEmpty) return false;
        continue;
      }

      if (templateSegment != actualSegment) {
        return false;
      }
    }

    return true;
  }

  static int _specificity(String path) {
    var score = 0;

    for (final segment in _segments(path)) {
      score += segment.startsWith(':') ? 1 : 10;
    }

    return score;
  }

  static List<String> _segments(String path) {
    return _normalize(
      path,
    ).split('/').where((segment) => segment.isNotEmpty).toList();
  }

  static String _normalize(String path) {
    if (path.trim().isEmpty) return '/';

    final value = path.trim();

    if (value == '/') return '/';

    return '/${value.split('/').where((e) => e.isNotEmpty).join('/')}';
  }

  // ---------------------------------------------------------------------------
  // JSON helpers
  // ---------------------------------------------------------------------------

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];

    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Route field "$key" is required.');
    }

    return value.trim();
  }

  static String? _optionalString(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  static int _optionalInt(dynamic value) {
    if (value == null) {
      return 0xe836;
    }

    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? 0xe836;
    }

    return 0xe836;
  }

  static bool _boolValue(dynamic value) {
    return value == true;
  }

  static int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }
}
