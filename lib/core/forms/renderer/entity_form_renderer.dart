import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../layout/entity_form_layout.dart';
import '../models/entity_meta.dart';
import '../models/field_meta.dart';
import '../registry/entity_field_widget_registry.dart';

import 'entity_form_array.dart';
import 'entity_form_field_renderer.dart';
import 'entity_form_group.dart';

class EntityFormRenderer extends StatelessWidget {
  const EntityFormRenderer({
    super.key,
    required this.fields,
    required this.form,
    required this.mode,
    required this.registry,
    this.parentPath = '',
    this.showMissingControls = false,
  });

  final List<FieldMeta<dynamic>> fields;

  /// The FormGroup corresponding to the current metadata level.
  ///
  /// Root renderer receives the root FormGroup.
  /// Nested group renderer receives its child FormGroup.
  /// Array item renderer receives the item's FormGroup.
  final FormGroup form;

  final EntityMode mode;
  final EntityFieldWidgetRegistry registry;

  /// Used for readable diagnostics, e.g. ui.label or contacts.0.email.
  final String parentPath;

  /// When enabled, missing metadata controls show a diagnostic widget.
  final bool showMissingControls;

  @override
  Widget build(BuildContext context) {
    final visibleFields = fields
        .where(_isVisible)
        .where((field) => form.contains(field.name))
        .toList();

    return EntityFormLayout(
      fields: visibleFields,
      itemBuilder: (context, field) {
        return _buildField(context, field);
      },
    );
  }

  Widget _buildField(BuildContext context, FieldMeta<dynamic> field) {
    final control = form.control(field.name);

    if (control is FormGroup) {
      return EntityFormGroup(
        field: field,
        form: control,
        mode: mode,
        registry: registry,
      );
    }

    if (control is FormArray) {
      return EntityFormArray(
        field: field,
        array: control,
        mode: mode,
        registry: registry,
      );
    }

    return EntityFormFieldRenderer(
      field: field,
      form: form,
      control: control,
      mode: mode,
      registry: registry,
    );
  }

  bool _isVisible(FieldMeta<dynamic> field) {
    return field.isVisible(form);
  }
}
