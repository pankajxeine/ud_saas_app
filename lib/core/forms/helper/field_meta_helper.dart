import '../models/field_meta.dart';
import '../models/entity_grid_layout.dart';

FieldMeta<dynamic> fieldMetaFromJson(Map<String, dynamic> json) {
  final name = json['name']?.toString();

  if (name == null || name.trim().isEmpty) {
    throw const FormatException('Field schema requires a non-empty "name".');
  }

  // Resolve the data type independently from the widget.
  final type = _parseFieldType(json['type']);

  // UI configuration can be supplied inside "ui" or at the root
  // for backward compatibility with older metadata.
  final ui = _asMap(json['ui']);

  // Parse nested field definitions recursively.
  final childrenJson = json['fields'];
  final children = childrenJson is List
      ? childrenJson
            .whereType<Map>()
            .map((item) => fieldMetaFromJson(Map<String, dynamic>.from(item)))
            .toList()
      : <FieldMeta<dynamic>>[];

  // Array items use the same metadata shape as any other field. Keeping the
  // item definition on `itemMeta` lets the form factory create a FormGroup for
  // every object in the array instead of treating the item as an untyped value.
  final itemMetaJson = json['itemMeta'] ?? json['items'];
  final itemMeta = itemMetaJson is Map
      ? fieldMetaFromJson(Map<String, dynamic>.from(itemMetaJson))
      : null;

  // Options can be omitted.
  final optionsJson = json['options'];
  final options = optionsJson is List
      ? optionsJson
            .whereType<Map>()
            .map(
              (item) => FieldOption<dynamic>.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
      : <FieldOption<dynamic>>[];

  // Support both old and new validation property names.
  final validationJson = json['validations'] ?? json['validationRules'];

  final validationRules = _asMap(validationJson);

  final features = _asMap(json['features']);

  FieldCondition? parseCondition(String key) {
    final value = json[key];

    if (value is Map) {
      return FieldCondition.fromJson(Map<String, dynamic>.from(value));
    }

    return null;
  }

  // Explicit initialValue takes precedence over default.
  // containsKey preserves an intentionally supplied null.
  final dynamic initialValue = json.containsKey('initialValue')
      ? json['initialValue']
      : json['default'];

  final layoutJson = json['layout'];

  return FieldMeta<dynamic>(
    name: name,

    label:
        _firstNonNull([
          ui['label'],
          json['label'],
          json['title'],
        ])?.toString() ??
        name,

    widget: _firstNonNull([
      json['widget'],
      _defaultWidgetForType(type),
    ])!.toString(),

    type: type,

    editable: _parseEditable(json),

    initialValue: _parseInitialValue(initialValue, type),

    placeholder: _firstNonNull([
      ui['placeholder'],
      json['placeholder'],
    ])?.toString(),

    helpText: _firstNonNull([
      ui['helperText'],
      ui['hint'],
      json['helpText'],
    ])?.toString(),

    maxLength: _parseInt(json['maxLength'] ?? validationRules['maxLength']),

    options: options,
    validationRules: validationRules,
    features: features,

    visibleWhen: parseCondition('visibleWhen'),
    enabledWhen: parseCondition('enabledWhen'),

    fields: children,

    itemMeta: itemMeta,

    layout: layoutJson is Map
        ? FieldLayoutMeta.fromJson(Map<String, dynamic>.from(layoutJson))
        : const FieldLayoutMeta(),
  );
}

/// Resolves schema type names to the application's existing enum.
///
/// Supports application-specific names and common JSON Schema aliases.
EntityFieldType _parseFieldType(dynamic value) {
  final typeName = value?.toString().trim().toLowerCase();

  switch (typeName) {
    // Text/string types.
    case 'string':
    case 'text':
      return EntityFieldType.text;

    case 'email':
      return EntityFieldType.email;

    case 'password':
      return EntityFieldType.password;

    case 'phone':
      return EntityFieldType.phone;

    case 'textarea':
      return EntityFieldType.textarea;

    // Numeric types.
    case 'integer':
    case 'number':
      return EntityFieldType.number;

    case 'currency':
      return EntityFieldType.currency;

    // Other primitive types.
    case 'boolean':
    case 'bool':
      return EntityFieldType.boolean;

    case 'select':
      return EntityFieldType.select;

    case 'multiselect':
      return EntityFieldType.multiselect;

    case 'date':
      return EntityFieldType.date;

    case 'time':
      return EntityFieldType.time;

    case 'daterange':
    case 'date_range':
      return EntityFieldType.dateRange;

    case 'slider':
      return EntityFieldType.slider;

    // Composite types.
    case 'object':
    case 'group':
      return EntityFieldType.group;

    case 'array':
      return EntityFieldType.array;

    case 'custom':
      return EntityFieldType.custom;
  }

  // Also accept any additional exact enum names defined by the app.
  for (final item in EntityFieldType.values) {
    if (item.name.toLowerCase() == typeName) {
      return item;
    }
  }

  throw FormatException(
    'Unsupported field type "$value". '
    'Add a mapping in _parseFieldType().',
  );
}

/// Defaults the widget independently of the field data type.
String _defaultWidgetForType(EntityFieldType type) {
  switch (type) {
    case EntityFieldType.text:
    case EntityFieldType.email:
    case EntityFieldType.password:
    case EntityFieldType.phone:
    case EntityFieldType.number:
    case EntityFieldType.currency:
    case EntityFieldType.textarea:
      return 'text';

    case EntityFieldType.boolean:
      return 'switch';

    case EntityFieldType.select:
      return 'select';

    case EntityFieldType.multiselect:
      return 'multiselect';

    case EntityFieldType.date:
      return 'datePicker';

    case EntityFieldType.time:
      return 'timePicker';

    case EntityFieldType.dateRange:
      return 'dateRange';

    case EntityFieldType.slider:
      return 'slider';

    case EntityFieldType.group:
      return 'group';

    case EntityFieldType.array:
      return 'array';

    case EntityFieldType.custom:
      return 'custom';
  }
}

/// Maps the existing editable property from readOnly metadata.
///
/// Do not combine create/update permissions here: those are mode-specific.
bool _parseEditable(Map<String, dynamic> json) {
  if (json['editable'] is bool) {
    return json['editable'] as bool;
  }

  return json['readOnly'] != true;
}

/// Parses the initial/default value without converting every value to String.
dynamic _parseInitialValue(dynamic value, EntityFieldType type) {
  if (value == null) return null;

  switch (type) {
    case EntityFieldType.text:
    case EntityFieldType.email:
    case EntityFieldType.password:
    case EntityFieldType.phone:
    case EntityFieldType.textarea:
      return value.toString();

    case EntityFieldType.number:
    case EntityFieldType.currency:
      if (value is num) return value;
      return num.tryParse(value.toString());

    case EntityFieldType.boolean:
      return _parseBool(value);

    case EntityFieldType.slider:
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());

    case EntityFieldType.multiselect:
      return value is List ? List<dynamic>.from(value) : <dynamic>[];

    case EntityFieldType.date:
    case EntityFieldType.time:
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());

    case EntityFieldType.dateRange:
      return value is Map ? Map<String, dynamic>.from(value) : null;

    case EntityFieldType.select:
      // Preserve the option's original value type (String, int, etc.).
      return value;

    case EntityFieldType.group:
      return value is Map ? Map<String, dynamic>.from(value) : null;

    case EntityFieldType.array:
      return value is List ? List<dynamic>.from(value) : <dynamic>[];

    case EntityFieldType.custom:
      return value;
  }
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;

  switch (value.toString().toLowerCase().trim()) {
    case 'true':
    case '1':
    case 'yes':
    case 'on':
      return true;

    case 'false':
    case '0':
    case 'no':
    case 'off':
      return false;

    default:
      return false;
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return <String, dynamic>{};
}

dynamic _firstNonNull(List<dynamic> values) {
  for (final value in values) {
    if (value != null) return value;
  }

  return null;
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value == null) return null;

  return int.tryParse(value.toString());
}
