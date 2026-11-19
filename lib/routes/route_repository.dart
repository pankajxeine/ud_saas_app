class RouteRepository {
  RouteRepository();

  /// Returns hard-coded dynamic route definitions.
  ///
  /// Later, replace this implementation with an API call.
  Future<List<Map<String, dynamic>>> getRoutes() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return [
      // ------------------------------------------------------------
      // Modules
      // ------------------------------------------------------------
      {
        'name': 'modules',
        'path': '/metadata/modules',
        'pageType': 'modules',
        'label': 'Modules',
        'localizationKey': 'modules',
        'icon': 'oxf1f4',
        'section': 'Administration',
        'enabled': true,
        'requiresAuth': true,
        'showInSidebar': true,
        'showInRail': true,
        'showInBottomBar': false,
      },
      {
        'name': 'module',
        'path': '/metadata/modules/:id',
        'pageType': 'module',
        'label': 'Module Details',
        'localizationKey': 'module_details',
        'parentName': 'modules',
        'enabled': true,
        'requiresAuth': true,
      },
      {
        'name': 'moduleVersion',
        'path': '/metadata/modules/:id/versions/:versionId',
        'pageType': 'moduleVersion',
        'label': 'Module Version',
        'localizationKey': 'module_version',
        'parentName': 'modules',
        'enabled': true,
        'requiresAuth': true,
      },

      // ------------------------------------------------------------
      // Products
      // ------------------------------------------------------------
      //     {
      //       'name': 'products',
      //       'path': '/products',
      //       'pageType': 'entityList',
      //       'label': 'Products',
      //       'localizationKey': 'products',
      //       'section': 'Inventory',
      //       'icon': 'inventory_2_outlined',
      //       'pageConfig': {'moduleName': 'products', 'entityName': 'product'},
      //       'enabled': true,
      //       'requiresAuth': true,
      //       'showInSidebar': true,
      //       'showInRail': true,
      //     },
      //     {
      //       'name': 'productDetail',
      //       'path': '/products/:id',
      //       'pageType': 'entityDetail',
      //       'label': 'Product Details',
      //       'parentName': 'products',
      //       'pageConfig': {
      //         'moduleName': 'products',
      //         'entityName': 'product',
      //         'recordIdParam': 'id',
      //       },
      //       'enabled': true,
      //       'requiresAuth': true,
      //     },
      //     {
      //       'name': 'productCreate',
      //       'path': '/products/create',
      //       'pageType': 'entityCreate',
      //       'label': 'Create Product',
      //       'parentName': 'products',
      //       'pageConfig': {'moduleName': 'products', 'entityName': 'product'},
      //       'enabled': true,
      //       'requiresAuth': true,
      //     },
      //     {
      //       'name': 'productEdit',
      //       'path': '/products/:id/edit',
      //       'pageType': 'entityEdit',
      //       'label': 'Edit Product',
      //       'parentName': 'products',
      //       'pageConfig': {
      //         'moduleName': 'products',
      //         'entityName': 'product',
      //         'recordIdParam': 'id',
      //       },
      //       'enabled': true,
      //       'requiresAuth': true,
      //     },

      //     // ------------------------------------------------------------
      //     // Orders
      //     // ------------------------------------------------------------
      //     {
      //       'name': 'orders',
      //       'path': '/sales/orders',
      //       'pageType': 'entityList',
      //       'label': 'Orders',
      //       'localizationKey': 'orders',
      //       'section': 'Sales',
      //       'icon': 'shopping_cart_outlined',
      //       'pageConfig': {'moduleName': 'sales', 'entityName': 'order'},
      //       'enabled': true,
      //       'requiresAuth': true,
      //       'showInSidebar': true,
      //       'showInRail': true,
      //     },

      //     // ------------------------------------------------------------
      //     // Users
      //     // ------------------------------------------------------------
      //     {
      //       'name': 'users',
      //       'path': '/admin/users',
      //       'pageType': 'entityList',
      //       'label': 'Users',
      //       'localizationKey': 'users',
      //       'section': 'Administration',
      //       'icon': 'people_outline',
      //       'pageConfig': {'moduleName': 'administration', 'entityName': 'user'},
      //       'enabled': true,
      //       'requiresAuth': true,
      //       'showInSidebar': true,
      //       'showInRail': true,
      //     },
    ];
  }
}
