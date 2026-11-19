import 'package:ud_sass_app/routes/app_routes_constants.dart';

class AppRouteMetadata {
  const AppRouteMetadata({
    required this.path,
    required this.label,
    this.localizationKey,
    this.parentPath,
    this.showInBreadcrumb = true,
  });

  final String path;
  final String label;
  final String? localizationKey;
  final String? parentPath;
  final bool showInBreadcrumb;
}

class AppRouteMetadataRegistry {
  AppRouteMetadataRegistry._();

  static final List<AppRouteMetadata> routes = [
    const AppRouteMetadata(
      path: ApplicationRoutesConstants.dashboard,
      label: 'Dashboard',
    ),

    // CRM
    const AppRouteMetadata(
      path: '/crm',
      label: 'CRM',
      parentPath: ApplicationRoutesConstants.dashboard,
    ),
    const AppRouteMetadata(
      path: '/crm/contacts',
      label: 'Contacts',
      parentPath: '/crm',
    ),
    const AppRouteMetadata(
      path: '/crm/contacts/:contactId',
      label: 'Contact details',
      parentPath: '/crm/contacts',
    ),
    const AppRouteMetadata(
      path: '/crm/contacts/:contactId/edit',
      label: 'Edit contact',
      parentPath: '/crm/contacts/:contactId',
    ),

    // Add other modules using the same structure.
  ];
  static String resolveConcretePath(String template, String currentRoute) {
    final templateParts = _segments(template);
    final actualParts = _segments(currentRoute);

    final result = <String>[];

    for (var i = 0; i < templateParts.length; i++) {
      final part = templateParts[i];

      if (part.startsWith(':') && i < actualParts.length) {
        result.add(actualParts[i]);
      } else {
        result.add(part);
      }
    }

    return result.isEmpty ? '/' : '/${result.join('/')}';
  }

  static List<AppRouteMetadata> resolve(String currentRoute) {
    final current = _find(currentRoute);
    if (current == null) return const [];

    final result = <AppRouteMetadata>[];
    final visited = <String>{};
    AppRouteMetadata? item = current;

    while (item != null && visited.add(item.path)) {
      result.insert(0, item);

      final parent = item.parentPath;
      if (parent == null) break;

      item = _find(parent);
    }

    return result
        .where((item) => item.showInBreadcrumb)
        .toList(growable: false);
  }

  static AppRouteMetadata? _find(String path) {
    final actual = _normalize(path);

    final matches = routes
        .where((route) => _matches(route.path, actual))
        .toList();

    if (matches.isEmpty) return null;

    matches.sort(
      (a, b) => _specificity(b.path).compareTo(_specificity(a.path)),
    );

    return matches.first;
  }

  static bool _matches(String template, String actual) {
    final expectedParts = _segments(template);
    final actualParts = _segments(actual);

    if (expectedParts.length != actualParts.length) return false;

    for (var i = 0; i < expectedParts.length; i++) {
      if (expectedParts[i].startsWith(':')) continue;
      if (expectedParts[i] != actualParts[i]) return false;
    }

    return true;
  }

  static int _specificity(String path) {
    return _segments(path).where((part) => !part.startsWith(':')).length;
  }

  static List<String> _segments(String path) {
    return _normalize(
      path,
    ).split('/').where((part) => part.isNotEmpty).toList();
  }

  static String _normalize(String path) {
    final value = path.split('?').first.split('#').first;

    if (value.isEmpty || value == '/') return '/';

    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
