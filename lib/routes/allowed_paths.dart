import 'generated_module_routes.dart';

bool isAllowedPath(String path) {
  final normalized = _normalizePath(path);

  // Static application routes.
  const staticPaths = <String>{
    '/',
    '/login',
    '/dashboard',
    '/products',
    '/orders',
    '/settings',
    '/metadata/modules',
    '/metadata/modules/new',
  };

  if (staticPaths.contains(normalized)) {
    return true;
  }

  // Metadata module and version routes.
  if (_isMetadataPath(normalized)) {
    return true;
  }

  // Cpanel category and module routes.
  if (_isCpanelPath(normalized)) {
    return true;
  }

  // Database-driven generated module routes.
  if (isAllowedGeneratedPath(normalized)) {
    return true;
  }

  return false;
}

// ------------------------------------------------------------
// GENERATED MODULE ROUTES
// ------------------------------------------------------------

bool isAllowedGeneratedPath(String path) {
  final uri = Uri.tryParse(path);

  if (uri == null) {
    return false;
  }

  return generatedModuleRoutes.any((route) => route.matches(uri));
}

// ------------------------------------------------------------
// METADATA ROUTES
// ------------------------------------------------------------

bool _isMetadataPath(String path) {
  final segments = Uri(path: path).pathSegments;

  if (segments.length == 2 &&
      segments[0] == 'metadata' &&
      segments[1] == 'modules') {
    return true;
  }

  if (segments.length == 3 &&
      segments[0] == 'metadata' &&
      segments[1] == 'modules') {
    return segments[2] == 'new' || segments[2].isNotEmpty;
  }

  if (segments.length == 5 &&
      segments[0] == 'metadata' &&
      segments[1] == 'modules' &&
      segments[3] == 'versions') {
    return segments[2].isNotEmpty &&
        (segments[4] == 'new' || segments[4].isNotEmpty);
  }

  return false;
}

// ------------------------------------------------------------
// CPANEL ROUTES
// ------------------------------------------------------------

bool _isCpanelPath(String path) {
  final segments = Uri(path: path).pathSegments;

  // /cpanel/:categorySlug
  if (segments.length == 2 &&
      segments[0] == 'cpanel' &&
      segments[1].isNotEmpty) {
    return true;
  }

  // /cpanel/:categorySlug/:moduleSlug
  if (segments.length == 3 &&
      segments[0] == 'cpanel' &&
      segments[1].isNotEmpty &&
      segments[2].isNotEmpty) {
    return true;
  }

  return false;
}

// ------------------------------------------------------------
// PATH NORMALIZATION
// ------------------------------------------------------------

String _normalizePath(String path) {
  final uri = Uri.tryParse(path);

  if (uri == null) {
    return '';
  }

  var normalized = uri.path;

  if (normalized.length > 1) {
    normalized = normalized.replaceFirst(RegExp(r'/+$'), '');
  }

  return normalized.isEmpty ? '/' : normalized;
}
