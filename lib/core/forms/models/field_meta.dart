import 'package:reactive_forms/reactive_forms.dart';

import '../helper/build_validators.dart';

import 'entity_grid_layout.dart';

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
    this.features = const {},
    this.layout = const FieldLayoutMeta(),
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

  final FieldLayoutMeta layout;

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
