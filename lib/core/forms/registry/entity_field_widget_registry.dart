import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../models/entity_meta.dart';
import '../models/field_meta.dart';

import '../widgets/input_text_field.dart';
import '../widgets/input_boolean_field.dart';
import '../widgets/input_select_field.dart';

import 'entity_field_widget_builder.dart';

class EntityFieldWidgetRegistry {
  EntityFieldWidgetRegistry({Map<String, EntityFieldWidgetBuilder>? builders})
    : _builders = {..._defaultBuilders(), ...?builders};

  final Map<String, EntityFieldWidgetBuilder> _builders;

  Widget build({
    required BuildContext context,
    required FieldMeta<dynamic> field,
    required FormGroup form,
    required AbstractControl<dynamic> control,
    required EntityMode mode,
  }) {
    final widgetName = _resolveWidgetName(field);

    final builder = _builders[widgetName];

    if (builder == null) {
      return _UnsupportedFieldWidget(field: field, widgetName: widgetName);
    }

    return builder(
      context: context,
      field: field,
      form: form,
      control: control,
      mode: mode,
    );
  }

  String _resolveWidgetName(FieldMeta<dynamic> field) {
    // Prefer explicit JSON widget.
    if (field.widget != null && field.widget!.isNotEmpty) {
      return field.widget!;
    }

    return _defaultWidgetForType(field.type);
  }

  String _defaultWidgetForType(EntityFieldType type) {
    switch (type) {
      case EntityFieldType.text:
        return 'text';

      case EntityFieldType.email:
        return 'email';

      case EntityFieldType.password:
        return 'password';

      case EntityFieldType.phone:
        return 'text';

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

      case EntityFieldType.group:
      case EntityFieldType.array:
      case EntityFieldType.custom:
        return 'unsupported';
    }
  }

  static Map<String, EntityFieldWidgetBuilder> _defaultBuilders() {
    return {
      'text': _textBuilder,
      'email': _textBuilder,
      'password': _textBuilder,
      'phone': _textBuilder,
      'textarea': _textBuilder,

      'number': _textBuilder,
      'currency': _textBuilder,

      'switch': _booleanBuilder,
      'checkbox': _booleanBuilder,

      'select': _selectBuilder,
      'multiselect': _selectBuilder,
    };
  }

  static Widget _textBuilder({
    required BuildContext context,
    required FieldMeta<dynamic> field,
    required FormGroup form,
    required AbstractControl<dynamic> control,
    required EntityMode mode,
  }) {
    return InputTextField(field: field);
  }

  static Widget _booleanBuilder({
    required BuildContext context,
    required FieldMeta<dynamic> field,
    required FormGroup form,
    required AbstractControl<dynamic> control,
    required EntityMode mode,
  }) {
    return AppBooleanField(field: field);
  }

  static Widget _selectBuilder({
    required BuildContext context,
    required FieldMeta<dynamic> field,
    required FormGroup form,
    required AbstractControl<dynamic> control,
    required EntityMode mode,
  }) {
    return AppSelectField(field: field);
  }
}

class _UnsupportedFieldWidget extends StatelessWidget {
  const _UnsupportedFieldWidget({
    required this.field,
    required this.widgetName,
  });

  final FieldMeta<dynamic> field;
  final String widgetName;

  @override
  Widget build(BuildContext context) {
    return Text('Unsupported field widget: $widgetName (${field.name})');
  }
}
