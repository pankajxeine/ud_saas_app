import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'models/entity_meta.dart';
import 'models/field_meta.dart';
import 'entity_form_group.dart';

class EntityFormArray extends StatelessWidget {
  const EntityFormArray({
    super.key,
    required this.field,
    required this.array,
    required this.mode,
    this.fieldBuilder,
  });

  final FieldMeta<dynamic> field;
  final FormArray<dynamic> array;
  final EntityMode mode;

  final Widget Function(
    BuildContext context,
    FieldMeta<dynamic> field,
    FormGroup form,
    EntityMode mode,
  )?
  fieldBuilder;

  bool get _canEdit => mode != EntityMode.view && field.editable;

  @override
  Widget build(BuildContext context) {
    return ReactiveFormArray<dynamic>(
      formArray: array,
      builder: (context, formArray, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================
              // ARRAY HEADER
              // =================================================
              Row(
                children: [
                  Expanded(
                    child: Text(
                      field.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                  if (_canEdit)
                    IconButton(
                      tooltip: 'Add',
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        _addItem(formArray);
                      },
                    ),
                ],
              ),

              if (field.helpText != null && field.helpText!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    field.helpText!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),

              const SizedBox(height: 12),

              // =================================================
              // ARRAY ITEMS
              // =================================================
              if (formArray.controls.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No items added'),
                ),

              ...List.generate(formArray.controls.length, (index) {
                return _buildItem(context, formArray, index);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(
    BuildContext context,
    FormArray<dynamic> formArray,
    int index,
  ) {
    final control = formArray.controls[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // =====================================================
          // ITEM HEADER
          // =====================================================
          Row(
            children: [
              Expanded(
                child: Text(
                  '${field.label} ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),

              if (_canEdit)
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    formArray.removeAt(index);
                  },
                ),
            ],
          ),

          const SizedBox(height: 12),

          // =====================================================
          // FORM GROUP ITEM
          // =====================================================
          if (control is FormGroup && field.itemMeta != null)
            EntityFormGroup(
              field: field.itemMeta!,
              form: control,
              mode: mode,
              fieldBuilder: fieldBuilder,
            ),

          // =====================================================
          // PRIMITIVE ITEM
          // =====================================================
          if (control is! FormGroup)
            const Text('Array item renderer is not configured.'),
        ],
      ),
    );
  }

  // =============================================================
  // ADD NEW ARRAY ITEM
  // =============================================================

  void _addItem(FormArray<dynamic> formArray) {
    if (field.itemMeta == null) {
      return;
    }

    final itemMeta = field.itemMeta!;

    // -----------------------------------------------------------
    // Array item is a group/object.
    // -----------------------------------------------------------

    if (itemMeta.type == EntityFieldType.group) {
      final controls = <String, AbstractControl<dynamic>>{};

      for (final childField in itemMeta.fields) {
        controls[childField.name] = FormControl<dynamic>(
          value: childField.initialValue,
        );
      }

      formArray.add(FormGroup(controls));

      return;
    }

    // -----------------------------------------------------------
    // Primitive item.
    // -----------------------------------------------------------

    formArray.add(FormControl<dynamic>(value: itemMeta.initialValue));
  }
}
