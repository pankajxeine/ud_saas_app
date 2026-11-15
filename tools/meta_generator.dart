import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

Future<void> main(List<String> args) async {
  final root = args.isEmpty ? '.' : args.first;

  final files = Directory(root)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.openapi.yaml'))
      .toList();

  if (files.isEmpty) {
    print('No openapi files found');
    return;
  }

  for (final file in files) {
    await generateMeta(file);
  }
}

String metaOutputPath(File file) {
  final apiDir = file.parent.path;

  final moduleDir = p.dirname(apiDir);

  final moduleName = p
      .basenameWithoutExtension(p.basenameWithoutExtension(file.path))
      .replaceAll('.openapi', '');

  return p.join(moduleDir, '${moduleName}_meta.json');
}

Future<void> generateMeta(File openApiFile) async {
  print('Processing ${openApiFile.path}');

  final yaml = loadYaml(await openApiFile.readAsString());

  final meta = MetaGenerator(yaml).generate();

  final target = File(metaOutputPath(openApiFile));

  target.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(meta));

  print('Created ${target.path}');
}

class MetaGenerator {
  final YamlMap doc;

  MetaGenerator(this.doc);

  late final YamlMap schemas =
      (doc['components']?['schemas'] as YamlMap?) ?? YamlMap();

  Map<String, dynamic> generate() {
    final entity = _detectEntity();

    final createSchema = _findSchema([
      '${entity}Request',
      '${entity}CreateRequest',
    ]);

    final updateSchema = _findSchema([
      '${entity}UpdateRequest',
      '${entity}PatchRequest',
    ]);

    final responseSchema = _findSchema(['${entity}Response', entity]);

    final references = _buildSqlReferences();

    final fields = _buildFields(
      createSchema,
      updateSchema,
      responseSchema,
      references,
    );

    return {
      'entity': entity,
      'title': _humanize(entity),

      'table': doc['x-sql-table'],

      'primaryKey': _primaryKey(fields),

      'api': _buildApi(doc['x-sql-table']),

      'grid': {
        "pageSize": 20,
        "defaultSort": {"field": "record_code", "direction": "desc"},
      },
      "search": {
        "quickSearch": ["record_code"],
        "filters": [],
      },
      'datatable': {
        'columns': fields.map((field) {
          final visibility = field['visibility'];
          final show = visibility is Map
              ? (visibility['show'] as List? ?? const [])
              : const [];

          return {
            'field': field['name'],
            'label': field['label'],
            'tableEnable': show.contains('table'),
            'viewEnable': show.contains('detail'),
          };
        }).toList(),
      },
      'fields': fields,
    };
  }

  String _detectEntity() {
    for (final schema in schemas.keys) {
      final name = schema.toString();

      if (name.endsWith('Response')) {
        return name.replaceAll('Response', '');
      }
    }

    return schemas.keys.first.toString();
  }

  YamlMap? _findSchema(List<String> candidates) {
    for (final name in candidates) {
      final schema = schemas[name];

      if (schema is YamlMap) {
        return schema;
      }
    }

    return null;
  }

  YamlMap _properties(YamlMap? schema) {
    if (schema == null) {
      return YamlMap();
    }

    final props = schema['properties'];

    if (props is YamlMap) {
      return props;
    }

    final allOf = schema['allOf'];

    if (allOf is YamlList) {
      for (final item in allOf) {
        if (item is YamlMap && item['properties'] is YamlMap) {
          return item['properties'] as YamlMap;
        }
      }
    }

    final oneOf = schema['oneOf'];

    if (oneOf is YamlList) {
      for (final item in oneOf) {
        if (item is YamlMap && item['properties'] is YamlMap) {
          return item['properties'] as YamlMap;
        }
      }
    }

    return YamlMap();
  }

  Set<String> _required(YamlMap? schema) {
    if (schema == null) {
      return {};
    }

    final required = schema['required'];

    if (required is YamlList) {
      return required.map((e) => e.toString()).toSet();
    }

    return {};
  }

  Map<String, dynamic> _buildSqlReferences() {
    final list = doc['x-sql-references'] as YamlList?;

    final result = <String, dynamic>{};

    if (list == null) {
      return result;
    }

    for (final item in list) {
      final table = item['table']?.toString();
      final column =
          item['column']?.toString() ?? item['key']?.toString() ?? '';
      if (column.isEmpty) continue;

      result[column] = {
        'table': table,
        'column': column,
        'lookup': {
          'endpoint': table == null ? null : '/$table',
          'strategy': 'remote',
          'valueField': column,
          'displayField': 'name',
        }..removeWhere((key, value) => value == null),
      };
    }

    return result;
  }

  List<Map<String, dynamic>> _buildFields(
    YamlMap? createSchema,
    YamlMap? updateSchema,
    YamlMap? responseSchema,
    Map<String, dynamic> globalRefs,
  ) {
    final responseProps = _properties(responseSchema);

    final createProps = _properties(createSchema);

    final updateProps = _properties(updateSchema);

    final createRequired = _required(createSchema);

    final updateRequired = _required(updateSchema);

    final fields = <Map<String, dynamic>>[];

    for (final entry in responseProps.entries) {
      final name = entry.key.toString();

      final property = entry.value is YamlMap
          ? entry.value as YamlMap
          : YamlMap();

      final reference = _buildReference(name, property, globalRefs);
      final type = _type(property);

      final field = <String, dynamic>{
        // Identity
        'name': name,
        'label': _uiLabel(name, property),

        // Type metadata
        'type': type,
        'format': _fieldFormat(property, type),

        // A relation is rendered as a lookup/select by default.
        'widget': reference != null ? 'reference' : _widget(property),

        if (_group(property, reference) != null)
          'group': _group(property, reference),

        if (reference != null) 'reference': reference,

        'description': property['description'],

        'title': property['title'],

        'permissions': {
          'read': true,
          'create': createProps.containsKey(name),
          'update': updateProps.containsKey(name),
        },

        'security': _buildSecurity(property, entityName: _detectEntity()),

        if (property['nullable'] == true) 'nullable': true,
        if (property['readOnly'] == true) 'readOnly': true,
        if (property['writeOnly'] == true) 'writeOnly': true,
        if (property['deprecated'] == true) 'deprecated': true,

        'ui': _buildUiMetadata(name, property, reference: reference),

        'visibility': _buildVisibility(
          name: name,
          property: property,
          createProps: createProps,
          updateProps: updateProps,
          createRequired: createRequired,
          updateRequired: updateRequired,
        ),

        'validation': _buildValidation(property),

        // Conditional field behavior is intentionally separate from static
        // validation. An absent x-rules extension produces an empty array.
        'rules': _buildRules(property),
      };

      // Default value
      if (property['default'] != null) {
        field['default'] = property['default'];
      }

      // Example
      if (property['example'] != null) {
        field['example'] = property['example'];
      }

      // Enum support
      if (property['enum'] is YamlList) {
        field['enum'] = (property['enum'] as YamlList).toList();

        field['widget'] = 'select';
      }

      // Array support
      if (property['type'] == 'array') {
        field['array'] = _resolveSchema(property);
      }

      // Object support
      if (property['type'] == 'object' || property['properties'] != null) {
        field['object'] = _resolveSchema(property);
      }

      // Association ($ref)
      if (property[r'$ref'] != null) {
        field['association'] = _resolveSchema(property);
      }

      fields.add(field);
    }

    return fields;
  }

  Map<String, dynamic>? _buildReference(
    String fieldName,
    YamlMap property,
    Map<String, dynamic> globalRefs,
  ) {
    final raw = property['x-reference'];
    final reference = raw is YamlMap
        ? Map<String, dynamic>.from(raw)
        : globalRefs[fieldName] is Map
        ? Map<String, dynamic>.from(globalRefs[fieldName] as Map)
        : null;

    if (reference == null) return null;

    final table = reference['table']?.toString();
    final column =
        reference['column']?.toString() ??
        reference['key']?.toString() ??
        fieldName;

    final rawLookup = reference['lookup'];
    final lookup = rawLookup is Map
        ? Map<String, dynamic>.from(rawLookup)
        : <String, dynamic>{};

    return {
      if (table != null) 'table': table,
      'column': column,
      'lookup': {
        'endpoint': lookup['endpoint'] ?? (table == null ? null : '/$table'),
        'strategy': lookup['strategy'] ?? 'remote',
        'valueField': lookup['valueField'] ?? column,
        'displayField': lookup['displayField'] ?? 'name',
      }..removeWhere((key, value) => value == null),
    };
  }

  String _uiLabel(String fieldName, YamlMap property) {
    final ui = property['x-ui'];
    if (ui is YamlMap && ui['label'] != null) {
      return ui['label'].toString();
    }
    return _humanize(fieldName);
  }

  String _fieldFormat(YamlMap property, String type) {
    if (type == 'uuid') return 'string';
    return property['format']?.toString() ?? property['type']?.toString() ?? 'string';
  }

  String? _group(YamlMap property, Map<String, dynamic>? reference) {
    final explicit = property['x-group'] ?? property['group'];
    if (explicit != null && explicit.toString().trim().isNotEmpty) {
      return explicit.toString();
    }
    final table = reference?['table']?.toString();
    if (table == null) return null;

    // SQL table names commonly include a schema/module prefix, for example
    // crm_account. Use the entity portion as the default UI group label.
    final parts = table.split('_');
    return _humanize(parts.length > 1 ? parts.skip(1).join('_') : table);
  }

  Map<String, dynamic> _buildSecurity(
    YamlMap property, {
    required String entityName,
  }) {
    final raw = property['x-security'];
    if (raw is YamlMap) return Map<String, dynamic>.from(raw);

    final permissions = property['x-permissions'];
    if (permissions is YamlMap) {
      return {'permissions': Map<String, dynamic>.from(permissions)};
    }

    final prefix = entityName.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match[1]}.${match[2]}',
    ).replaceAll('_', '.').toLowerCase();

    return {
      'permissions': {
        'read': '$prefix.read',
        'create': '$prefix.create',
        'update': '$prefix.update',
      },
      'masking': {
        'enabled': false,
        'strategy': 'none',
      },
    };
  }

  Map<String, dynamic> _buildVisibility({
    required String name,
    required YamlMap property,
    required YamlMap createProps,
    required YamlMap updateProps,
    required Set<String> createRequired,
    required Set<String> updateRequired,
  }) {
    final show = <String>[];
    if (createProps.containsKey(name)) show.add('create');
    if (updateProps.containsKey(name)) show.add('edit');
    if (!_isAudit(name)) show.add('table');
    show.add('detail');

    final required = <String>[];
    if (createRequired.contains(name)) required.add('create');
    if (updateRequired.contains(name)) required.add('edit');

    final readOnly = <String>[];
    if (property['readOnly'] == true) {
      readOnly.addAll(['create', 'edit']);
    }

    return {
      'show': show,
      'required': required,
      'readOnly': readOnly,
    };
  }

  List<Map<String, dynamic>> _buildValidation(YamlMap property) {
    final rules = <Map<String, dynamic>>[];
    for (final key in [
      'minLength',
      'maxLength',
      'minimum',
      'maximum',
      'exclusiveMinimum',
      'exclusiveMaximum',
      'multipleOf',
      'minItems',
      'maxItems',
      'pattern',
      'format',
    ]) {
      if (property[key] != null) {
        rules.add({'type': key, 'value': property[key]});
      }
    }
    return rules;
  }

  List<Map<String, dynamic>> _buildRules(YamlMap property) {
    final raw = property['x-rules'] ?? property['x-field-rules'];
    if (raw is! YamlList) return <Map<String, dynamic>>[];
    return raw
        .whereType<YamlMap>()
        .map((rule) => Map<String, dynamic>.from(rule))
        .toList();
  }

  bool _skipUiMetadata(String fieldName, YamlMap property) {
    // Primary key / foreign keys
    if (fieldName.endsWith('_id')) {
      return true;
    }

    // Audit fields
    if ({
      'created_at',
      'created_by',
      'updated_at',
      'updated_by',
      'deleted_at',
      'deleted_by',
    }.contains(fieldName)) {
      return true;
    }

    // Read-only system fields
    if (property['readOnly'] == true) {
      return true;
    }

    // Explicit references
    if (property['x-reference'] != null) {
      return true;
    }

    return false;
  }

  Map<String, dynamic> _buildUiMetadata(
    String fieldName,
    YamlMap property, {
    Map<String, dynamic>? reference,
  }) {
    final ui = property['x-ui'] is YamlMap
        ? property['x-ui'] as YamlMap
        : YamlMap();

    final label = ui['label'] ?? _humanize(fieldName);

    return {
      'label': label,

      'placeholder':
          ui['placeholder'] ??
              (reference == null
                  ? _defaultPlaceholder(fieldName, property)
                  : 'Select ${_humanize(fieldName)}'),

      'hint': ui['hint'] ?? property['description'],

      'tooltip': ui['tooltip'] ?? property['description'],

      'helperText': ui['helperText'] ?? property['description'],

      'icon': ui['icon'],
      'hidden': ui['hidden'] == true,
    };
  }

  String _defaultPlaceholder(String name, YamlMap property) {
    final type = property['type']?.toString();

    final format = property['format']?.toString();

    if (format == 'email') {
      return 'Enter email address';
    }

    if (format == 'uuid') {
      return 'Select ${_humanize(name)}';
    }

    if (type == 'integer' || type == 'number') {
      return 'Enter ${_humanize(name)}';
    }

    if (type == 'boolean') {
      return '';
    }

    return 'Enter ${_humanize(name)}';
  }

  Map<String, dynamic>? _resolveSchema(dynamic schema, {Set<String>? visited}) {
    visited ??= <String>{};

    if (schema == null) {
      return null;
    }

    if (schema is! YamlMap) {
      return null;
    }

    // Reference schema
    if (schema[r'$ref'] != null) {
      final schemaName = schema[r'$ref'].toString().split('/').last;

      if (visited.contains(schemaName)) {
        return {'kind': 'ref', 'schema': schemaName, 'circular': true};
      }

      final target = schemas[schemaName];

      final nextVisited = Set<String>.from(visited)..add(schemaName);

      return {
        'kind': 'ref',
        'schema': schemaName,
        'resolved': target is YamlMap
            ? _buildSchemaDefinition(target, visited: nextVisited)
            : null,
      };
    }

    // Enum
    if (schema['enum'] is YamlList) {
      return {
        'kind': 'enum',
        'type': schema['type'] ?? 'string',
        'values': (schema['enum'] as YamlList).toList(),
        'default': schema['default'],
      };
    }

    // Array
    if (schema['type'] == 'array') {
      return {
        'kind': 'array',
        'items': _resolveSchema(schema['items'], visited: visited),
      };
    }

    // allOf
    if (schema['allOf'] is YamlList) {
      return {
        'kind': 'allOf',
        'schemas': (schema['allOf'] as YamlList)
            .map((item) => _resolveSchema(item, visited: visited))
            .toList(),
      };
    }

    // oneOf
    if (schema['oneOf'] is YamlList) {
      return {
        'kind': 'oneOf',
        'schemas': (schema['oneOf'] as YamlList)
            .map((item) => _resolveSchema(item, visited: visited))
            .toList(),
      };
    }

    // Object
    if (schema['type'] == 'object' || schema['properties'] != null) {
      return {
        'kind': 'object',
        'properties': _inlineProperties(schema, visited: visited),
      };
    }

    // Primitive
    return {
      'kind': 'primitive',

      'type': schema['type'] ?? 'string',

      if (schema['format'] != null) 'format': schema['format'],

      if (schema['description'] != null) 'description': schema['description'],

      if (schema['default'] != null) 'default': schema['default'],

      if (schema['nullable'] == true) 'nullable': true,
    };
  }

  Map<String, dynamic> _buildSchemaDefinition(
    YamlMap schema, {
    Set<String>? visited,
  }) {
    visited ??= <String>{};

    final props = _properties(schema);

    final required = ((schema['required'] as YamlList?) ?? [])
        .map((e) => e.toString())
        .toList();

    final properties = <String, dynamic>{};

    for (final entry in props.entries) {
      final fieldName = entry.key.toString();

      final fieldSchema = entry.value is YamlMap
          ? entry.value as YamlMap
          : YamlMap();

      final property = <String, dynamic>{
        'required': required.contains(fieldName),

        'type': fieldSchema['type'],

        'format': fieldSchema['format'],

        'title': fieldSchema['title'],

        'description': fieldSchema['description'],

        'nullable': fieldSchema['nullable'] == true,

        'readOnly': fieldSchema['readOnly'] == true,

        'writeOnly': fieldSchema['writeOnly'] == true,

        'deprecated': fieldSchema['deprecated'] == true,

        'default': fieldSchema['default'],

        'example': fieldSchema['example'],
        if (!_skipUiMetadata(fieldName, fieldSchema))
          'ui': _buildUiMetadata(fieldName, fieldSchema),

        'ui': _buildUiMetadata(fieldName, fieldSchema),
      };

      if (fieldSchema['enum'] is YamlList) {
        property['enum'] = (fieldSchema['enum'] as YamlList).toList();
      }

      final validations = <String, dynamic>{};

      for (final key in [
        'minimum',
        'maximum',
        'exclusiveMinimum',
        'exclusiveMaximum',
        'minLength',
        'maxLength',
        'pattern',
        'multipleOf',
        'minItems',
        'maxItems',
      ]) {
        if (fieldSchema[key] != null) {
          validations[key] = fieldSchema[key];
        }
      }

      if (validations.isNotEmpty) {
        property['validations'] = validations;
      }

      if (fieldSchema['x-reference'] is YamlMap) {
        final ref = fieldSchema['x-reference'] as YamlMap;

        property['reference'] = {
          'table': ref['table'],

          'column': ref['column'],

          'lookup': {
            'strategy': 'remote',

            'endpoint': '/${ref['table']}',

            'valueField': ref['column'],

            'placeholder': 'Search ${_humanize(fieldName)}',
          },
        };
      }

      property['schema'] = _resolveSchema(fieldSchema, visited: visited);

      properties[fieldName] = property;
    }

    return {
      'kind': 'schema',

      'type': schema['type'] ?? 'object',

      'title': schema['title'],

      'description': schema['description'],

      'required': required,

      'properties': properties,
    };
  }

  Map<String, dynamic> _inlineProperties(
    YamlMap schema, {
    required Set<String> visited,
  }) {
    final props = schema['properties'] as YamlMap? ?? YamlMap();

    final required = ((schema['required'] as YamlList?) ?? [])
        .map((e) => e.toString())
        .toSet();

    final result = <String, dynamic>{};

    for (final entry in props.entries) {
      final name = entry.key.toString();

      result[name] = {
        'required': required.contains(name),

        'schema': _resolveSchema(entry.value, visited: visited),
      };
    }

    return result;
  }

  Map<String, dynamic> _buildApi(table) {
    final paths = doc['paths'] as YamlMap? ?? YamlMap();

    final result = <String, dynamic>{};

    for (final path in paths.entries) {
      final url = path.key.toString();

      final methods = path.value as YamlMap;

      methods.forEach((method, _) {
        switch (method.toString().toUpperCase()) {
          case 'GET':
            if (url.contains('{')) {
              result['detail'] = {
                'path': url,
                'enabled': true,
                "permission": '$table.operation.detail',
              };
            } else {
              result['list'] = {
                'path': url,
                'enabled': true,
                "permission": '$table.operation.list',
              };
            }
            break;

          case 'POST':
            result['create'] = {
              'path': url,
              'enabled': true,
              "permission": '$table.operation.create',
            };
            break;

          case 'PUT':
          case 'PATCH':
            result['update'] = {
              'path': url,
              'enabled': true,
              "permission": '$table.operation.update',
            };
            break;

          case 'DELETE':
            result['delete'] = {
              'path': url,
              'enabled': true,
              "permission": '$table.operation.delete',
            };
            break;
        }
      });
    }

    return result;
  }

  String _primaryKey(List<Map<String, dynamic>> fields) {
    for (final field in fields) {
      final name = field['name'].toString();

      if (name.endsWith('_id') && name != 'account_id') {
        return name;
      }
    }

    return 'id';
  }

  bool _isAudit(String field) {
    return {
      'created_at',
      'created_by',
      'updated_at',
      'updated_by',
      'deleted_at',
    }.contains(field);
  }

  String _type(YamlMap property) {
    final format = property['format']?.toString();

    final type = property['type']?.toString();

    if (format == 'uuid') {
      return 'uuid';
    }

    if (format == 'date-time') {
      return 'datetime';
    }

    return type ?? 'string';
  }

  String _widget(YamlMap property) {
    final type = _type(property);

    switch (type) {
      case 'boolean':
        return 'switch';

      case 'integer':
        return 'number';

      case 'datetime':
        return 'datetime';

      default:
        return 'text';
    }
  }

  String _humanize(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ');
  }
}
