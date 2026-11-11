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
        'columns': fields
            .where((e) => e['showInTable'] == true)
            .map((e) => {'field': e['name'], 'label': e['label']})
            .toList(),
      },

      // 'form': {
      //   'create': fields
      //       .where((e) => e['showInCreate'] == true)
      //       .map((e) => e['name'])
      //       .toList(),
      //   'update': fields
      //       .where((e) => e['showInUpdate'] == true)
      //       .map((e) => e['name'])
      //       .toList(),
      // },
      'detail': {'fields': fields.map((e) => e['name']).toList()},

      // 'references': references,
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
      result[item['column']] = {
        'table': item['table'],
        'key': item['key'],
        'lookup': {'endpoint': '/${item['table']}', 'strategy': 'remote'},
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

      final field = <String, dynamic>{
        // Identity
        'name': name,
        'label': _humanize(name),

        // Type metadata
        'type': _type(property),

        'widget': _widget(property),
        //ui property
        if (!_skipUiMetadata(name, property))
          'ui': _buildUiMetadata(name, property),

        'format': property['format'],

        // Documentation
        'title': property['title'],

        'description': property['description'],

        // Visibility
        'showInTable': !_isAudit(name),

        'showInDetail': true,

        'showInCreate': createProps.containsKey(name),

        'showInUpdate': updateProps.containsKey(name),

        // Permissions
        'permissions': {
          'read': true,
          'create': createProps.containsKey(name),
          'update': updateProps.containsKey(name),
        },

        // Required Rules
        'requiredOnCreate': createRequired.contains(name),

        'requiredOnUpdate': updateRequired.contains(name),

        // OpenAPI flags
        'nullable': property['nullable'] == true,

        'readOnly': property['readOnly'] == true,

        'writeOnly': property['writeOnly'] == true,

        'deprecated': property['deprecated'] == true,
      };

      // Validation block
      final validations = <String, dynamic>{};

      if (property['minimum'] != null) {
        validations['minimum'] = property['minimum'];
      }

      if (property['maximum'] != null) {
        validations['maximum'] = property['maximum'];
      }

      if (property['minLength'] != null) {
        validations['minLength'] = property['minLength'];
      }

      if (property['maxLength'] != null) {
        validations['maxLength'] = property['maxLength'];
      }

      if (property['pattern'] != null) {
        validations['pattern'] = property['pattern'];
      }

      if (property['multipleOf'] != null) {
        validations['multipleOf'] = property['multipleOf'];
      }

      if (validations.isNotEmpty) {
        field['validations'] = validations;
      }

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

      // Reference support
      if (property['x-reference'] is YamlMap) {
        final ref = property['x-reference'] as YamlMap;

        field['reference'] = {
          'table': ref['table'],

          'column': ref['column'],

          'lookup': {
            'strategy': 'remote',

            'endpoint': '/${ref['table']}',

            'displayField': 'name',

            'valueField': ref['column'],
          },
        };
      } else if (globalRefs.containsKey(name)) {
        field['reference'] = globalRefs[name];
      }

      // Association ($ref)
      if (property[r'$ref'] != null) {
        field['association'] = _resolveSchema(property);
      }

      fields.add(field);
    }

    return fields;
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

  Map<String, dynamic> _buildUiMetadata(String fieldName, YamlMap property) {
    final ui = property['x-ui'] is YamlMap
        ? property['x-ui'] as YamlMap
        : YamlMap();

    final label = ui['label'] ?? _humanize(fieldName);

    return {
      'label': label,

      'placeholder':
          ui['placeholder'] ?? _defaultPlaceholder(fieldName, property),

      'hint': ui['hint'] ?? property['description'],

      'tooltip': ui['tooltip'] ?? property['description'],

      'helperText': ui['helperText'] ?? property['description'],

      'icon': ui['icon'],
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
