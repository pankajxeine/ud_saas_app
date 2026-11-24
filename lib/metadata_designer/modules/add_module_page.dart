import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/core/forms/forms.dart';
import 'package:ud_sass_app/core/forms/helper/entity_meta_helper.dart';
import 'package:ud_sass_app/core/forms/models/entity_meta.dart';
import 'package:ud_sass_app/metadata_designer/models/metadata_module.dart';
import 'package:ud_sass_app/metadata_designer/models/metadata_schema.dart';
import 'package:ud_sass_app/metadata_designer/repository/metadata_repository.dart';
import 'package:ud_sass_app/routes/app_routes_constants.dart';

class AddModulePage extends StatelessWidget {
  const AddModulePage({super.key});

  static final EntityMeta _meta = entityMetaFromJson(const {
    'entityName': 'New metadata module',
    'fields': [
      {
        'name': 'moduleCode',
        'label': 'Module code',
        'type': 'text',
        'validationRules': {'required': true, 'minLength': 2},
      },
      {
        'name': 'moduleName',
        'label': 'Module name',
        'type': 'text',
        'validationRules': {'required': true},
      },
      {
        'name': 'schemaName',
        'label': 'Database schema',
        'type': 'text',
        'initialValue': 'public',
        'validationRules': {'required': true},
      },
      {
        'name': 'tableName',
        'label': 'Database table',
        'type': 'text',
        'validationRules': {'required': true},
      },
      {'name': 'apiBasePath', 'label': 'API base path', 'type': 'text'},
      {'name': 'description', 'label': 'Description', 'type': 'textarea'},
      {'name': 'icon', 'label': 'Icon', 'type': 'text', 'initialValue': 'box'},
      {
        'name': 'isActive',
        'label': 'Active',
        'type': 'boolean',
        'initialValue': true,
      },
    ],
  });

  @override
  Widget build(BuildContext context) {
    return AppReactiveForm(
      meta: _meta,
      initialData: const {'apiBasePath': '/new_module'},
      onSubmit: (data) async {
        final code = _slug(data['moduleCode']?.toString() ?? 'new_module');
        final table = _slug(data['tableName']?.toString() ?? code);
        final module = MetaModule.empty(
          moduleCode: code,
          moduleName: data['moduleName']?.toString(),
          schemaName: data['schemaName']?.toString(),
          tableName: table,
          apiBasePath: data['apiBasePath']?.toString() ?? '/$code',
          description: data['description']?.toString(),
          icon: data['icon']?.toString(),
          isActive: data['isActive'] != false,
        );
        final schema = MetadataSchema.empty(
          entity: code,
          title: data['moduleName']?.toString(),
          table: table,
        );
        final result = await LocalMetadataRepository(
          baseUrl: ProfileConstants.api.toString(),
        ).createModule(module: module, schema: schema);
        if (!context.mounted) return;
        if (result.body?.moduleId.isNotEmpty == true) {
          context.go(
            ApplicationRoutesConstants.metadataModule(result.body!.moduleId),
          );
        }
      },
    );
  }

  static String _slug(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}
