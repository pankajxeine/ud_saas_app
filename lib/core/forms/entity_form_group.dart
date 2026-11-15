import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'models/entity_meta.dart';
import 'models/field_meta.dart';
import 'entity_form_field_factory.dart';
import 'entity_form_array.dart';

class EntityFormGroup extends StatelessWidget {
  const EntityFormGroup({
    super.key,
    required this.field,
    required this.form,
    required this.mode,
    this.fieldBuilder,
  });

  final FieldMeta<dynamic> field;
  final FormGroup form;
  final EntityMode mode;

  /// Allows the parent form to override individual fields.
  final Widget Function(
    BuildContext context,
    FieldMeta<dynamic> field,
    FormGroup form,
    EntityMode mode,
  )?
  fieldBuilder;

  @override
  Widget build(BuildContext context) {
    return _EntityFormGroupContent(
      field: field,
      form: form,
      mode: mode,
      fieldBuilder: fieldBuilder,
    );
  }
}

class _EntityFormGroupContent extends StatelessWidget {
  const _EntityFormGroupContent({
    required this.field,
    required this.form,
    required this.mode,
    this.fieldBuilder,
  });

  final FieldMeta<dynamic> field;
  final FormGroup form;
  final EntityMode mode;

  final Widget Function(
    BuildContext context,
    FieldMeta<dynamic> field,
    FormGroup form,
    EntityMode mode,
  )?
  fieldBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // GROUP HEADER
          // =====================================================
          if (field.label.isNotEmpty) ...[
            Text(field.label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
          ],

          if (field.helpText != null && field.helpText!.trim().isNotEmpty) ...[
            Text(field.helpText!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
          ],

          // =====================================================
          // NESTED FIELDS
          // =====================================================
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final childField in field.fields)
                _buildField(context, childField),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(BuildContext context, FieldMeta<dynamic> childField) {
    final control = form.control(childField.name);

    // ==========================================================
    // NESTED GROUP
    // ==========================================================

    if (childField.type == EntityFieldType.group) {
      if (control is! FormGroup) {
        return const SizedBox.shrink();
      }

      return EntityFormGroup(
        field: childField,
        form: control,
        mode: mode,
        fieldBuilder: fieldBuilder,
      );
    }

    // ==========================================================
    // FORM ARRAY
    // ==========================================================

    if (childField.type == EntityFieldType.array) {
      if (control is! FormArray) {
        return const SizedBox.shrink();
      }

      return EntityFormArray(
        field: childField,
        array: control,
        mode: mode,
        fieldBuilder: fieldBuilder,
      );
    }

    // ==========================================================
    // CUSTOM FIELD BUILDER
    // ==========================================================

    if (fieldBuilder != null) {
      return fieldBuilder!(context, childField, form, mode);
    }

    // ==========================================================
    // STANDARD FIELD
    // ==========================================================

    return EntityFormFieldFactory.build(
      context: context,
      field: childField,
      form: form,
      mode: mode,
    );
  }
}
