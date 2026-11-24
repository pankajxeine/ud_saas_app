import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/core/forms/forms.dart';
import 'package:ud_sass_app/core/forms/helper/entity_meta_helper.dart';
import 'package:ud_sass_app/core/forms/models/entity_meta.dart';
import 'package:ud_sass_app/metadata_designer/models/metadata_module.dart';
import 'package:ud_sass_app/metadata_designer/models/metadata_module_version.dart';
import 'package:ud_sass_app/metadata_designer/models/metadata_schema.dart';
import 'package:ud_sass_app/metadata_designer/repository/metadata_repository.dart';
import 'package:ud_sass_app/routes/app_routes_constants.dart';

class AddModuleVersionPage extends StatelessWidget {
  const AddModuleVersionPage({super.key, required this.moduleId});

  final String moduleId;

  static final EntityMeta _meta = entityMetaFromJson(const {
    'entityName': 'New module schema version',
    'fields': [
      {
        'name': 'entity',
        'label': 'Entity',
        'type': 'text',
        'validationRules': {'required': true},
      },
      {
        'name': 'title',
        'label': 'Title',
        'type': 'text',
        'validationRules': {'required': true},
      },
      {
        'name': 'table',
        'label': 'Database table',
        'type': 'text',
        'validationRules': {'required': true},
      },
      {
        'name': 'primaryKey',
        'label': 'Primary key',
        'type': 'text',
        'initialValue': 'id',
      },
    ],
  });

  @override
  Widget build(BuildContext context) {
    final repository = LocalMetadataRepository(
      baseUrl: ProfileConstants.api.toString(),
    );

    return FutureBuilder(
      future: repository.fetchMetadataModuleById(moduleId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Unable to load module: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Text('Loading module...');
        }
        final module = snapshot.data!.body;
        if (module == null) {
          return Text(snapshot.data!.message);
        }
        return _ModuleVersionForm(module: module, meta: _meta);
      },
    );
  }
}

class _ModuleVersionForm extends StatelessWidget {
  const _ModuleVersionForm({required this.module, required this.meta});

  final MetaModule module;
  final EntityMeta meta;

  @override
  Widget build(BuildContext context) {
    return AppReactiveForm(
      meta: meta,
      initialData: {
        'entity': module.moduleCode,
        'title': module.moduleName,
        'table': module.tableName,
        'primaryKey': 'id',
      },
      onSubmit: (data) async {
        final schema = MetadataSchema.empty(
          entity: data['entity']?.toString() ?? module.moduleCode,
          title: data['title']?.toString() ?? module.moduleName,
          table: data['table']?.toString() ?? module.tableName,
        ).copyWith(primaryKey: data['primaryKey']?.toString() ?? 'id');
        final result =
            await LocalMetadataRepository(
              baseUrl: ProfileConstants.api.toString(),
            ).createModuleVersion(
              MetaModuleVersion(
                moduleId: module.moduleId,
                versionNo: module.currentVersion + 1,
                schemaJson: schema,
                publicationStatus: 'draft',
              ),
            );
        if (!context.mounted) return;
        final version = result.body;
        if (version?.moduleVersionId != null) {
          context.go(
            ApplicationRoutesConstants.metadataVersion(
              module.moduleId,
              version!.moduleVersionId!,
            ),
          );
        }
      },
    );
  }
}
