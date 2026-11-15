import 'package:reactive_forms/reactive_forms.dart';

import 'models/entity_meta.dart';
import 'models/field_meta.dart';

typedef EntityValidatorBuilder =
    List<Validator<dynamic>> Function(FieldMeta<dynamic> field);

class EntityFormControlFactory {
  EntityFormControlFactory._();

  // Distinguishes an omitted value from an explicitly supplied null.
  static const Object _notProvided = Object();

  /// Creates a FormControl, FormGroup or FormArray from metadata.
  static AbstractControl<dynamic> create(
    FieldMeta<dynamic> field, {
    Object? value = _notProvided,
    required EntityMode mode,
    EntityValidatorBuilder? validatorBuilder,
  }) {
    final resolvedValue = identical(value, _notProvided)
        ? field.initialValue
        : value;

    final validators = validatorBuilder?.call(field) ?? <Validator<dynamic>>[];

    late final AbstractControl<dynamic> control;

    switch (field.type) {
      // Nested JSON object.
      case EntityFieldType.group:
        control = _createGroup(
          field.fields,
          initialData: _asMap(resolvedValue),
          mode: mode,
          validatorBuilder: validatorBuilder,
        );
        break;

      // JSON array.
      case EntityFieldType.array:
        control = _createArray(
          field,
          value: resolvedValue,
          mode: mode,
          validatorBuilder: validatorBuilder,
        );
        break;

      // Primitive fields.
      default:
        control = _createPrimitiveControl(field, resolvedValue, validators);
    }

    if (mode == EntityMode.view || !field.editable) {
      control.markAsDisabled();
    }

    return control;
  }

  /// Creates the root FormGroup.
  static FormGroup createFormGroup({
    required List<FieldMeta<dynamic>> fields,
    Map<String, dynamic>? initialData,
    EntityMode mode = EntityMode.create,
    EntityValidatorBuilder? validatorBuilder,
  }) {
    return _createGroup(
      fields,
      initialData: initialData,
      mode: mode,
      validatorBuilder: validatorBuilder,
    );
  }

  /// Recursively creates a FormGroup.
  static FormGroup _createGroup(
    List<FieldMeta<dynamic>> fields, {
    Map<String, dynamic>? initialData,
    required EntityMode mode,
    EntityValidatorBuilder? validatorBuilder,
  }) {
    final controls = <String, AbstractControl<dynamic>>{};

    for (final field in fields) {
      final hasValue =
          initialData != null && initialData.containsKey(field.name);

      controls[field.name] = create(
        field,
        value: hasValue ? initialData[field.name] : _notProvided,
        mode: mode,
        validatorBuilder: validatorBuilder,
      );
    }

    return FormGroup(controls);
  }

  /// Recursively creates a FormArray.
  static FormArray<dynamic> _createArray(
    FieldMeta<dynamic> field, {
    Object? value,
    required EntityMode mode,
    EntityValidatorBuilder? validatorBuilder,
  }) {
    final values = value is Iterable && value is! String
        ? value.toList()
        : <dynamic>[];

    final controls = <AbstractControl<dynamic>>[];

    for (final itemValue in values) {
      final itemMeta = field.itemMeta;

      if (itemMeta == null) {
        controls.add(FormControl<dynamic>(value: itemValue));
        continue;
      }

      controls.add(
        create(
          itemMeta,
          value: itemValue,
          mode: mode,
          validatorBuilder: validatorBuilder,
        ),
      );
    }

    return FormArray<dynamic>(controls);
  }

  /// Creates a typed primitive FormControl.
  static AbstractControl<dynamic> _createPrimitiveControl(
    FieldMeta<dynamic> field,
    dynamic value,
    List<Validator<dynamic>> validators,
  ) {
    final normalized = normalizeValue(field: field, value: value);

    switch (field.type) {
      // String.
      case EntityFieldType.text:
      case EntityFieldType.email:
      case EntityFieldType.password:
      case EntityFieldType.phone:
      case EntityFieldType.textarea:
      case EntityFieldType.select:
        return FormControl<String>(
          value: normalized as String?,
          validators: validators,
        );

      // Number.
      case EntityFieldType.number:
      case EntityFieldType.currency:
        return FormControl<num>(
          value: normalized as num?,
          validators: validators,
        );

      // Boolean.
      case EntityFieldType.boolean:
        return FormControl<bool>(
          value: normalized as bool? ?? false,
          validators: validators,
        );

      // Multi-select.
      case EntityFieldType.multiselect:
        return FormControl<List<String>>(
          value: normalized as List<String>? ?? <String>[],
          validators: validators,
        );

      // Date and time.
      case EntityFieldType.date:
      case EntityFieldType.time:
        return FormControl<DateTime>(
          value: normalized as DateTime?,
          validators: validators,
        );

      // Date range.
      case EntityFieldType.dateRange:
        return FormControl<dynamic>(value: normalized, validators: validators);

      // Slider.
      case EntityFieldType.slider:
        return FormControl<double>(
          value: normalized as double?,
          validators: validators,
        );

      // Custom field: dynamic control by default.
      // case EntityFieldType.custom:
      //   return FormControl<dynamic>(value: normalized, validators: validators);

      // These types must be handled by the container factory.
      case EntityFieldType.group:
      case EntityFieldType.custom:
      case EntityFieldType.array:
        throw StateError(
          'Unexpected container type ${field.type} '
          'in primitive control creation.',
        );
    }
  }

  /// Normalizes API values before assigning them to controls.
  static dynamic normalizeValue({
    required FieldMeta<dynamic> field,
    dynamic value,
  }) {
    if (value == null) return null;

    switch (field.type) {
      case EntityFieldType.text:
      case EntityFieldType.email:
      case EntityFieldType.password:
      case EntityFieldType.phone:
      case EntityFieldType.textarea:
      case EntityFieldType.select:
        return value.toString();

      case EntityFieldType.number:
      case EntityFieldType.currency:
        if (value is num) return value;
        return num.tryParse(value.toString());

      case EntityFieldType.boolean:
        if (value is bool) return value;

        final normalized = value.toString().trim().toLowerCase();

        return normalized == 'true' || normalized == '1' || normalized == 'yes';

      case EntityFieldType.slider:
        if (value is num) return value.toDouble();
        return double.tryParse(value.toString());

      case EntityFieldType.multiselect:
        if (value is Iterable) {
          return value.map((item) => item.toString()).toList();
        }
        return <String>[];

      case EntityFieldType.date:
      case EntityFieldType.time:
        if (value is DateTime) return value;
        return DateTime.tryParse(value.toString());

      case EntityFieldType.dateRange:
      // case EntityFieldType.custom:
      case EntityFieldType.group:
      case EntityFieldType.custom:
      case EntityFieldType.array:
        return value;
    }
  }

  /// Converts a JSON map safely.
  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }
}
