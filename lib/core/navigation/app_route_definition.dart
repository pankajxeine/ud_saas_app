import 'package:flutter/widgets.dart';

/// One path-template route, such as `/items/:id/edit`.
class AppRouteDefinition {
  const AppRouteDefinition({required this.path, required this.builder});

  final String path;
  final Widget Function(Map<String, String> parameters) builder;
  int get specificity => _segments(
    path,
  ).where((String segment) => !segment.startsWith(':')).length;

  Widget? build(Uri uri) {
    final List<String> templateSegments = _segments(path);
    final List<String> pathSegments = uri.pathSegments;
    if (templateSegments.length != pathSegments.length) {
      return null;
    }

    final Map<String, String> parameters = <String, String>{};
    for (var index = 0; index < templateSegments.length; index += 1) {
      final String template = templateSegments[index];
      final String actual = pathSegments[index];
      if (template.startsWith(':')) {
        parameters[template.substring(1)] = actual;
      } else if (template != actual) {
        return null;
      }
    }
    return builder(parameters);
  }

  static List<String> _segments(String path) =>
      path.split('/').where((String segment) => segment.isNotEmpty).toList();
}

int requiredRouteId(Map<String, String> parameters) {
  final String? rawId = parameters['id'];
  final int? id = rawId == null ? null : int.tryParse(rawId);
  if (id == null) {
    throw FormatException('Expected a numeric route id, received "$rawId".');
  }
  return id;
}
