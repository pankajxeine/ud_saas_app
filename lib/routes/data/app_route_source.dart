abstract interface class AppRouteSource {
  Future<List<dynamic>> loadRoutes();
}

/// Temporary source used until the backend route API is ready.
class HardcodedAppRouteSource implements AppRouteSource {
  const HardcodedAppRouteSource();

  @override
  Future<List<dynamic>> loadRoutes() async {
    return const [
      {
        'name': 'modules',
        'path': '/modules',
        'pageType': 'modules',
        'label': 'Modules',
        'localizationKey': 'modules',
        'icon': 59648,
        'showInSidebar': true,
        'showInRail': true,
        'showInBreadcrumb': true,
        'requiresAuth': true,
        'enabled': true,
      },
      {
        'name': 'module',
        'path': '/modules/:id',
        'pageType': 'module',
        'label': 'Module Details',
        'parentName': 'modules',
        'showInBreadcrumb': true,
        'requiresAuth': true,
        'enabled': true,
      },
      {
        'name': 'moduleVersion',
        'path': '/modules/:id/version/:versionId',
        'pageType': 'moduleVersion',
        'label': 'Module Version',
        'parentName': 'module',
        'showInBreadcrumb': true,
        'requiresAuth': true,
        'enabled': true,
      },
    ];
  }
}
