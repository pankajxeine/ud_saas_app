import 'package:reactive_forms/reactive_forms.dart';

/// --------------------
/// ENUMS
/// --------------------
enum EntityFieldType {
  text,
  email,
  password,
  phone,
  number,
  currency,
  boolean,
  date,
  dateRange,
  select,
  multiselect,
  textarea,
  slider,
}

enum EntityMode { view, edit, create }

/// --------------------
/// VALIDATOR BUILDER
/// --------------------
List<Validator<dynamic>> buildValidators(Map<String, dynamic> rules) {
  final validators = <Validator<dynamic>>[];

  rules.forEach((key, value) {
    switch (key) {
      case 'required':
        if (value == true) validators.add(Validators.required);
        break;
      case 'requiredTrue':
        if (value == true) validators.add(Validators.requiredTrue);
        break;
      case 'email':
        if (value == true) validators.add(Validators.email);
        break;
      case 'number':
        if (value == true) validators.add(Validators.number(allowNull: true));
        break;
      case 'min':
        if (value is num) validators.add(Validators.min(value));
        break;
      case 'max':
        if (value is num) validators.add(Validators.max(value));
        break;
      case 'minLength':
        if (value is int) validators.add(Validators.minLength(value));
        break;
      case 'maxLength':
        if (value is int) validators.add(Validators.maxLength(value));
        break;
      case 'pattern':
        if (value is String) validators.add(Validators.pattern(value));
        break;
      case 'creditCard':
        if (value == true) validators.add(Validators.creditCard);
        break;
      case 'equals':
        if (value != null) validators.add(Validators.equals(value));
        break;
      case 'compose':
        if (value is Iterable<Validator<dynamic>>) {
          validators.add(Validators.compose(value.toList()));
        }
        break;

      case 'composeOR':
        if (value is Iterable<Validator<dynamic>>) {
          validators.add(Validators.composeOR(value.toList()));
        }
        break;
      case 'contains':
        if (value != null) validators.add(Validators.contains(value));
        break;
      case 'any':
        if (value is AnyValidatorFunctionTest<dynamic>) {
          validators.add(Validators.any(value));
        }
        break;
      case 'oneOf':
        if (value is Iterable) {
          validators.add(Validators.oneOf(value.toList()));
        }
        break;
      case 'mustMatch':
        if (value is Map<String, String>) {
          final c1 = value['control'];
          final c2 = value['matchingControl'];
          if (c1 != null && c2 != null) {
            validators.add(Validators.mustMatch(c1, c2));
          }
        }
        break;
      case 'compare':
        if (value is Map<String, dynamic>) {
          final c1 = value['control'];
          final c2 = value['matchingControl'];
          final op = value['operator'];
          if (c1 != null && c2 != null && op != null) {
            validators.add(Validators.compare(c1, c2, op));
          }
        }
        break;
    }
  });

  return validators;
}

/// --------------------
/// FIELD META
/// --------------------
class FieldMeta<T> {
  const FieldMeta({
    required this.name,
    required this.label,
    required this.type,
    this.editable = true,
    this.initialValue,
    this.placeholder,
    this.options,
    this.validationRules = const {},
    this.colSpan = 1,
    this.rowSpan = 1,
    this.features,
  });

  final String name;
  final String label;
  final EntityFieldType type;
  final bool editable;
  final T? initialValue;

  final String? placeholder;
  final List<String>? options;

  final int colSpan;
  final int rowSpan;

  final Map<String, dynamic> validationRules;
  final Map<String, dynamic>? features;

  FormControl<T> toFormControl() {
    return FormControl<T>(
      value: initialValue,
      validators: buildValidators(validationRules),
    );
  }
}

/// --------------------
/// ENTITY META
/// --------------------
class EntityMeta {
  const EntityMeta({required this.entityName, required this.fields});

  final String entityName;
  final List<FieldMeta> fields;

  FormGroup toFormGroup({EntityMode mode = EntityMode.create}) {
    final controls = {
      for (var f in fields.where((f) => f.editable || mode == EntityMode.view))
        f.name: f.toFormControl(),
    };
    print("control $controls");
    return FormGroup(controls);
  }
}

/// --------------------
/// JSON → MODEL
/// --------------------
// EntityMeta entityMetaFromJson(Map<String, dynamic> json) {
//   final entityName = json['entityName'] as String;
//   final fieldsJson = json['fields'] as List<dynamic>;

//   final fields = fieldsJson.map((f) {
//     final typeString = f['type'] as String? ?? 'text';
//     final type = EntityFieldType.values.firstWhere(
//       (t) => t.toString().split('.').last == typeString,
//       orElse: () => EntityFieldType.text,
//     );

//     return FieldMeta<dynamic>(
//       name: f['name'] as String,
//       label: f['label'] as String,
//       type: type,
//       editable: f['editable'] as bool? ?? true,
//       initialValue: f['initialValue'],
//       placeholder: f['placeholder'] as String?,
//       options: (f['options'] as List<dynamic>?)?.cast<String>(),
//       step: f['step'] as num?,
//       validationRules: (f['validationRules'] as Map<String, dynamic>?) ?? {},
//     );
//   }).toList();

//   return EntityMeta(entityName: entityName, fields: fields);
// }

EntityMeta entityMetaFromJson(Map<String, dynamic> json) {
  final entityName = json['entityName'] as String;
  final fieldsJson = json['fields'] as List<dynamic>;

  final fields = fieldsJson.map((f) => _fieldMetaFromJson(f)).toList();

  return EntityMeta(entityName: entityName, fields: fields);
}

FieldMeta _fieldMetaFromJson(Map<String, dynamic> f) {
  final typeString = f['type'] as String? ?? 'text';
  final type = EntityFieldType.values.firstWhere(
    (t) => t.toString().split('.').last == typeString,
    orElse: () => EntityFieldType.text,
  );

  Map<String, dynamic> rules =
      (f['validationRules'] as Map<String, dynamic>?) ?? {};

  Map<String, dynamic> features =
      (f['features'] as Map<String, dynamic>?) ?? {};

  switch (type) {
    case EntityFieldType.text:
    case EntityFieldType.email:
    case EntityFieldType.password:
    case EntityFieldType.textarea:
    case EntityFieldType.phone:
    case EntityFieldType.select:
      return FieldMeta<String>(
        name: f['name'],
        label: f['label'],
        placeholder: f['placeholder'] as String?,
        type: type,
        initialValue: f['initialValue'] as String?,
        options: (f['options'] as List<dynamic>?)?.cast<String>(),
        validationRules: rules,
        features: features,
      );

    case EntityFieldType.multiselect:
      return FieldMeta<List<String>>(
        name: f['name'],
        label: f['label'],
        placeholder: f['placeholder'] as String?,
        type: type,
        initialValue: (f['initialValue'] as List<dynamic>?)?.cast<String>(),
        options: (f['options'] as List<dynamic>?)?.cast<String>(),
        validationRules: rules,
      );

    case EntityFieldType.number:
    case EntityFieldType.currency:
      return FieldMeta<int>(
        name: f['name'],
        label: f['label'],
        placeholder: f['placeholder'] as String?,
        type: type,
        initialValue: f['initialValue'] as int?,
        validationRules: rules,
      );

    case EntityFieldType.slider:
      return FieldMeta<double>(
        name: f['name'],
        label: f['label'],
        placeholder: f['placeholder'] as String?,
        type: type,
        initialValue: f['initialValue'] as double?,
        validationRules: rules,
      );

    case EntityFieldType.boolean:
      return FieldMeta<bool>(
        name: f['name'],
        label: f['label'],
        placeholder: f['placeholder'] as String?,
        type: type,
        initialValue: f['initialValue'] as bool?,
        validationRules: rules,
      );

    case EntityFieldType.date:
    case EntityFieldType.dateRange:
      return FieldMeta<DateTime>(
        name: f['name'],
        label: f['label'],
        placeholder: f['placeholder'] as String?,
        type: type,
        initialValue: f['initialValue'] != null
            ? DateTime.parse(f['initialValue'])
            : null,
        validationRules: rules,
      );
  }
}
