import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'entity_meta.dart';

import 'widgets/input_text_field.dart';
// import 'widgets/input_number_field.dart';
import 'widgets/input_boolean_field.dart';
import 'widgets/input_select_field.dart';
// import 'widgets/input_multiselect_field.dart';
// import 'widgets/input_date_field.dart';
//import 'widgets/input_date_range_field.dart';
//import 'widgets/input_slider_field.dart';

class EntityFormFieldFactory {
  EntityFormFieldFactory._();

  static Widget build({
    required BuildContext context,
    required FieldMeta<dynamic> field,
    required FormGroup form,
    required EntityMode mode,
  }) {
    if (!form.contains(field.name)) {
      return const SizedBox.shrink();
    }

    switch (field.type) {
      case EntityFieldType.text:
      case EntityFieldType.email:
      case EntityFieldType.password:
      case EntityFieldType.phone:
      case EntityFieldType.textarea:
        return InputTextField(field: field);

      case EntityFieldType.number:
      case EntityFieldType.currency:
        return InputTextField(field: field);

      case EntityFieldType.boolean:
        return AppBooleanField(field: field);

      case EntityFieldType.select:
        return AppSelectField(field: field);

      case EntityFieldType.multiselect:
        return AppSelectField(field: field);

      case EntityFieldType.date:
      case EntityFieldType.time:
        return InputTextField(field: field);

      case EntityFieldType.dateRange:
        return InputTextField(field: field);

      case EntityFieldType.slider:
        return InputTextField(field: field);
    }
  }
}
