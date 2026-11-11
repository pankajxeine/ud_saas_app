import 'metadata_reference.dart';

class MetadataField {
  final String name;
  final String label;
  final String type;
  final String? widget;
  final String? format;
  final String? title;
  final String? description;

  final Map<String, dynamic> ui;

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
    this.ui = const {},
    this.showInTable = false,
    this.showInDetail = true,
    this.showInCreate = true,
    this.showInUpdate = true,
    this.requiredOnCreate = false,
    this.requiredOnUpdate = false,
    this.nullable = true,
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
      'ui',
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
      showInTable: json['showInTable'] == true,
      showInDetail: json['showInDetail'] != false,
      showInCreate: json['showInCreate'] != false,
      showInUpdate: json['showInUpdate'] != false,
      requiredOnCreate: json['requiredOnCreate'] == true,
      requiredOnUpdate: json['requiredOnUpdate'] == true,
      nullable: json['nullable'] != false,
      readOnly: json['readOnly'] == true,
      writeOnly: json['writeOnly'] == true,
      deprecated: json['deprecated'] == true,
      permissions: _map(json['permissions']),
      validations: _map(json['validations']),
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
    'showInTable': showInTable,
    'showInDetail': showInDetail,
    'showInCreate': showInCreate,
    'showInUpdate': showInUpdate,
    'requiredOnCreate': requiredOnCreate,
    'requiredOnUpdate': requiredOnUpdate,
    'nullable': nullable,
    'readOnly': readOnly,
    'writeOnly': writeOnly,
    'deprecated': deprecated,
    'permissions': permissions,
    'validations': validations,
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
      ui: ui ?? this.ui,
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
}
