import 'metadata_reference.dart';

class MetadataField {
  final String name;
  final String label;
  final String type;
  final String? widget;
  final String? format;
  final String? title;
  final String? description;
  final String? group;

  final Map<String, dynamic> ui;

  /// Field-level mode configuration in the current metadata contract.
  final Map<String, dynamic> visibility;
  final Map<String, dynamic> security;
  final List<dynamic> validation;
  final List<Map<String, dynamic>> rules;

  final bool showInTable;
  final bool showInDetail;
  final bool showInCreate;
  final bool showInUpdate;

  final bool requiredOnCreate;
  final bool requiredOnUpdate;
  final bool nullable;
  final bool readOnly;
  final bool writeOnly;
  final bool deprecated;

  final Map<String, dynamic> permissions;
  final Map<String, dynamic> validations;
  final dynamic defaultValue;
  final MetadataReference? reference;
  final Map<String, dynamic> extra;

  const MetadataField({
    required this.name,
    required this.label,
    this.type = 'string',
    this.widget,
    this.format,
    this.title,
    this.description,
    this.group,
    this.ui = const {},
    this.visibility = const {},
    this.security = const {},
    this.validation = const [],
    this.rules = const [],
    this.showInTable = false,
    this.showInDetail = true,
    this.showInCreate = true,
    this.showInUpdate = true,
    this.requiredOnCreate = false,
    this.requiredOnUpdate = false,
    this.nullable = false,
    this.readOnly = false,
    this.writeOnly = false,
    this.deprecated = false,
    this.permissions = const {},
    this.validations = const {},
    this.defaultValue,
    this.reference,
    this.extra = const {},
  });

  factory MetadataField.fromJson(Map<String, dynamic> json) {
    const known = {
      'name',
      'label',
      'type',
      'widget',
      'format',
      'title',
      'description',
      'group',
      'ui',
      'visibility',
      'security',
      'validation',
      'rules',
      'showInTable',
      'showInDetail',
      'showInCreate',
      'showInUpdate',
      'requiredOnCreate',
      'requiredOnUpdate',
      'nullable',
      'readOnly',
      'writeOnly',
      'deprecated',
      'permissions',
      'validations',
      'default',
      'reference',
    };

    final reference = json['reference'];

    return MetadataField(
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString() ?? 'string',
      widget: json['widget']?.toString(),
      format: json['format']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      ui: _map(json['ui']),
      showInTable: _visibilityFlag(
        json['visibility'],
        'table',
        json['showInTable'] == true,
      ),
      showInDetail: _visibilityFlag(
        json['visibility'],
        'detail',
        json['showInDetail'] != false,
      ),
      showInCreate: _visibilityFlag(
        json['visibility'],
        'create',
        json['showInCreate'] != false,
      ),
      showInUpdate: _visibilityFlag(
        json['visibility'],
        'edit',
        json['showInUpdate'] != false,
      ),
      requiredOnCreate: _visibilityFlag(
        json['visibility'],
        'create',
        json['requiredOnCreate'] == true,
        key: 'required',
      ),
      requiredOnUpdate: _visibilityFlag(
        json['visibility'],
        'edit',
        json['requiredOnUpdate'] == true,
        key: 'required',
      ),
      nullable: json['nullable'] == true,
      readOnly: json['readOnly'] == true,
      writeOnly: json['writeOnly'] == true,
      deprecated: json['deprecated'] == true,
      permissions: _map(json['permissions']),
      validations: _map(json['validations']),
      group: json['group']?.toString(),
      visibility: _map(json['visibility']),
      security: _map(json['security']),
      validation: json['validation'] is List
          ? List<dynamic>.from(json['validation'] as List)
          : const [],
      rules: json['rules'] is List
          ? (json['rules'] as List)
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : const [],
      defaultValue: json['default'],
      reference: reference is Map
          ? MetadataReference.fromJson(Map<String, dynamic>.from(reference))
          : null,
      extra: Map.fromEntries(
        json.entries.where((entry) => !known.contains(entry.key)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    ...extra,
    'name': name,
    'label': label,
    'type': type,
    if (widget != null) 'widget': widget,
    if (format != null) 'format': format,
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (ui.isNotEmpty) 'ui': ui,
    if (group != null) 'group': group,
    if (security.isNotEmpty) 'security': security,
    'validation': validation,
    'rules': rules,
    if (visibility.isNotEmpty ||
        showInTable ||
        showInDetail ||
        showInCreate ||
        showInUpdate ||
        requiredOnCreate ||
        requiredOnUpdate)
      'visibility': {
        ...visibility,
        'show': [
          if (showInTable) 'table',
          if (showInDetail) 'detail',
          if (showInCreate) 'create',
          if (showInUpdate) 'edit',
        ],
        'required': [
          if (requiredOnCreate) 'create',
          if (requiredOnUpdate) 'edit',
        ],
        'readOnly': visibility['readOnly'] is List
            ? List<dynamic>.from(visibility['readOnly'] as List)
            : const [],
      },
    if (nullable) 'nullable': true,
    if (readOnly) 'readOnly': true,
    if (writeOnly) 'writeOnly': true,
    if (deprecated) 'deprecated': true,
    'permissions': permissions,
    if (defaultValue != null) 'default': defaultValue,
    if (reference != null) 'reference': reference!.toJson(),
  };

  // final updatedField = field.copyWith(
  //     reference: field.reference?.copyWith(entity: 'crm_contact'),
  //   );
  MetadataField copyWith({
    String? name,
    String? label,
    String? type,
    String? widget,
    String? format,
    String? title,
    String? description,
    Map<String, dynamic>? ui,
    bool? visible,
    bool? required,
    bool? nullable,
    bool? readOnly,
    bool? writeOnly,
    bool? deprecated,
    Map<String, dynamic>? permissions,
    Map<String, dynamic>? validations,
    dynamic defaultValue,
    MetadataReference? reference,
    String? group,
    Map<String, dynamic>? visibility,
    Map<String, dynamic>? security,
    List<dynamic>? validation,
    List<Map<String, dynamic>>? rules,
    Map<String, dynamic>? extra,
  }) {
    return MetadataField(
      name: name ?? this.name,
      label: label ?? this.label,
      type: type ?? this.type,
      widget: widget ?? this.widget,
      format: format ?? this.format,
      title: title ?? this.title,
      description: description ?? this.description,
      group: group ?? this.group,
      ui: ui ?? this.ui,
      visibility: visibility ?? this.visibility,
      security: security ?? this.security,
      validation: validation ?? this.validation,
      rules: rules ?? this.rules,
      nullable: nullable ?? this.nullable,
      readOnly: readOnly ?? this.readOnly,
      writeOnly: writeOnly ?? this.writeOnly,
      deprecated: deprecated ?? this.deprecated,
      permissions: permissions ?? this.permissions,
      validations: validations ?? this.validations,
      defaultValue: defaultValue ?? this.defaultValue,
      reference: reference ?? this.reference,
      extra: extra ?? this.extra,
    );
  }

  static Map<String, dynamic> _map(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  static bool _visibilityFlag(
    dynamic raw,
    String value,
    bool fallback, {
    String key = 'show',
  }) {
    if (raw is! Map || raw[key] is! List) return fallback;
    return (raw[key] as List).map((item) => item.toString()).contains(value);
  }
}
