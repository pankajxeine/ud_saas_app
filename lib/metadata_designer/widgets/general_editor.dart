import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/core/forms/app_reactive_form.dart';
import 'package:ud_sass_app/core/forms/helper/entity_meta_helper.dart';
import 'package:ud_sass_app/core/forms/models/entity_meta.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';

/// Edits entity/title/table/primaryKey on the current schema version.
class GeneralEditor extends StatelessWidget {
  const GeneralEditor({super.key});

  static final EntityMeta _metadata = entityMetaFromJson(const {
    'entityName': 'Module schema',
    'fields': [
      {'name': 'entity', 'label': 'Entity', 'type': 'text', 'validationRules': {'required': true}},
      {'name': 'title', 'label': 'Title', 'type': 'text', 'validationRules': {'required': true}},
      {'name': 'table', 'label': 'Database table', 'type': 'text', 'validationRules': {'required': true}},
      {'name': 'primaryKey', 'label': 'Primary key', 'type': 'text', 'initialValue': 'id'},
    ],
  });

  @override
  Widget build(BuildContext context) {
    final schema = context.select(
      (MetadataBloc bloc) => bloc.state.metadata?.schemaJson,
    );
    if (schema == null) return const Center(child: Text('No schema loaded.'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AppReactiveForm(
        key: ValueKey(
          'schema-${schema.entity}-${schema.title}-${schema.table}-${schema.primaryKey}',
        ),
        meta: _metadata,
        initialData: {
          'entity': schema.entity ?? '',
          'title': schema.title ?? '',
          'table': schema.table ?? '',
          'primaryKey': schema.primaryKey ?? 'id',
        },
        onSubmit: (data) async {
          context.read<MetadataBloc>().add(UpdateRootProperties(data));
        },
      ),
    );
  }
}
