// import 'dart:convert';

import 'package:reactive_forms/reactive_forms.dart';
import '../helper/build_validators.dart';

import 'field_meta.dart';
import 'entity_grid_layout.dart';

enum EntityMode { view, edit, create }

class EntityMeta {
  const EntityMeta({
    required this.entityName,
    required this.fields,
    this.layout = const EntityGridLayout(),
  });

  final String entityName;
  final EntityGridLayout layout;
  final List<FieldMeta<dynamic>> fields;

  /// Creates a Reactive Forms [FormGroup].
  ///
  /// Value priority:
  ///
  /// 1. [initialData] value (Edit/View API data)
  /// 2. [FieldMeta.initialValue] (schema default)
  /// 3. null
  FormGroup toFormGroup({
    EntityMode mode = EntityMode.create,
    Map<String, dynamic>? initialData,
  }) {
    final controls = <String, AbstractControl<dynamic>>{};

    for (final field in fields) {
      final value = initialData != null && initialData.containsKey(field.name)
          ? initialData[field.name]
          : field.initialValue;

      controls[field.name] = _createControl(field, value);
    }

    final form = FormGroup(controls);

    for (final field in fields) {
      final control = form.control(field.name);

      if (mode == EntityMode.view || !field.editable) {
        control.markAsDisabled();
      }
    }

    return form;
  }

  AbstractControl<dynamic> _createControl(
    FieldMeta<dynamic> field,
    dynamic value,
  ) {
    final validators = buildValidators(field.validationRules);

    switch (field.type) {
      case EntityFieldType.text:
      case EntityFieldType.email:
      case EntityFieldType.password:
      case EntityFieldType.phone:
      case EntityFieldType.textarea:
      case EntityFieldType.select:
        return FormControl<String>(
          value: value?.toString(),
          validators: validators,
        );

      case EntityFieldType.number:
      case EntityFieldType.currency:
        return FormControl<num>(
          value: value == null
              ? null
              : value is num
              ? value
              : num.tryParse(value.toString()),
          validators: validators,
        );

      case EntityFieldType.boolean:
        return FormControl<bool>(
          value: value == null
              ? false
              : value is bool
              ? value
              : value.toString().toLowerCase() == 'true',
          validators: validators,
        );

      case EntityFieldType.multiselect:
        return FormControl<List<String>>(
          value: value is Iterable
              ? value.map((e) => e.toString()).toList()
              : <String>[],
          validators: validators,
        );

      case EntityFieldType.time:
      case EntityFieldType.date:
        return FormControl<DateTime>(
          value: value is DateTime
              ? value
              : value == null
              ? null
              : DateTime.tryParse(value.toString()),
          validators: validators,
        );

      case EntityFieldType.dateRange:
        return FormControl<dynamic>(value: value, validators: validators);

      case EntityFieldType.slider:
        return FormControl<double>(
          value: value == null
              ? null
              : value is num
              ? value.toDouble()
              : double.tryParse(value.toString()),
          validators: validators,
        );
    }
  }

  /// Normalizes API data to a suitable value for the field type.
  dynamic _normalizeFieldValue({
    required FieldMeta<dynamic> field,
    dynamic value,
  }) {
    if (value == null) {
      return null;
    }

    switch (field.type) {
      case EntityFieldType.text:
      case EntityFieldType.email:
      case EntityFieldType.password:
      case EntityFieldType.phone:
      case EntityFieldType.textarea:
        return value.toString();

      case EntityFieldType.select:
        return value;

      case EntityFieldType.number:
      case EntityFieldType.currency:
        if (value is num) {
          return value;
        }
        return num.tryParse(value.toString());

      case EntityFieldType.boolean:
        if (value is bool) {
          return value;
        }
        return value.toString().toLowerCase() == 'true';

      case EntityFieldType.slider:
        if (value is num) {
          return value.toDouble();
        }
        return double.tryParse(value.toString());

      case EntityFieldType.multiselect:
        if (value is Iterable) {
          return value.toList();
        }
        return <dynamic>[];
      case EntityFieldType.time:
      case EntityFieldType.date:
        if (value is DateTime) {
          return value;
        }
        return DateTime.tryParse(value.toString());

      case EntityFieldType.dateRange:
        return value;
    }
  }
}
