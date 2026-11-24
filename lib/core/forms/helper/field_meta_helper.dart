import '../models/field_meta.dart';
import '../models/entity_grid_layout.dart';
import '../models/entity_meta.dart';

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
    asyncValidationRules: json['asyncValidationRules'] is List
        ? (json['asyncValidationRules'] as List)
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : const [],
    groupValidationRules: _asMap(json['groupValidationRules']),
    arrayValidationRules: _asMap(json['arrayValidationRules']),
    features: features,

    visibleWhen: parseCondition('visibleWhen'),
    enabledWhen: parseCondition('enabledWhen'),

    fields: children,

    itemMeta: itemMeta,

    section: json['section']?.toString(),

    layout: layoutJson is Map
        ? FieldLayoutMeta.fromJson(Map<String, dynamic>.from(layoutJson))
        : const FieldLayoutMeta(),
  );
}

/// Converts a JSON Schema object into the metadata consumed by [AppReactiveForm].
EntityMeta entityMetaFromJsonSchema(Map<String, dynamic> schema) {
  final properties = schema['properties'];
  final required = (schema['required'] as List? ?? const [])
      .map((item) => item.toString())
      .toSet();
  final fields = <FieldMeta<dynamic>>[];

  if (properties is Map) {
    for (final entry in properties.entries) {
      if (entry.value is Map) {
        fields.add(
          _fieldMetaFromJsonSchema(
            entry.key.toString(),
            Map<String, dynamic>.from(entry.value as Map),
            required: required.contains(entry.key.toString()),
          ),
        );
      }
    }
  }

  return EntityMeta(
    entityName: schema['title']?.toString() ?? 'Entity',
    fields: fields,
    formLayout: _schemaLayoutMode(schema),
    sections: _schemaSections(schema),
  );
}

EntityFormLayoutMode _schemaLayoutMode(Map<String, dynamic> schema) {
  final layout = schema['layout'];
  final mode = layout is Map ? layout['mode']?.toString().toLowerCase() : null;
  return switch (mode) {
    'tabs' => EntityFormLayoutMode.tabs,
    'stepper' => EntityFormLayoutMode.stepper,
    _ => EntityFormLayoutMode.basic,
  };
}

List<EntityFormSection> _schemaSections(Map<String, dynamic> schema) {
  final layout = schema['layout'];
  if (layout is! Map || layout['sections'] is! List) return const [];
  return (layout['sections'] as List)
      .whereType<Map>()
      .map((item) => EntityFormSection.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

FieldMeta<dynamic> _fieldMetaFromJsonSchema(
  String name,
  Map<String, dynamic> schema, {
  bool required = false,
}) {
  final itemSchema = schema['items'];
  final isMultiSelect =
      schema['widget']?.toString() == 'multiselect' ||
      (itemSchema is Map && itemSchema['enum'] is List);
  final type = isMultiSelect
      ? EntityFieldType.multiselect
      : _schemaType(schema['type']?.toString(), schema['format']?.toString());
  final json = <String, dynamic>{
    'name': name,
    'label':
        schema['label']?.toString() ??
        schema['title']?.toString() ??
        _humanizeSchemaName(name),
    'type': type.name,
    'widget': schema['widget']?.toString() ?? _schemaWidget(type),
    if (schema['section'] != null) 'section': schema['section'],
    if (schema['format'] != null) 'format': schema['format'],
    if (schema['description'] != null) 'helpText': schema['description'],
    if (schema['enum'] is List)
      'options': (schema['enum'] as List)
          .map((value) => {'label': value.toString(), 'value': value})
          .toList(),
    'validationRules': _schemaValidationRules(schema, required: required),
    if (schema['x-asyncValidators'] is List)
      'asyncValidationRules': schema['x-asyncValidators'],
  };

  if (type == EntityFieldType.multiselect &&
      itemSchema is Map &&
      itemSchema['enum'] is List) {
    json['options'] = (itemSchema['enum'] as List)
        .map((value) => {'label': value.toString(), 'value': value})
        .toList();
  }

  if (type == EntityFieldType.group) {
    final properties = schema['properties'];
    final requiredChildren = (schema['required'] as List? ?? const [])
        .map((item) => item.toString())
        .toSet();
    json['fields'] = [
      if (properties is Map)
        for (final entry in properties.entries)
          if (entry.value is Map)
            _fieldMetaFromJsonSchema(
              entry.key.toString(),
              Map<String, dynamic>.from(entry.value as Map),
              required: requiredChildren.contains(entry.key.toString()),
            ).toJson(),
    ];
    json['groupValidationRules'] = _schemaCompositeRules(
      schema['x-groupValidators'],
    );
  }

  if (type == EntityFieldType.array) {
    final items = schema['items'];
    if (items is Map) {
      json['itemMeta'] = _fieldMetaFromJsonSchema(
        '${name}Item',
        Map<String, dynamic>.from(items),
      ).toJson();
    }
    json['arrayValidationRules'] = {
      ..._schemaValidationRules(schema),
      ..._schemaCompositeRules(schema['x-arrayValidators']),
    };
  }

  return fieldMetaFromJson(json);
}

EntityFieldType _schemaType(String? type, String? format) {
  if (type == 'string' && format == 'date-time') return EntityFieldType.date;
  if (type == 'integer' || type == 'number') return EntityFieldType.number;
  if (type == 'boolean') return EntityFieldType.boolean;
  if (type == 'object') return EntityFieldType.group;
  if (type == 'array') return EntityFieldType.array;
  return EntityFieldType.text;
}

String _schemaWidget(EntityFieldType type) {
  switch (type) {
    case EntityFieldType.boolean:
      return 'switch';
    case EntityFieldType.number:
      return 'number';
    case EntityFieldType.date:
      return 'date';
    case EntityFieldType.group:
      return 'group';
    case EntityFieldType.array:
      return 'array';
    default:
      return 'text';
  }
}

Map<String, dynamic> _schemaValidationRules(
  Map<String, dynamic> schema, {
  bool required = false,
}) {
  final rules = <String, dynamic>{};
  if (required) rules['required'] = true;
  if (schema['format'] == 'email') rules['email'] = true;
  if (schema['format'] == 'credit-card') rules['creditCard'] = true;
  if (schema['type'] == 'integer' || schema['type'] == 'number') {
    rules['number'] = true;
  }

  for (final key in [
    'minLength',
    'maxLength',
    'minimum',
    'maximum',
    'pattern',
    'minItems',
    'maxItems',
  ]) {
    if (schema[key] != null) rules[_schemaValidationKey(key)] = schema[key];
  }
  if (schema['uniqueItems'] == true) rules['uniqueItems'] = true;
  final contains = schema['contains'];
  if (contains is Map && contains['const'] != null) {
    rules['contains'] = [contains['const']];
  }

  final custom = schema['x-validators'];
  if (custom is List) {
    final configured = <Map<String, dynamic>>[];
    for (final item in custom.whereType<Map>()) {
      final rule = Map<String, dynamic>.from(item);
      final key = rule['name']?.toString() ?? rule['type']?.toString();
      if (key == null) continue;
      rules[key] = rule['value'] ?? true;
      configured.add(rule);
    }
    if (configured.isNotEmpty) rules['rules'] = configured;
  }
  if (schema['const'] != null) rules['equals'] = schema['const'];
  if (schema['enum'] is List) rules['oneOf'] = schema['enum'];
  final anyOf = schema['anyOf'];
  if (anyOf is List) {
    rules['composeOR'] = anyOf
        .whereType<Map>()
        .map((item) => _schemaValidationRules(Map<String, dynamic>.from(item)))
        .toList();
  }
  return rules;
}

String _schemaValidationKey(String key) {
  switch (key) {
    case 'minimum':
      return 'min';
    case 'maximum':
      return 'max';
    case 'minItems':
      return 'minLength';
    case 'maxItems':
      return 'maxLength';
    default:
      return key;
  }
}

Map<String, dynamic> _schemaCompositeRules(dynamic value) {
  if (value is! List) return {};
  final result = <String, dynamic>{};
  final configured = <Map<String, dynamic>>[];
  for (final item in value.whereType<Map>()) {
    final rule = Map<String, dynamic>.from(item);
    final type = rule['type']?.toString() ?? rule['name']?.toString();
    if (type != null) {
      result[type] = rule;
      if (rule['name'] != null) configured.add(rule);
    }
  }
  if (configured.isNotEmpty) result['rules'] = configured;
  return result;
}

String _humanizeSchemaName(String value) => value
    .replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match[1]} ${match[2]}',
    )
    .replaceAll('_', ' ')
    .split(RegExp(r'\s+'))
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');

extension on FieldMeta<dynamic> {
  Map<String, dynamic> toJson() => {
    'name': name,
    'label': label,
    'type': type.name,
    if (widget != null) 'widget': widget,
    if (initialValue != null) 'initialValue': initialValue,
    if (placeholder != null) 'placeholder': placeholder,
    if (helpText != null) 'helpText': helpText,
    if (options.isNotEmpty)
      'options': options.map((option) => option.toJson()).toList(),
    if (validationRules.isNotEmpty) 'validationRules': validationRules,
    if (asyncValidationRules.isNotEmpty)
      'asyncValidationRules': asyncValidationRules,
    if (groupValidationRules.isNotEmpty)
      'groupValidationRules': groupValidationRules,
    if (arrayValidationRules.isNotEmpty)
      'arrayValidationRules': arrayValidationRules,
    if (fields.isNotEmpty)
      'fields': fields.map((field) => field.toJson()).toList(),
    if (itemMeta != null) 'itemMeta': itemMeta!.toJson(),
  };
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
