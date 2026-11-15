import 'package:flutter/widgets.dart';

import '../app_reactive_form.dart';
import '../helper/entity_meta_helper.dart';
import '../models/entity_meta.dart';

/// Sample metadata for an order form containing an array of line items.
///
/// The schema uses the form metadata format consumed by [entityMetaFromJson].
/// In particular, an object array declares its item schema in `itemMeta`.
const Map<String, dynamic> sampleOrderFormSchema = {
  'entityName': 'Order',
  'fields': [
    {
      'name': 'customerName',
      'label': 'Customer name',
      'type': 'text',
      'validationRules': {'required': true, 'minLength': 2},
    },
    {
      'name': 'items',
      'label': 'Order items',
      'type': 'array',
      'helpText': 'Add one row for each product in the order.',
      'itemMeta': {
        'name': 'item',
        'label': 'Item',
        'type': 'group',
        'fields': [
          {
            'name': 'productName',
            'label': 'Product',
            'type': 'text',
            'validationRules': {'required': true},
          },
          {
            'name': 'quantity',
            'label': 'Quantity',
            'type': 'number',
            'validationRules': {'required': true, 'min': 1},
          },
          {
            'name': 'unitPrice',
            'label': 'Unit price',
            'type': 'number',
            'validationRules': {'required': true, 'min': 0},
          },
        ],
      },
    },
    {'name': 'notes', 'label': 'Notes', 'type': 'textarea'},
  ],
};

final EntityMeta sampleOrderFormMeta = entityMetaFromJson(
  sampleOrderFormSchema,
);

/// Ready-to-embed example using the application's normal form architecture.
class SampleFormArray extends StatelessWidget {
  const SampleFormArray({super.key});

  @override
  Widget build(BuildContext context) {
    return AppReactiveForm(
      meta: sampleOrderFormMeta,
      initialData: const {
        'customerName': 'Ada Lovelace',
        'items': [
          {'productName': 'Notebook', 'quantity': 2, 'unitPrice': 12.50},
        ],
        'notes': 'Deliver during business hours.',
      },
      onSubmit: (data) async {
        // Replace this with the repository/API call for the host screen.
        debugPrint('Sample order: $data');
      },
    );
  }
}
