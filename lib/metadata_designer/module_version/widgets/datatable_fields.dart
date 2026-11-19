import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/forms/app_reactive_form.dart';
import '../../../core/forms/helper/entity_meta_helper.dart';
import '../../../../core/forms/models/entity_meta.dart';
import '../../bloc/metadata_bloc.dart';
import '../../bloc/metadata_event.dart';

/// Sample metadata for an order form containing an array of line items.
///
/// The schema uses the form metadata format consumed by [entityMetaFromJson].
/// In particular, an object array declares its item schema in `itemMeta`.
const Map<String, dynamic> sampleOrderFormSchema = {
  'entityName': 'Data Table',
  'fields': [
    {
      'name': 'columns',
      'label': 'Columns',
      'type': 'array',
      'helpText': 'Add one row for each product in the order.',
      'itemMeta': {
        'name': 'column',
        'label': 'Column',
        'type': 'group',
        'fields': [
          {
            'name': 'field',
            'label': 'Field',
            'type': 'text',
            'validationRules': {'required': true},
          },
          {
            'name': 'label',
            'label': 'Label',
            'type': 'text',
            'validationRules': {'required': true, 'min': 1},
          },
          {
            'name': 'tableEnable',
            'label': 'Enable in table',
            'type': 'boolean',
            'widget': 'switch',
            'initialValue': true,
          },
          {
            'name': 'viewEnable',
            'label': 'Enable in detail view',
            'type': 'boolean',
            'widget': 'switch',
            'initialValue': true,
          },
        ],
      },
    },
  ],
};

final EntityMeta sampleOrderFormMeta = entityMetaFromJson(
  sampleOrderFormSchema,
);

/// Ready-to-embed example using the application's normal form architecture.
class DataTableColumnView extends StatelessWidget {
  const DataTableColumnView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppReactiveForm(
      meta: sampleOrderFormMeta,
      initialData: const {
        "columns": [
          {"field": "record_code", "label": "Record Code", "tableEnable": true, "viewEnable": true},
          {"field": "contact_id", "label": "Contact Id", "tableEnable": true, "viewEnable": true},
          {"field": "account_id", "label": "Account Id", "tableEnable": true, "viewEnable": true},
          {"field": "first_name", "label": "First Name", "tableEnable": true, "viewEnable": true},
          {"field": "last_name", "label": "Last Name", "tableEnable": true, "viewEnable": true},
          {"field": "email", "label": "Email", "tableEnable": true, "viewEnable": true},
          {"field": "phone", "label": "Phone", "tableEnable": true, "viewEnable": true},
          {"field": "job_title", "label": "Job Title", "tableEnable": true, "viewEnable": true},
          {"field": "is_primary", "label": "Is Primary", "tableEnable": true, "viewEnable": true},
          {"field": "is_billing", "label": "Is Billing", "tableEnable": true, "viewEnable": true},
          {"field": "is_technical", "label": "Is Technical", "tableEnable": true, "viewEnable": true},
          {"field": "marketing_consent", "label": "Marketing Consent", "tableEnable": true, "viewEnable": true},
          {"field": "preferred_locale", "label": "Preferred Locale", "tableEnable": true, "viewEnable": true},
        ],
      },
      onSubmit: (data) async {
        final columns = (data['columns'] as List? ?? const [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        context.read<MetadataBloc>().add(
          UpdateRootProperty('datatable', {'columns': columns}),
        );
      },
    );
  }
}
