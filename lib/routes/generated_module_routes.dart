import '../core/navigation/app_route_definition.dart';

import '../metadata_designer/module/module.dart';
import '../metadata_designer/modules/modules.dart';
import '../metadata_designer/module_version/module_version.dart';

// import '../../features/example/data_grid_page.dart';

/// All generated module routes.
///
/// Keep more specific routes before generic routes where possible.
/// AppRouter also sorts routes by specificity.
final List<AppRouteDefinition> generatedModuleRoutes = [
  // ----------------------------------------------------------
  // PRODUCT ROUTES
  // ----------------------------------------------------------
  AppRouteDefinition(
    name: "Module Version",
    path: '/modules/:moduleId/versions/:versionId',
    builder: (params) {
      final moduleId = params.path('moduleId')!;
      final versionId = params.path('versionId')!;

      return MetadataVersionDesign(moduleId: moduleId, versionId: versionId);
    },
  ),

  // AppRouteDefinition(
  //   name: 'customer-details',
  //   path: '/customers/:id',
  //   builder: (context, params) {
  //     return MetadataModuleRecordView(
  //       entity: 'customer',
  //       recordId: params['id']!,
  //     );
  //   },
  // ),

  // ----------------------------------------------------------
  // Metadata tool ROUTES
  // ----------------------------------------------------------
  AppRouteDefinition(
    name: 'Modules',
    path: '/modules',
    builder: (params) {
      return const MetadataModules();
    },
  ),

  AppRouteDefinition(
    name: 'Module',
    path: '/modules/:moduleId',
    builder: (params) {
      final moduleId = params.path('moduleId')!;
      return MetadataModule(moduleId: moduleId);
    },
  ),
];
