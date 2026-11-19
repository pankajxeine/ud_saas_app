import 'metadata_api.dart';
import 'metadata_field.dart';
import 'metadata_grid.dart';

class MetadataSchema {
  final String? entity;
  final String? title;
  final String? table;
  final String? primaryKey;

  /// API operations stored as an array.
  ///
  /// Example:
  /// "api": [
  ///   {
  ///     "operation": "list",
  ///     "path": "/contact",
  ///     "enabled": true,
  ///     "permission": "crm_contact.operation.list"
  ///   }
  /// ]
  final MetadataApi? api;

  final MetadataGrid? grid;

  // Flexible metadata sections.
  final Map<String, dynamic> search;
  final Map<String, dynamic> datatable;
  final Map<String, dynamic> detail;

  final List<MetadataField> fields;

  // Properties not explicitly modeled above.
  final Map<String, dynamic> extra;

  const MetadataSchema({
    this.entity,
    this.title,
    this.table,
    this.primaryKey,
    this.api,
    this.grid,
    this.search = const {},
    this.datatable = const {},
    this.detail = const {},
    this.fields = const [],
    this.extra = const {},
  });

  factory MetadataSchema.fromJson(Map<String, dynamic> json) {
    const known = {
      'entity',
      'title',
      'table',
      'primaryKey',
      'api',
      'grid',
      'search',
      'datatable',
      'detail',
      'fields',
      'meta_module',
    };

    return MetadataSchema(
      entity: json['entity']?.toString(),
      title: json['title']?.toString(),
      table: json['table']?.toString(),
      primaryKey: json['primaryKey']?.toString(),

      // API is now an array of operations.
      api: _parseApi(json['api']),

      // Grid remains an object.
      grid: _parseObject(json['grid'], MetadataGrid.fromJson),

      search: _map(json['search']),
      datatable: _map(json['datatable']),
      detail: _map(json['detail']),

      fields: _parseFields(json['fields']),

      extra: Map<String, dynamic>.fromEntries(
        json.entries.where((entry) => !known.contains(entry.key)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...extra,

      if (entity != null) 'entity': entity,
      if (title != null) 'title': title,
      if (table != null) 'table': table,
      if (primaryKey != null) 'primaryKey': primaryKey,

      // Serializes API as an array.
      if (api != null) 'api': api!.toJson(),

      if (grid != null) 'grid': grid!.toJson(),

      'search': search,
      'datatable': datatable,
      'fields': fields.map((field) => field.toJson()).toList(),
    };
  }

  MetadataSchema copyWith({
    String? entity,
    String? title,
    String? table,
    String? primaryKey,
    MetadataApi? api,
    MetadataGrid? grid,
    Map<String, dynamic>? search,
    Map<String, dynamic>? datatable,
    Map<String, dynamic>? detail,
    List<MetadataField>? fields,
    Map<String, dynamic>? extra,
  }) {
    return MetadataSchema(
      entity: entity ?? this.entity,
      title: title ?? this.title,
      table: table ?? this.table,
      primaryKey: primaryKey ?? this.primaryKey,
      api: api ?? this.api,
      grid: grid ?? this.grid,
      search: search ?? this.search,
      datatable: datatable ?? this.datatable,
      detail: detail ?? this.detail,
      fields: fields ?? this.fields,
      extra: extra ?? this.extra,
    );
  }

  // ------------------------------------------------------------
  // JSON parsing helpers
  // ------------------------------------------------------------

  /// Parses API operations from a JSON array.
  static MetadataApi? _parseApi(dynamic value) {
    if (value == null) return null;

    if (value is List) {
      return MetadataApi.fromJson(value);
    }

    // Also supports the wrapper format:
    // { "api": [...] }
    if (value is Map && value['api'] is List) {
      return MetadataApi.fromJson(value['api']);
    }

    if (value is Map) {
      final operations = <Map<String, dynamic>>[];
      for (final entry in value.entries) {
        if (entry.value is Map) {
          operations.add({
            ...Map<String, dynamic>.from(entry.value as Map),
            'operation': entry.key.toString(),
          });
        }
      }
      return MetadataApi.fromJson(operations);
    }

    return null;
  }

  /// Parses an object-based metadata section.
  static T? _parseObject<T>(
    dynamic value,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (value is! Map) return null;

    return parser(Map<String, dynamic>.from(value));
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is! Map) return {};

    return Map<String, dynamic>.from(value);
  }

  static List<MetadataField> _parseFields(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map(
          (field) => MetadataField.fromJson(Map<String, dynamic>.from(field)),
        )
        .toList();
  }

  // ------------------------------------------------------------
  // Default schema
  // ------------------------------------------------------------

  factory MetadataSchema.empty({
    required String entity,
    String? title,
    String? table,
  }) {
    final normalizedEntity = entity.trim().toLowerCase();

    return MetadataSchema(
      entity: normalizedEntity,
      title: title ?? _toTitleCase(normalizedEntity),
      table: table ?? normalizedEntity,
      primaryKey: 'id',

      // Creates default API operation array.
      api: MetadataApi.empty(entity: normalizedEntity),

      grid: MetadataGrid.empty(),

      search: {'quickSearch': <String>[], 'filters': <Map<String, dynamic>>[]},

      datatable: {'columns': <Map<String, dynamic>>[]},

      fields: const [],

      extra: const {},
    );
  }

  static String _toTitleCase(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
