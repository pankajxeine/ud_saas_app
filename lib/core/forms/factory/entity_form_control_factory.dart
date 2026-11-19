import 'package:reactive_forms/reactive_forms.dart';

import '../models/entity_meta.dart';
import '../models/field_meta.dart';
import '../validation/entity_validation_factory.dart';

typedef EntityValidatorBuilder =
    List<Validator<dynamic>> Function(FieldMeta<dynamic> field);
typedef EntityAsyncValidatorBuilder =
    List<AsyncValidator<dynamic>> Function(FieldMeta<dynamic> field);

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
    EntityAsyncValidatorBuilder? asyncValidatorBuilder,
  }) {
    final resolvedValue = identical(value, _notProvided)
        ? field.initialValue
        : value;

    final validators = validatorBuilder?.call(field) ?? <Validator<dynamic>>[];
    final asyncValidators =
        asyncValidatorBuilder?.call(field) ?? <AsyncValidator<dynamic>>[];

    late final AbstractControl<dynamic> control;

    switch (field.type) {
      // Nested JSON object.
      case EntityFieldType.group:
        control = _createGroup(
          field.fields,
          initialData: _asMap(resolvedValue),
          mode: mode,
          validatorBuilder: validatorBuilder,
          asyncValidatorBuilder: asyncValidatorBuilder,
          validators: [
            ...validators,
            ...EntityValidationFactory.buildGroupValidators(
              field.groupValidationRules,
            ),
          ],
        );
        break;

      // JSON array.
      case EntityFieldType.array:
        control = _createArray(
          field,
          value: resolvedValue,
          mode: mode,
          validatorBuilder: validatorBuilder,
          asyncValidatorBuilder: asyncValidatorBuilder,
          validators: [
            ...validators,
            ...EntityValidationFactory.buildArrayValidators(
              field.arrayValidationRules,
            ),
          ],
        );
        break;

      // Primitive fields.
      default:
        control = _createPrimitiveControl(
          field,
          resolvedValue,
          validators,
          asyncValidators,
        );
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
    EntityAsyncValidatorBuilder? asyncValidatorBuilder,
  }) {
    return _createGroup(
      fields,
      initialData: initialData,
      mode: mode,
      validatorBuilder: validatorBuilder,
      asyncValidatorBuilder: asyncValidatorBuilder,
    );
  }

  /// Recursively creates a FormGroup.
  static FormGroup _createGroup(
    List<FieldMeta<dynamic>> fields, {
    Map<String, dynamic>? initialData,
    required EntityMode mode,
    EntityValidatorBuilder? validatorBuilder,
    EntityAsyncValidatorBuilder? asyncValidatorBuilder,
    List<Validator<dynamic>> validators = const [],
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
        asyncValidatorBuilder: asyncValidatorBuilder,
      );
    }

    return FormGroup(controls, validators: validators);
  }

  /// Recursively creates a FormArray.
  static FormArray<dynamic> _createArray(
    FieldMeta<dynamic> field, {
    Object? value,
    required EntityMode mode,
    EntityValidatorBuilder? validatorBuilder,
    EntityAsyncValidatorBuilder? asyncValidatorBuilder,
    List<Validator<dynamic>> validators = const [],
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
          asyncValidatorBuilder: asyncValidatorBuilder,
        ),
      );
    }

    return FormArray<dynamic>(controls, validators: validators);
  }

  /// Creates a typed primitive FormControl.
  static AbstractControl<dynamic> _createPrimitiveControl(
    FieldMeta<dynamic> field,
    dynamic value,
    List<Validator<dynamic>> validators,
    List<AsyncValidator<dynamic>> asyncValidators,
  ) {
    final normalized = normalizeValue(field: field, value: value);

    switch (field.type) {
      // String.
      case EntityFieldType.text:
      case EntityFieldType.email:
      case EntityFieldType.password:
      case EntityFieldType.phone:
      case EntityFieldType.textarea:
        return FormControl<String>(
          value: normalized?.toString(),
          validators: validators,
          asyncValidators: asyncValidators,
        );
      case EntityFieldType.select:
        return FormControl<dynamic>(
          value: normalized,
          validators: validators,
          asyncValidators: asyncValidators,
        );

      // Number.
      case EntityFieldType.number:
      case EntityFieldType.currency:
        return FormControl<num>(
          value: normalized as num?,
          validators: validators,
          asyncValidators: asyncValidators,
        );

      // Boolean.
      case EntityFieldType.boolean:
        return FormControl<bool>(
          value: normalized as bool? ?? false,
          validators: validators,
          asyncValidators: asyncValidators,
        );

      // Multi-select.
      case EntityFieldType.multiselect:
        return FormControl<List<String>>(
          value: normalized as List<String>? ?? <String>[],
          validators: validators,
          asyncValidators: asyncValidators,
        );

      // Date and time.
      case EntityFieldType.date:
      case EntityFieldType.time:
        return FormControl<DateTime>(
          value: normalized as DateTime?,
          validators: validators,
          asyncValidators: asyncValidators,
        );

      // Date range.
      case EntityFieldType.dateRange:
        return FormControl<dynamic>(
          value: normalized,
          validators: validators,
          asyncValidators: asyncValidators,
        );

      // Slider.
      case EntityFieldType.slider:
        return FormControl<double>(
          value: normalized as double?,
          validators: validators,
          asyncValidators: asyncValidators,
        );

      // Custom field: dynamic control by default.
      case EntityFieldType.custom:
        return FormControl<dynamic>(
          value: normalized,
          validators: validators,
          asyncValidators: asyncValidators,
        );

      // These types must be handled by the container factory.
      case EntityFieldType.group:
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
        return value;

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
      case EntityFieldType.custom:
      case EntityFieldType.group:
      case EntityFieldType.array:
        return value;
    }
  }

  static AbstractControl<dynamic> createArrayItem({
    required FieldMeta<dynamic> field,
    Object? value = _notProvided,
    required EntityMode mode,
    EntityValidatorBuilder? validatorBuilder,
  }) {
    final itemMeta = field.itemMeta;

    if (itemMeta == null) {
      final resolvedValue = identical(value, _notProvided) ? null : value;

      final control = FormControl<dynamic>(value: resolvedValue);

      if (mode == EntityMode.view || !field.editable) {
        control.markAsDisabled();
      }

      return control;
    }

    return create(
      itemMeta,
      value: value,
      mode: mode,
      validatorBuilder: validatorBuilder,
    );
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
