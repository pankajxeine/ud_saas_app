import 'dart:convert';

import 'package:reactive_forms/reactive_forms.dart';

/// ============================================================
/// ENTITY FIELD TYPES
/// ============================================================

enum EntityFieldType {
  text,
  email,
  password,
  phone,
  number,
  currency,
  boolean,
  date,
  dateTime,
  dateRange,
  select,
  multiselect,
  textarea,
  slider,
}

/// ============================================================
/// ENTITY FORM MODE
/// ============================================================

enum EntityMode { create, edit, view }

/// ============================================================
/// FIELD OPTION
/// ============================================================

class FieldOption {
  const FieldOption({
    required this.value,
    required this.label,
    this.disabled = false,
  });

  final dynamic value;
  final String label;
  final bool disabled;

  factory FieldOption.fromJson(dynamic json) {
    if (json is String || json is num || json is bool) {
      return FieldOption(value: json, label: json.toString());
    }

    if (json is Map) {
      final map = Map<String, dynamic>.from(json);

      final value = map['value'] ?? map['id'] ?? map['code'];

      return FieldOption(
        value: value,
        label:
            map['label']?.toString() ??
            map['name']?.toString() ??
            value?.toString() ??
            '',
        disabled: map['disabled'] == true,
      );
    }

    return FieldOption(value: json, label: json?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'label': label, 'disabled': disabled};
  }
}

/// ============================================================
/// CONDITIONAL VISIBILITY
/// ============================================================

class FieldVisibilityRule {
  const FieldVisibilityRule({
    required this.control,
    this.equals,
    this.notEquals,
    this.contains,
  });

  final String control;
  final dynamic equals;
  final dynamic notEquals;
  final dynamic contains;

  factory FieldVisibilityRule.fromJson(Map<String, dynamic> json) {
    return FieldVisibilityRule(
      control: json['control']?.toString() ?? '',
      equals: json['equals'],
      notEquals: json['notEquals'],
      contains: json['contains'],
    );
  }

  bool evaluate(FormGroup form) {
    if (control.isEmpty || !form.contains(control)) {
      return true;
    }

    final value = form.control(control).value;

    if (equals != null) {
      return value == equals;
    }

    if (notEquals != null) {
      return value != notEquals;
    }

    if (contains != null) {
      if (value is Iterable) {
        return value.contains(contains);
      }

      if (value is String) {
        return value.contains(contains.toString());
      }
    }

    return true;
  }
}

/// ============================================================
/// VALIDATOR BUILDER
/// ============================================================

List<Validator<dynamic>> buildValidators(Map<String, dynamic> rules) {
  final validators = <Validator<dynamic>>[];

  rules.forEach((key, value) {
    switch (key) {
      case 'required':
        if (value == true) {
          validators.add(Validators.required);
        }
        break;

      case 'requiredTrue':
        if (value == true) {
          validators.add(Validators.requiredTrue);
        }
        break;

      case 'email':
        if (value == true) {
          validators.add(Validators.email);
        }
        break;

      case 'number':
        if (value == true) {
          validators.add(Validators.number(allowNull: true));
        }
        break;

      case 'min':
        if (value is num) {
          validators.add(Validators.min(value));
        }
        break;

      case 'max':
        if (value is num) {
          validators.add(Validators.max(value));
        }
        break;

      case 'minLength':
        if (value is num) {
          validators.add(Validators.minLength(value.toInt()));
        }
        break;

      case 'maxLength':
        if (value is num) {
          validators.add(Validators.maxLength(value.toInt()));
        }
        break;

      case 'pattern':
        if (value is String && value.isNotEmpty) {
          validators.add(Validators.pattern(value));
        }
        break;

      case 'creditCard':
        if (value == true) {
          validators.add(Validators.creditCard);
        }
        break;

      case 'equals':
        if (value != null) {
          validators.add(Validators.equals(value));
        }
        break;

      case 'contains':
        if (value != null) {
          validators.add(Validators.contains(value));
        }
        break;

      case 'oneOf':
        if (value is Iterable) {
          validators.add(Validators.oneOf(value.toList()));
        }
        break;

      case 'mustMatch':
        if (value is Map) {
          final map = Map<String, dynamic>.from(value);

          final control = map['control']?.toString();
          final matchingControl = map['matchingControl']?.toString();

          if (control != null &&
              matchingControl != null &&
              control.isNotEmpty &&
              matchingControl.isNotEmpty) {
            validators.add(Validators.mustMatch(control, matchingControl));
          }
        }
        break;
    }
  });

  return validators;
}

/// ============================================================
/// FIELD META
/// ============================================================

class FieldMeta<T> {
  const FieldMeta({
    required this.name,
    required this.label,
    required this.type,
    this.editable = true,
    this.visible = true,
    this.required = false,
    this.initialValue,
    this.placeholder,
    this.helpText,
    this.maxLength,
    this.options = const [],
    this.validationRules = const {},
    this.colSpan = 1,
    this.rowSpan = 1,
    this.features = const {},
    this.visibilityRule,
  });

  /// API / database property name.
  final String name;

  /// Display label.
  final String label;

  final EntityFieldType type;

  /// Can this field be edited?
  final bool editable;

  /// Static visibility.
  final bool visible;

  final bool required;

  /// Default value from schema.
  final T? initialValue;

  final String? placeholder;

  final String? helpText;

  final int? maxLength;

  final List<FieldOption> options;

  final Map<String, dynamic> validationRules;

  /// Layout metadata.
  final int colSpan;
  final int rowSpan;

  /// UI-specific configuration.
  ///
  /// Example:
  ///
  /// {
  ///   "showClearButton": true,
  ///   "showCopyButton": true,
  ///   "minLines": 3
  /// }
  final Map<String, dynamic> features;

  final FieldVisibilityRule? visibilityRule;

  bool get isRequired {
    return required || validationRules['required'] == true;
  }

  bool isVisible(FormGroup form) {
    if (!visible) {
      return false;
    }

    return visibilityRule?.evaluate(form) ?? true;
  }

  bool isEditable(EntityMode mode) {
    if (mode == EntityMode.view) {
      return false;
    }

    return editable;
  }

  FormControl<T> toFormControl({
    T? value,
    EntityMode mode = EntityMode.create,
  }) {
    final validators = <Validator<dynamic>>[
      ...buildValidators(validationRules),
    ];

    if (required && validationRules['required'] != true) {
      validators.add(Validators.required);
    }

    final control = FormControl<T>(
      value: value ?? initialValue,
      validators: validators,
    );

    if (!isEditable(mode)) {
      control.markAsDisabled();
    }

    return control;
  }
}

/// ============================================================
/// ENTITY META
/// ============================================================

class EntityMeta {
  const EntityMeta({
    required this.entityName,
    required this.fields,
    this.title,
    this.description,
  });

  /// Entity identifier.
  ///
  /// Examples:
  /// - User
  /// - Order
  /// - Product
  /// - MetaModule
  final String entityName;

  final String? title;
  final String? description;

  final List<FieldMeta<dynamic>> fields;

  /// Creates a Reactive FormGroup.
  ///
  /// [initialData] should contain API/entity values when editing.
  FormGroup toFormGroup({
    EntityMode mode = EntityMode.create,
    Map<String, dynamic> initialData = const <String, dynamic>{},
  }) {
    final controls = <String, AbstractControl<dynamic>>{};

    for (final field in fields) {
      final dynamic value = initialData.containsKey(field.name)
          ? initialData[field.name]
          : field.initialValue;

      final control = FormControl<dynamic>(
        value: value,
        validators: [
          ...buildValidators(field.validationRules),
          if (field.required && field.validationRules['required'] != true)
            Validators.required,
        ],
      );

      if (!field.isEditable(mode)) {
        control.markAsDisabled();
      }

      controls[field.name] = control;
    }

    return FormGroup(controls);
  }

  FieldMeta<dynamic>? fieldByName(String name) {
    for (final field in fields) {
      if (field.name == name) {
        return field;
      }
    }

    return null;
  }

  /// Returns values suitable for API submission.
  Map<String, dynamic> toPayload(
    FormGroup form, {
    bool includeDisabled = false,
  }) {
    final value = includeDisabled ? form.rawValue : form.value;

    return Map<String, dynamic>.from(value);
  }
}

/// ============================================================
/// JSON → ENTITY META
/// ============================================================

EntityMeta entityMetaFromJson(Map<String, dynamic> json) {
  final rawFields = json['fields'];

  final fieldsJson = rawFields is List ? rawFields : const <dynamic>[];

  return EntityMeta(
    entityName:
        json['entityName']?.toString() ??
        json['entity']?.toString() ??
        'Entity',
    title: json['title']?.toString(),
    description: json['description']?.toString(),
    fields: fieldsJson
        .whereType<Map>()
        .map((field) => _fieldMetaFromJson(Map<String, dynamic>.from(field)))
        .toList(),
  );
}

/// ============================================================
/// JSON → FIELD META
/// ============================================================

FieldMeta<dynamic> _fieldMetaFromJson(Map<String, dynamic> json) {
  final type = _parseFieldType(json['type']?.toString());

  final validationRules = _mapFromDynamic(json['validationRules']);

  final features = _mapFromDynamic(json['features']);

  final visibility = _mapFromDynamic(json['visibility']);

  return FieldMeta<dynamic>(
    name: json['name']?.toString() ?? '',
    label: json['label']?.toString() ?? json['name']?.toString() ?? '',
    type: type,
    editable: json['editable'] != false,
    visible: json['visible'] != false,
    required: json['required'] == true || validationRules['required'] == true,
    initialValue: _normalizeInitialValue(json['initialValue'], type),
    placeholder: json['placeholder']?.toString(),
    helpText: json['helpText']?.toString(),
    maxLength: _intValue(json['maxLength']),
    options: _parseOptions(json['options']),
    validationRules: validationRules,
    colSpan: _intValue(json['colSpan']) ?? 1,
    rowSpan: _intValue(json['rowSpan']) ?? 1,
    features: features,
    visibilityRule: visibility.isEmpty
        ? null
        : FieldVisibilityRule.fromJson(visibility),
  );
}

/// ============================================================
/// FIELD TYPE PARSER
/// ============================================================

EntityFieldType _parseFieldType(String? value) {
  if (value == null || value.isEmpty) {
    return EntityFieldType.text;
  }

  final normalized = value
      .replaceAll('_', '')
      .replaceAll('-', '')
      .toLowerCase();

  switch (normalized) {
    case 'email':
      return EntityFieldType.email;

    case 'password':
      return EntityFieldType.password;

    case 'phone':
      return EntityFieldType.phone;

    case 'number':
    case 'integer':
    case 'decimal':
      return EntityFieldType.number;

    case 'currency':
      return EntityFieldType.currency;

    case 'boolean':
    case 'bool':
    case 'checkbox':
    case 'switch':
      return EntityFieldType.boolean;

    case 'date':
      return EntityFieldType.date;

    case 'datetime':
      return EntityFieldType.dateTime;

    case 'daterange':
      return EntityFieldType.dateRange;

    case 'select':
    case 'dropdown':
      return EntityFieldType.select;

    case 'multiselect':
      return EntityFieldType.multiselect;

    case 'textarea':
    case 'multiline':
      return EntityFieldType.textarea;

    case 'slider':
      return EntityFieldType.slider;

    default:
      return EntityFieldType.text;
  }
}

/// ============================================================
/// OPTIONS PARSER
/// ============================================================

List<FieldOption> _parseOptions(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value.map(FieldOption.fromJson).toList();
}

/// ============================================================
/// INITIAL VALUE NORMALIZER
/// ============================================================

dynamic _normalizeInitialValue(dynamic value, EntityFieldType type) {
  if (value == null) {
    return null;
  }

  switch (type) {
    case EntityFieldType.number:
    case EntityFieldType.currency:
    case EntityFieldType.slider:
      if (value is num) {
        return value;
      }
      return num.tryParse(value.toString());

    case EntityFieldType.boolean:
      if (value is bool) {
        return value;
      }
      return value.toString().toLowerCase() == 'true';

    case EntityFieldType.multiselect:
      if (value is List) {
        return List<dynamic>.from(value);
      }
      return [value];

    case EntityFieldType.text:
    case EntityFieldType.email:
    case EntityFieldType.password:
    case EntityFieldType.phone:
    case EntityFieldType.date:
    case EntityFieldType.dateTime:
    case EntityFieldType.dateRange:
    case EntityFieldType.select:
    case EntityFieldType.textarea:
      return value is String ? value : jsonEncode(value);
  }
}

/// ============================================================
/// SAFE HELPERS
/// ============================================================

Map<String, dynamic> _mapFromDynamic(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return <String, dynamic>{};
}

int? _intValue(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '');
}
