import 'package:reactive_forms/reactive_forms.dart';
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
  group,
  array,
  custom,
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
    final value = _resolvePath(form, field);

    if (value == _notFound) return false;

    if (equals != null && value != equals) return false;
    if (notEquals != null && value == notEquals) return false;

    if (isEmpty == true && !_isEmpty(value)) return false;
    if (isNotEmpty == true && _isEmpty(value)) return false;

    return true;
  }

  static const Object _notFound = Object();

  static dynamic _resolvePath(AbstractControl<dynamic> root, String path) {
    dynamic current = root;

    for (final segment in path.split('.')) {
      if (current is FormGroup) {
        if (!current.controls.containsKey(segment)) {
          return _notFound;
        }
        current = current.control(segment);
      } else if (current is FormArray) {
        final index = int.tryParse(segment);
        if (index == null || index < 0 || index >= current.controls.length) {
          return _notFound;
        }
        current = current.controls[index];
      } else {
        return _notFound;
      }
    }

    return current is AbstractControl ? current.value : current;
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
    this.widget,
    this.editable = true,
    this.initialValue,
    this.placeholder,
    this.helpText,
    this.maxLength,
    this.options = const [],
    this.validationRules = const {},
    this.features = const {},
    this.layout = const FieldLayoutMeta(),
    this.fields = const [],
    this.visibleWhen,
    this.enabledWhen,
    this.itemMeta,
  });

  final String name;
  final String label;
  final EntityFieldType type;
  final String? widget;
  final bool editable;
  final T? initialValue;

  final String? placeholder;
  final String? helpText;
  final int? maxLength;

  final List<FieldOption<dynamic>> options;
  final Map<String, dynamic> validationRules;

  final FieldLayoutMeta layout;

  /// Child fields for nested FormGroup.
  final List<FieldMeta<dynamic>> fields;
  final FieldMeta<dynamic>? itemMeta;
  final Map<String, dynamic> features;

  final FieldCondition? visibleWhen;
  final FieldCondition? enabledWhen;

  bool get isRequired => validationRules['required'] == true;

  bool get isGroup => type == EntityFieldType.group;

  bool get isArray => type == EntityFieldType.array;

  bool get isBoolean => type == EntityFieldType.boolean;

  bool get isContainer => isGroup || isArray;

  bool get hasItemMeta => itemMeta != null;

  bool isVisible(FormGroup form) => visibleWhen?.evaluate(form) ?? true;

  bool isEnabled(FormGroup form) => enabledWhen?.evaluate(form) ?? true;
}
