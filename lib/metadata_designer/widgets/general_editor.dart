import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ud_sass_app/ui/dashcn/components/input.dart';
// import 'package:ud_sass_app/ui/dashcn/components/select.dart';
// import 'package:ud_sass_app/ui/dashcn/src/theme/theme.dart';

import 'package:ud_sass_app/core/forms/entity_meta.dart';
import 'package:ud_sass_app/core/forms/entity_form.dart';

import '../bloc/metadata_bloc.dart';
// import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';

class GeneralEditor extends StatelessWidget {
  const GeneralEditor({super.key});

  static const Map<String, dynamic> _schema = {
    'entityName': 'Metadata Module',
    'fields': [
      {
        'name': 'moduleId',
        'label': 'Module ID',
        'type': 'text',
        'placeholder': 'crm_contact',
        'editable': true,
        'validationRules': {
          'required': true,
          'minLength': 3,
          'maxLength': 100,
          'pattern': r'^[a-z][a-z0-9_]*$',
        },
        "colSpan": {"mobile": 12, "tablet": 6, "desktop": 3},
      },
      {
        'name': 'moduleCode',
        'label': 'Module Code',
        'type': 'text',
        'placeholder': 'CRM_CONTACT',
        'validationRules': {
          'required': true,
          'minLength': 2,
          'maxLength': 100,
          'pattern': r'^[A-Za-z][A-Za-z0-9_]*$',
        },
        "colSpan": {"mobile": 12, "tablet": 6, "desktop": 3},
        "rowSpan": {"mobile": 1, "tablet": 2, "desktop": 2, "largeDesktop": 3},
      },
      {
        'name': 'moduleName',
        'label': 'Module Name',
        'type': 'text',
        'placeholder': 'CRM Contact',
        'validationRules': {'required': true, 'minLength': 2, 'maxLength': 150},
        "colSpan": {"mobile": 12, "tablet": 6, "desktop": 3},
        "rowSpan": {"mobile": 1, "tablet": 2, "desktop": 2, "largeDesktop": 3},
      },
      {
        'name': 'apiBasePath',
        'label': 'API Base Path',
        'type': 'text',
        'placeholder': '/api/crm/contacts',
        'validationRules': {
          'required': true,
          'maxLength': 200,
          'pattern': r'^/.*$',
        },
        'colSpan': 6,
        'features': {'showClearButton': true, 'showCopyButton': true},
      },
      {
        'name': 'schemaName',
        'label': 'Database Schema',
        'type': 'text',
        'placeholder': 'crm',
        'initialValue': 'public',
        'validationRules': {
          'required': true,
          'maxLength': 63,
          'pattern': r'^[a-z][a-z0-9_]*$',
        },
        'colSpan': 6,
      },
      {
        'name': 'tableName',
        'label': 'Database Table',
        'type': 'text',
        'placeholder': 'crm_contact',
        'validationRules': {
          'required': true,
          'maxLength': 63,
          'pattern': r'^[a-z][a-z0-9_]*$',
        },
        'colSpan': 6,
      },
      {
        'name': 'icon',
        'label': 'Icon',
        'type': 'text',
        'placeholder': 'people',
        'validationRules': {'maxLength': 100},
        'colSpan': 6,
        'features': {'showClearButton': true},
      },
      {
        'name': 'isActive',
        'label': 'Active',
        'type': 'boolean',
        'initialValue': true,
        'colSpan': 6,
      },
      {
        'name': 'description',
        'label': 'Description',
        'type': 'textarea',
        'placeholder': 'Describe this module',
        'maxLength': 1000,
        'validationRules': {'maxLength': 1000},
        'colSpan': 12,
        'rowSpan': 2,
      },
    ],
  };

  static final EntityMeta _metadata = entityMetaFromJson(_schema);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataBloc, MetadataState>(
      builder: (context, state) {
        final metaModule = state.metadata?.metaModule;

        // final fields = (metadata?.metaModule as List<dynamic>? ?? [])
        //     .whereType<Map<String, dynamic>>()
        //     .toList();

        // final fieldNames = fields
        //     .map((field) => field['name']?.toString() ?? '')
        //     .where((name) => name.isNotEmpty)
        //     .toList();

        print("Meta module details :-  $metaModule");
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EntityReactiveForm(
                meta: _metadata,
                mode: metaModule != null ? EntityMode.edit : EntityMode.create,
                initialData: moduleEditorInitialData(metaModule),
                onSubmit: (data) async => {print("submit application $data")},
              ),

              // _buildPrimaryKeyEditor(
              //   context: context,
              //   fieldNames: fieldNames,
              //   primaryKey: primaryKey,
              // ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> moduleEditorInitialData(Map<String, dynamic>? module) {
    return {
      'moduleId': module?['moduleId'] ?? '',
      'moduleCode': module?['moduleCode'] ?? '',
      'moduleName': module?['moduleName'] ?? '',
      'apiBasePath': module?['apiBasePath'] ?? '',
      'icon': module?['icon'],
      'description': module?['description'] ?? '',
      'schemaName': module?['schemaName'] ?? '',
      'tableName': module?['tableName'] ?? '',
      'isActive': module?['isActive'] ?? true,
    };
  }

  // Widget _buildTextEditor({
  //   required BuildContext context,
  //   required String label,
  //   required String description,
  //   required String property,
  //   required String value,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 18),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           label,
  //           style: Theme.of(context).typography.medium.copyWith(
  //             fontWeight: FontWeight.bold,
  //             color: Theme.of(context).colors.accentForeground,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           description,
  //           style: Theme.of(context).typography.small.copyWith(
  //             fontSize: 12,
  //             fontWeight: FontWeight.bold,
  //             color: Theme.of(context).colors.mutedForeground,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Input(
  //           initialValue: value,
  //           onChanged: (newValue) {
  //             context.read<MetadataBloc>().add(
  //               UpdateRootProperty(property, newValue),
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildPrimaryKeyEditor({
  //   required BuildContext context,
  //   required List<String> fieldNames,
  //   required String? primaryKey,
  // }) {
  //   final selectedValue = fieldNames.contains(primaryKey) ? primaryKey : null;

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Primary Key',
  //         style: TextStyle(fontWeight: FontWeight.w600),
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         'Select the field used to identify each record.',
  //         style: Theme.of(context).typography.medium.copyWith(
  //           fontSize: 12,
  //           fontWeight: FontWeight.bold,
  //           color: Theme.of(context).colors.accentForeground,
  //         ),
  //       ),
  //       const SizedBox(height: 8),

  //       if (fieldNames.isEmpty)
  //         Text(
  //           'Add at least one field before selecting a primary key.',
  //           style: Theme.of(context).typography.medium.copyWith(
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //             color: const Color(0xFFB42318),
  //           ),
  //         )
  //       else
  //         Select<String>(
  //           value: selectedValue,
  //           onChanged: (value) {
  //             if (value != null) {
  //               context.read<MetadataBloc>().add(
  //                 UpdateRootProperty('primaryKey', value),
  //               );
  //             }
  //           },
  //           itemBuilder: (context, item) {
  //             return Text(item);
  //           },
  //           items: fieldNames
  //               .map((name) => SelectItem(value: name, child: Text(name)))
  //               .toList(),
  //         ),
  //     ],
  //   );
  // }
}

extension ModuleEditorData on Map<String, dynamic> {
  Map<String, dynamic> toFormData() {
    return {
      'moduleId': this['moduleId'],
      'moduleCode': this['moduleCode'],
      'moduleName': this['moduleName'],
      'apiBasePath': this['apiBasePath'],
      'icon': this['icon'],
      'description': this['description'],
      'schemaName': this['schemaName'],
      'tableName': this['tableName'],
      'isActive': this['isActive'],
    };
  }
}
