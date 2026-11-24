// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';

import '../core/navigation/app_route_definition.dart';
import '../core/navigation/app_route_registry.dart';

import '../features/auth/login_page.dart';
import '../features/settings/settings_page.dart';
import '../features/products/product_list_page.dart';
import '../features/example/data_grid_page.dart';
import '../features/example/generic_crud_demo_page.dart';
// import '../features/example/validation_demo_page.dart';
// import '../features/example/sample_page.dart';

import '../metadata_designer/modules/modules.dart';
import '../metadata_designer/modules/add_module_page.dart';
import '../metadata_designer/module/module.dart';
import '../metadata_designer/module/add_module_version_page.dart';
import '../metadata_designer/module_version/module_version.dart';

class AppNavigationConfig {
  AppNavigationConfig._();

  // ---------------------------------------------------------------------------
  // Route names
  // ---------------------------------------------------------------------------

  static const dashboard = 'dashboard';
  static const contacts = 'contacts';
  static const contactDetail = 'contact-detail';
  static const orders = 'orders';
  static const users = 'users';
  static const settings = 'settings';
  static const login = 'login';
  static const crudDemo = 'crud-demo';
  // ---------------------------------------------------------------------------
  // Static routes
  // ---------------------------------------------------------------------------

  static final List<AppRouteDefinition> staticRoutes = [
    AppRouteDefinition(
      name: dashboard,
      path: '/dashboard',
      builder: (context, state) => const DataGridPage(),
      localizationKey: 'dashboard',
      label: 'Dashboard',
      icon: 0xe871,
      showInSidebar: true,
      showInRail: true,
      showInBottomBar: true,
      bottomBarOrder: 1,
    ),

    // AppRouteDefinition(
    //   name: contacts,
    //   path: '/crm/contacts',
    //   builder: (context, state) => const ContactsPage(),
    //   label: 'Contacts',
    //   localizationKey: 'contacts',
    //   section: 'CRM',
    //   icon: "people_outline",
    //   showInSidebar: true,
    //   showInRail: true,
    //   showInBottomBar: true,
    //   bottomBarOrder: 2,
    // ),

    // AppRouteDefinition(
    //   name: contactDetail,
    //   path: '/crm/contacts/:contactId',
    //   builder: (context, state) =>
    //       ContactDetailPage(contactId: state.pathParameters['contactId']!),
    //   label: 'Contact Details',
    //   localizationKey: 'contacts_details',
    //   parentName: contacts,
    // ),
    AppRouteDefinition(
      name: login,
      path: '/login',
      builder: (context, state) => const LoginPage(),
      label: 'Login',
      requiresAuth: false,
      showInBreadcrumb: false,
    ),
    AppRouteDefinition(
      name: orders,
      path: '/orders',
      builder: (context, state) => const ProductListPage(),
      label: 'Orders',
      section: 'Sales',
      localizationKey: 'orders',
      icon: 0xeb14,
      showInSidebar: true,
      showInRail: true,
      showInBottomBar: true,
      bottomBarOrder: 3,
    ),

    AppRouteDefinition(
      name: users,
      path: '/users',
      builder: (context, state) => const DataGridPage(),
      label: 'Users',
      localizationKey: 'administration',
      section: 'Administration',
      icon: 0xf8e5,
      showInSidebar: true,
      showInRail: true,
    ),

    AppRouteDefinition(
      name: settings,
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
      label: 'Settings',
      localizationKey: 'settings',
      icon: 0xe8b8,
      showInSidebar: true,
      showInRail: true,
    ),
    AppRouteDefinition(
      name: crudDemo,
      path: '/crud-demo',
      builder: (context, state) => const GenericCrudDemoPage(),
      label: 'CRUD Demo',
      requiresAuth: true,
      showInSidebar: true,
      showInRail: false,
      showInBreadcrumb: false,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Dynamic page builders
  // ---------------------------------------------------------------------------

  /// Page types are registered here, not in AppRouter.
  ///
  /// The database stores the pageType and pageConfig.
  /// Flutter resolves pageType to the actual widget.
  static String _moduleId(Uri uri) {
    final segments = uri.pathSegments;

    if (segments.length < 2 || segments[0] != 'modules') {
      throw FormatException('Invalid module URI: $uri');
    }

    return segments[1];
  }

  static ({String moduleId, String versionId}) _versionIds(Uri uri) {
    final segments = uri.pathSegments;

    if (segments.length < 4 ||
        segments[0] != 'modules' ||
        segments[2] != 'version') {
      throw FormatException('Invalid module version URI: $uri');
    }

    return (moduleId: segments[1], versionId: segments[3]);
  }

  static void registerPageBuilders({bool replace = false}) {
    AppRouteRegistry.registerPageTypes({
      'modules': (context, state, config) {
        return const MetadataModules();
      },

      'createModule': (context, state, config) {
        return const AddModulePage();
      },

      'createVersion': (context, state, config) {
        final segments = state.uri.pathSegments;

        if (segments.length < 5) {
          throw StateError('Module ID is missing from the route.');
        }

        return AddModuleVersionPage(moduleId: segments[2]);
      },

      'module': (context, state, config) {
        final segments = state.uri.pathSegments;

        if (segments.length < 2) {
          throw StateError('Module ID is missing from route.');
        }

        final moduleId = segments[2];
        debugPrint("*** moduleId : $moduleId  ");
        return MetadataModule(
          key: ValueKey('metadata-module-$moduleId'),
          moduleId: moduleId,
        );
      },

      'moduleVersion': (context, state, config) {
        final segments = state.uri.pathSegments;

        if (segments.length < 5) {
          throw StateError('Module ID or version ID is missing.');
        }

        final moduleId = segments[2];
        final versionId = segments[4];
        debugPrint("*** moduleId : $moduleId  versionID : $versionId");

        return MetadataVersionDesign(
          key: ValueKey('metadata-version-$moduleId-$versionId'),
          moduleId: moduleId,
          versionId: versionId,
        );
      },
    }, replace: replace);
  }

  static List<AppRouteDefinition> buildRoutes({
    List<dynamic> dynamicJson = const [],
  }) {
    final dynamicRoutes = AppRouteRegistry.fromJsonList(dynamicJson);

    final routes = <AppRouteDefinition>[...staticRoutes, ...dynamicRoutes];

    AppRouteRegistry.validate(routes);

    return routes;
  }
  // Database-driven route definitions
  // ---------------------------------------------------------------------------

  /// Converts routes received from the backend into AppRouteDefinition.
  static List<AppRouteDefinition> dynamicRoutesFromJson(
    List<Map<String, dynamic>> json,
  ) {
    return AppRouteRegistry.fromJsonList(json);
  }

  // ---------------------------------------------------------------------------
  // Route getters
  // ---------------------------------------------------------------------------

  static AppRouteDefinition get dashboardRoute =>
      staticRoutes.firstWhere((route) => route.name == dashboard);
}
