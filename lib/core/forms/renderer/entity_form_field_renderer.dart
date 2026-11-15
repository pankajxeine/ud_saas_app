import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../models/entity_meta.dart';
import '../models/field_meta.dart';
import '../registry/entity_field_widget_registry.dart';

class EntityFormFieldRenderer extends StatelessWidget {
  const EntityFormFieldRenderer({
    super.key,
    required this.field,
    required this.form,
    required this.control,
    required this.mode,
    required this.registry,
  });

  final FieldMeta<dynamic> field;
  final FormGroup form;
  final AbstractControl<dynamic> control;
  final EntityMode mode;
  final EntityFieldWidgetRegistry registry;

  @override
  Widget build(BuildContext context) {
    if (control is! FormControl) {
      return const SizedBox.shrink();
    }

    return ReactiveForm(
      formGroup: form,
      child: registry.build(
        context: context,
        field: field,
        form: form,
        control: control,
        mode: mode,
      ),
    );
  }
}
