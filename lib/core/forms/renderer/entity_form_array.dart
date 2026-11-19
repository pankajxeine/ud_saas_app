import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../factory/entity_form_control_factory.dart';
import '../models/entity_meta.dart';
import '../models/field_meta.dart';
import '../registry/entity_field_widget_registry.dart';

import 'entity_form_renderer.dart';

class EntityFormArray extends StatelessWidget {
  const EntityFormArray({
    super.key,
    required this.field,
    required this.array,
    required this.mode,
    required this.registry,
  });

  final FieldMeta<dynamic> field;
  final FormArray<dynamic> array;
  final EntityMode mode;
  final EntityFieldWidgetRegistry registry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.label.isNotEmpty) ...[
          Text(
            field.label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
        ],

        ...List.generate(array.controls.length, (index) {
          return _buildArrayItem(context, index, array.controls[index]);
        }),

        if (mode != EntityMode.view)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton(
              onPressed: () => _addItem(context),
              child: Text('Add ${field.label}'),
            ),
          ),
      ],
    );
  }

  Widget _buildArrayItem(
    BuildContext context,
    int index,
    AbstractControl<dynamic> control,
  ) {
    if (control is FormGroup) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text('${field.label} ${index + 1}')),
                if (mode != EntityMode.view)
                  TextButton(
                    onPressed: () {
                      array.removeAt(index);
                    },
                    child: const Text('Remove'),
                  ),
              ],
            ),

            EntityFormRenderer(
              fields: field.itemMeta?.fields ?? const [],
              form: control,
              mode: mode,
              registry: registry,
            ),
          ],
        ),
      );
    }

    return _buildPrimitiveItem(control);
  }

  Widget _buildPrimitiveItem(AbstractControl<dynamic> control) {
    if (control is! FormControl<dynamic>) {
      return const Text('Array item renderer is not configured.');
    }

    return ReactiveFormField<dynamic, dynamic>(
      formControl: control,
      builder: (state) => TextFormField(
        initialValue: state.value?.toString() ?? '',
        enabled: state.control.enabled,
        onChanged: state.didChange,
      ),
    );
  }

  void _addItem(BuildContext context) {
    final control = EntityFormControlFactory.createArrayItem(
      field: field,
      mode: mode,
    );

    array.add(control);
  }
}
