//
import 'package:flutter/material.dart';

typedef AppRoutePageBuilder = Widget Function(AppRouteParameters parameters);

/// Parameters passed to a route builder.
class AppRouteParameters {
  const AppRouteParameters({
    required this.uri,
    required this.pathParameters,
    required this.queryParameters,
    this.arguments,
  });

  /// Complete requested URI.
  final Uri uri;

  /// Dynamic parameters extracted from the route path.
  ///
  /// Example:
  /// Route: /products/:productId
  /// URL:   /products/123
  /// Result: {'productId': '123'}
  final Map<String, String> pathParameters;

  /// Query parameters from the URL.
  ///
  /// Example:
  /// /products?page=2&limit=10
  /// Result: {'page': '2', 'limit': '10'}
  final Map<String, String> queryParameters;

  /// Optional navigation arguments.
  final Object? arguments;

  /// Access dynamic path parameters.
  String? operator [](String key) => pathParameters[key];

  String? path(String key) => pathParameters[key];

  /// Access query parameters.
  String? query(String key) => queryParameters[key];

  /// Safely retrieve navigation arguments by type.
  T? argumentAs<T>() {
    final value = arguments;
    return value is T ? value : null;
  }

  /// Retrieve an integer path parameter.
  int? intParameter(String key) {
    return int.tryParse(pathParameters[key] ?? '');
  }

  /// Retrieve an integer query parameter.
  int? intQuery(String key) {
    return int.tryParse(queryParameters[key] ?? '');
  }
}

/// Defines a static or dynamic application route.
///
/// Examples:
///
/// Static:
/// /dashboard
///
/// Dynamic:
/// /products/:productId
///
/// Multiple parameters:
/// /metadata/modules/:moduleId/versions/:versionId
class AppRouteDefinition {
  const AppRouteDefinition({
    required this.name,
    required this.path,
    required this.builder,
  });

  final String name;

  final String path;

  final AppRoutePageBuilder builder;

  /// Normalized route path segments.
  ///
  /// Example:
  /// /products/:productId
  /// becomes:
  /// ['products', ':productId']
  List<String> get segments {
    return path.split('/').where((segment) => segment.isNotEmpty).toList();
  }

  /// Higher values indicate more specific routes.
  ///
  /// Static segments receive more weight than dynamic segments.
  ///
  /// Example:
  /// /products/new       -> more specific
  /// /products/:id       -> less specific
  int get specificity {
    return segments.fold<int>(
      0,
      (total, segment) => total + (segment.startsWith(':') ? 1 : 10),
    );
  }

  /// Checks whether the supplied URI matches this route.
  bool matches(Uri uri) {
    return _match(uri.path) != null;
  }

  /// Builds the route widget if the URI matches.
  ///
  /// Returns null when the route does not match.
  Widget? build(Uri uri, {Object? arguments}) {
    final parameters = _match(uri.path);

    if (parameters == null) {
      return null;
    }

    return builder(
      AppRouteParameters(
        uri: uri,
        pathParameters: parameters,
        queryParameters: uri.queryParameters,
        arguments: arguments,
      ),
    );
  }

  /// Matches an actual path against the route definition.
  ///
  /// Returns extracted parameters when matched.
  /// Returns null when the path does not match.
  Map<String, String>? _match(String actualPath) {
    final routeSegments = segments;

    final actualSegments = actualPath
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .toList();

    // Both paths must have the same number of segments.
    if (routeSegments.length != actualSegments.length) {
      return null;
    }

    final parameters = <String, String>{};

    for (var i = 0; i < routeSegments.length; i++) {
      final routeSegment = routeSegments[i];
      final actualSegment = actualSegments[i];

      if (routeSegment.startsWith(':')) {
        final parameterName = routeSegment.substring(1);

        // Invalid route definition.
        if (parameterName.isEmpty) {
          return null;
        }

        // Empty dynamic parameters are not allowed.
        if (actualSegment.isEmpty) {
          return null;
        }

        parameters[parameterName] = Uri.decodeComponent(actualSegment);
      } else {
        // Static segments must match exactly.
        if (routeSegment != actualSegment) {
          return null;
        }
      }
    }

    return parameters;
  }

  @override
  String toString() {
    return 'AppRouteDefinition(name: $name, path: $path)';
  }
}
