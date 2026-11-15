import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'models/entity_meta.dart';
import 'models/field_meta.dart';

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

    final control = form.control(field.name);
    debugPrint('UI control: ${form.control('ui').runtimeType}');

    // Nested controls are rendered by EntityFormGroup
    // and EntityFormArray, not by this factory.
    if (control is FormGroup || control is FormArray) {
      return const SizedBox.shrink();
    }

    // Prefer explicit widget metadata.
    // Fall back to a widget based on the field data type.
    // final widgetType = field.widget ?? _defaultWidget(field.type);
    final widgetType = _defaultWidget(field.type);
    print("widgetType $widgetType  $field.name");
    switch (widgetType) {
      // Text-based widgets
      case 'text':
      case 'email':
      case 'password':
      case 'phone':
        return InputTextField(field: field);

      case 'textarea':
        return InputTextField(field: field);

      // Numeric widgets
      case 'number':
      case 'currency':
        return InputTextField(field: field);

      // Boolean widgets
      case 'switch':
      case 'checkbox':
        return AppBooleanField(field: field);

      // Selection widgets
      case 'select':
      case 'multiselect':
        return AppSelectField(field: field);

      // Date/time widgets
      case 'date':
      case 'time':
      case 'dateRange':
        return InputTextField(field: field);

      case 'slider':
        return InputTextField(field: field);

      default:
        return _unsupportedWidget(field);
    }
  }

  static String _defaultWidget(EntityFieldType type) {
    switch (type) {
      case EntityFieldType.text:
        return 'text';

      case EntityFieldType.email:
        return 'email';

      case EntityFieldType.password:
        return 'password';

      case EntityFieldType.phone:
        return 'phone';

      case EntityFieldType.textarea:
        return 'textarea';

      case EntityFieldType.number:
        return 'number';

      case EntityFieldType.currency:
        return 'currency';

      case EntityFieldType.boolean:
        return 'switch';

      case EntityFieldType.select:
        return 'select';

      case EntityFieldType.multiselect:
        return 'multiselect';

      case EntityFieldType.date:
        return 'date';

      case EntityFieldType.time:
        return 'time';

      case EntityFieldType.dateRange:
        return 'dateRange';

      case EntityFieldType.slider:
        return 'slider';

      // These are handled by the recursive renderer.
      case EntityFieldType.group:
      case EntityFieldType.custom:
      case EntityFieldType.array:
        // case EntityFieldType.custom:
        return 'unsupported';
    }
  }

  static Widget _unsupportedWidget(FieldMeta<dynamic> field) {
    return InputTextField(field: field);
  }
}
