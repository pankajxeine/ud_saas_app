import 'dart:convert';

import 'package:reactive_forms/reactive_forms.dart';

enum EntityFieldType {
  text,
  email,
  password,
  phone,
  number,
  currency,
  boolean,
  date,
  time,
  dateRange,
  select,
  multiselect,
  textarea,
  slider,
}

enum EntityMode { view, edit, create }

enum EntityBreakpoint { mobile, tablet, desktop, largeDesktop }

class ResponsiveRowSpan {
  const ResponsiveRowSpan({
    this.mobile = 1,
    this.tablet = 1,
    this.desktop = 1,
    this.largeDesktop = 1,
  });

  final int mobile;
  final int tablet;
  final int desktop;
  final int largeDesktop;

  int forBreakpoint(EntityBreakpoint breakpoint) {
    return switch (breakpoint) {
      EntityBreakpoint.mobile => mobile,
      EntityBreakpoint.tablet => tablet,
      EntityBreakpoint.desktop => desktop,
      EntityBreakpoint.largeDesktop => largeDesktop,
    };
  }

  factory ResponsiveRowSpan.fromJson(dynamic json) {
    if (json is num) {
      final value = json.toInt().clamp(1, 100);
      return ResponsiveRowSpan(
        mobile: 1,
        tablet: value,
        desktop: value,
        largeDesktop: value,
      );
    }

    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      final desktop = _parseSpan(map['desktop'], 1);

      return ResponsiveRowSpan(
        mobile: _parseSpan(map['mobile'], 1),
        tablet: _parseSpan(map['tablet'], 1),
        desktop: desktop,
        largeDesktop: _parseSpan(map['largeDesktop'], desktop),
      );
    }

    return const ResponsiveRowSpan();
  }

  static int _parseSpan(dynamic value, int fallback) {
    return value is num ? value.toInt().clamp(1, 100) : fallback;
  }
}

/// Responsive column span in a 12-column grid.
class ResponsiveColSpan {
  const ResponsiveColSpan({
    this.mobile = 12,
    this.tablet = 6,
    this.desktop = 4,
    this.largeDesktop = 3,
  });

  final int mobile;
  final int tablet;
  final int desktop;
  final int largeDesktop;

  int forBreakpoint(EntityBreakpoint breakpoint) {
    return switch (breakpoint) {
      EntityBreakpoint.mobile => mobile,
      EntityBreakpoint.tablet => tablet,
      EntityBreakpoint.desktop => desktop,
      EntityBreakpoint.largeDesktop => largeDesktop,
    };
  }

  factory ResponsiveColSpan.fromJson(dynamic json) {
    if (json is num) {
      final value = _span(json, 6);

      return ResponsiveColSpan(
        mobile: 12,
        tablet: value,
        desktop: value,
        largeDesktop: value,
      );
    }

    if (json is Map) {
      final map = Map<String, dynamic>.from(json);

      final desktop = _span(map['desktop'], 4);

      return ResponsiveColSpan(
        mobile: _span(map['mobile'], 12),
        tablet: _span(map['tablet'], 6),
        desktop: desktop,
        largeDesktop: _span(map['largeDesktop'], desktop),
      );
    }

    return const ResponsiveColSpan();
  }

  Map<String, dynamic> toJson() => {
    'mobile': mobile,
    'tablet': tablet,
    'desktop': desktop,
    'largeDesktop': largeDesktop,
  };

  static int _span(dynamic value, int fallback) {
    if (value is num) {
      return value.toInt().clamp(1, 12);
    }
    return fallback;
  }
}

/// Select option with separate display label and API value.
class FieldOption<T> {
  const FieldOption({
    required this.label,
    required this.value,
    this.disabled = false,
    this.metadata = const {},
  });

  final String label;
  final T value;
  final bool disabled;
  final Map<String, dynamic> metadata;

  factory FieldOption.fromJson(dynamic json) {
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);

      return FieldOption<T>(
        label: map['label']?.toString() ?? map['value']?.toString() ?? '',
        value: map['value'] as T,
        disabled: map['disabled'] == true,
        metadata: map['metadata'] is Map
            ? Map<String, dynamic>.from(map['metadata'])
            : const {},
      );
    }

    return FieldOption<T>(label: json.toString(), value: json as T);
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'value': value,
    'disabled': disabled,
    if (metadata.isNotEmpty) 'metadata': metadata,
  };
}

/// Simple condition for visibility or enabled state.
///
/// Supported:
/// {"field":"type","equals":"physical"}
/// {"field":"type","notEquals":"service"}
/// {"field":"notes","isEmpty":true}
class FieldCondition {
  const FieldCondition({
    required this.field,
    this.equals,
    this.notEquals,
    this.isEmpty,
    this.isNotEmpty,
  });

  final String field;
  final dynamic equals;
  final dynamic notEquals;
  final bool? isEmpty;
  final bool? isNotEmpty;

  factory FieldCondition.fromJson(Map<String, dynamic> json) {
    return FieldCondition(
      field: json['field'] as String,
      equals: json['equals'],
      notEquals: json['notEquals'],
      isEmpty: json['isEmpty'] as bool?,
      isNotEmpty: json['isNotEmpty'] as bool?,
    );
  }

  bool evaluate(FormGroup form) {
    if (!form.controls.containsKey(field)) {
      return false;
    }

    final value = form.control(field).value;

    if (equals != null && value != equals) return false;
    if (notEquals != null && value == notEquals) return false;

    if (isEmpty == true && !_isEmpty(value)) return false;
    if (isNotEmpty == true && _isEmpty(value)) return false;

    return true;
  }

  static bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }
}

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
        if (value == true) {
          validators.add(Validators.number(allowNull: true));
        }
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
      case 'contains':
        if (value != null) validators.add(Validators.contains(value));
        break;
      case 'oneOf':
        if (value is Iterable) {
          validators.add(Validators.oneOf(value.toList()));
        }
        break;
      case 'mustMatch':
        if (value is Map) {
          final map = Map<String, dynamic>.from(value);
          final first = map['control']?.toString();
          final second = map['matchingControl']?.toString();

          if (first != null && second != null) {
            validators.add(Validators.mustMatch(first, second));
          }
        }
        break;
    }
  });

  return validators;
}

class FieldMeta<T> {
  const FieldMeta({
    required this.name,
    required this.label,
    required this.type,
    this.editable = true,
    this.initialValue,
    this.placeholder,
    this.helpText,
    this.maxLength,
    this.options = const [],
    this.validationRules = const {},
    this.colSpan = const ResponsiveColSpan(),
    this.rowSpan = const ResponsiveRowSpan(),
    this.features = const {},
    this.visibleWhen,
    this.enabledWhen,
  });

  final String name;
  final String label;
  final EntityFieldType type;
  final bool editable;
  final T? initialValue;

  final String? placeholder;
  final String? helpText;
  final int? maxLength;

  final List<FieldOption<dynamic>> options;
  final Map<String, dynamic> validationRules;
  final ResponsiveColSpan colSpan;

  /// Number of grid rows occupied.
  final ResponsiveRowSpan rowSpan;

  final Map<String, dynamic> features;

  final FieldCondition? visibleWhen;
  final FieldCondition? enabledWhen;

  bool get isRequired => validationRules['required'] == true;

  bool isVisible(FormGroup form) => visibleWhen?.evaluate(form) ?? true;

  bool isEnabled(FormGroup form) => enabledWhen?.evaluate(form) ?? true;

  FormControl<T> toFormControl() {
    return FormControl<T>(
      value: initialValue,
      validators: buildValidators(validationRules),
    );
  }
}

class EntityMeta {
  const EntityMeta({required this.entityName, required this.fields});

  final String entityName;
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
  // FormGroup toFormGroup({
  //   EntityMode mode = EntityMode.create,
  //   Map<String, dynamic>? initialData,
  // }) {
  //   final controls = <String, AbstractControl<dynamic>>{};

  //   for (final field in fields) {
  //     final dynamic value =
  //         initialData != null && initialData.containsKey(field.name)
  //         ? initialData[field.name]
  //         : field.initialValue;

  //     controls[field.name] = FormControl<dynamic>(
  //       value: _normalizeFieldValue(field: field, value: value),
  //       validators: buildValidators(field.validationRules),
  //     );
  //   }

  //   final form = FormGroup(controls);

  //   /// Disable controls for view mode or non-editable fields.
  //   for (final field in fields) {
  //     final control = form.control(field.name);

  //     if (mode == EntityMode.view || !field.editable) {
  //       control.markAsDisabled();
  //     }
  //   }

  //   return form;
  // }

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

EntityMeta entityMetaFromJson(Map<String, dynamic> json) {
  final fieldsJson = json['fields'] as List<dynamic>? ?? [];

  final fields = fieldsJson.map((item) {
    if (item is! Map) {
      throw FormatException('Invalid field definition: $item');
    }

    return _fieldMetaFromJson(Map<String, dynamic>.from(item));
  }).toList();

  return EntityMeta(
    entityName: json['entityName']?.toString() ?? 'Entity',
    fields: fields,
  );
}

FieldMeta<dynamic> _fieldMetaFromJson(Map<String, dynamic> json) {
  final type = EntityFieldType.values.firstWhere(
    (item) => item.name == json['type'],
    orElse: () => EntityFieldType.text,
  );

  final optionsJson = json['options'] as List<dynamic>? ?? [];

  final options = optionsJson
      .map((item) => FieldOption<dynamic>.fromJson(item))
      .toList();

  final rules = json['validationRules'] is Map
      ? Map<String, dynamic>.from(json['validationRules'])
      : <String, dynamic>{};

  final features = json['features'] is Map
      ? Map<String, dynamic>.from(json['features'])
      : <String, dynamic>{};

  FieldCondition? condition(String key) {
    final value = json[key];
    if (value is Map) {
      return FieldCondition.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
  }

  return FieldMeta<dynamic>(
    name: json['name'] as String,
    label: json['label']?.toString() ?? json['name'] as String,
    type: type,
    editable: json['editable'] as bool? ?? true,
    initialValue: _parseInitialValue(json['initialValue'], type),
    placeholder: json['placeholder']?.toString(),
    helpText: json['helpText']?.toString(),
    maxLength: (json['maxLength'] as num?)?.toInt(),
    options: options,
    validationRules: rules,
    features: features,
    colSpan: ResponsiveColSpan.fromJson(json['colSpan']),
    rowSpan: ResponsiveRowSpan.fromJson(json['rowSpan']),
    visibleWhen: condition('visibleWhen'),
    enabledWhen: condition('enabledWhen'),
  );
}

dynamic _parseInitialValue(dynamic value, EntityFieldType type) {
  if (value == null) return null;

  switch (type) {
    case EntityFieldType.boolean:
      return value == true || value.toString() == 'true';

    case EntityFieldType.slider:
      return value is num
          ? value.toDouble()
          : double.tryParse(value.toString());

    case EntityFieldType.multiselect:
      return value is List ? value.toList() : <dynamic>[];

    case EntityFieldType.dateRange:
      return value is Map ? Map<String, dynamic>.from(value) : null;

    case EntityFieldType.number:
    case EntityFieldType.currency:
    case EntityFieldType.time:
    case EntityFieldType.date:
    case EntityFieldType.text:
    case EntityFieldType.email:
    case EntityFieldType.password:
    case EntityFieldType.phone:
    case EntityFieldType.select:
    case EntityFieldType.textarea:
      return value.toString();
  }
}
