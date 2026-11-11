import '../models/field_meta.dart';

FieldMeta<dynamic> fieldMetaFromJson(Map<String, dynamic> json) {
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
