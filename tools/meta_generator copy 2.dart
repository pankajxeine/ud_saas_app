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

      'api': _buildApi(),

      'datatable': {
        'columns': fields
            .where((e) => e['showInTable'] == true)
            .map((e) => {'field': e['name'], 'label': e['label']})
            .toList(),
      },

      'form': {
        'create': fields
            .where((e) => e['showInCreate'] == true)
            .map((e) => e['name'])
            .toList(),
        'update': fields
            .where((e) => e['showInUpdate'] == true)
            .map((e) => e['name'])
            .toList(),
      },

      'detail': {'fields': fields.map((e) => e['name']).toList()},

      'references': references,

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

      final field = {
        'name': name,

        'label': _humanize(name),

        'type': _type(property),

        'widget': _widget(property),

        'nullable': property['nullable'] == true,

        'readOnly': property['readOnly'] == true,

        'requiredOnCreate': createRequired.contains(name),

        'requiredOnUpdate': updateRequired.contains(name),

        'showInCreate': createProps.containsKey(name),

        'showInUpdate': updateProps.containsKey(name),

        'showInDetail': true,

        'showInTable': !_isAudit(name),
      };

      if (property['x-reference'] is YamlMap) {
        final ref = property['x-reference'] as YamlMap;

        field['reference'] = {
          'table': ref['table'],
          'column': ref['column'],
          'lookup': {'endpoint': '/${ref['table']}'},
        };
      } else if (globalRefs.containsKey(name)) {
        field['reference'] = globalRefs[name];
      }

      fields.add(field);
    }

    return fields;
  }

  Map<String, dynamic> _buildApi() {
    final paths = doc['paths'] as YamlMap? ?? YamlMap();

    final api = <String, dynamic>{};

    for (final pathEntry in paths.entries) {
      final path = pathEntry.key.toString();

      final operations = pathEntry.value as YamlMap;

      for (final opEntry in operations.entries) {
        final method = opEntry.key.toString().toUpperCase();

        final operation = opEntry.value as YamlMap;

        final operationMeta = {
          'method': method,

          'path': path,

          'operationId': operation['operationId'],

          'summary': operation['summary'],

          'requestSchema': _extractRequestSchema(operation),

          'responseSchema': _extractResponseSchema(operation),
        };

        switch (method) {
          case 'GET':
            if (path.contains('{')) {
              api['detail'] = operationMeta;
            } else {
              api['list'] = operationMeta;
            }
            break;

          case 'POST':
            api['create'] = operationMeta;
            break;

          case 'PUT':
          case 'PATCH':
            api['update'] = operationMeta;
            break;

          case 'DELETE':
            api['delete'] = operationMeta;
            break;
        }
      }
    }

    return api;
  }

  Map<String, dynamic>? _extractRequestSchema(YamlMap operation) {
    final requestBody = operation['requestBody'];

    if (requestBody == null) {
      return null;
    }

    final content = (requestBody as YamlMap)['content'] as YamlMap?;

    if (content == null) {
      return null;
    }

    final json = content['application/json'];

    if (json == null) {
      return null;
    }

    final schema = (json as YamlMap)['schema'];

    return _resolveSchema(schema);
  }

  Map<String, dynamic>? _extractResponseSchema(YamlMap operation) {
    final responses = operation['responses'] as YamlMap?;

    if (responses == null) {
      return null;
    }

    for (final response in responses.entries) {
      final value = response.value;

      if (value is! YamlMap) {
        continue;
      }

      final content = value['content'] as YamlMap?;

      if (content == null) {
        continue;
      }

      final json = content['application/json'];

      if (json == null) {
        continue;
      }

      final schema = (json as YamlMap)['schema'];

      return _resolveSchema(schema);
    }

    return null;
  }

  Map<String, dynamic>? _resolveSchema(dynamic schema, {Set<String>? visited}) {
    visited ??= <String>{};

    if (schema == null) {
      return null;
    }

    if (schema is! YamlMap) {
      return null;
    }

    // $ref
    if (schema[r'$ref'] != null) {
      final schemaName = schema[r'$ref'].toString().split('/').last;

      // Prevent circular recursion
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

    // enum
    if (schema['enum'] is YamlList) {
      return {
        'kind': 'enum',
        'type': schema['type'] ?? 'string',
        'values': (schema['enum'] as YamlList).toList(),
      };
    }

    // array
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
            .map((e) => _resolveSchema(e, visited: visited))
            .toList(),
      };
    }

    // oneOf
    if (schema['oneOf'] is YamlList) {
      return {
        'kind': 'oneOf',

        'schemas': (schema['oneOf'] as YamlList)
            .map((e) => _resolveSchema(e, visited: visited))
            .toList(),
      };
    }

    // inline object
    if (schema['type'] == 'object' || schema['properties'] != null) {
      return {
        'kind': 'object',

        'properties': _inlineProperties(schema, visited),
      };
    }

    return {
      'kind': 'primitive',

      'type': schema['type'] ?? 'string',

      if (schema['format'] != null) 'format': schema['format'],
    };
  }

  Map<String, dynamic> _buildSchemaDefinition(
    YamlMap schema, {
    Set<String>? visited,
  }) {
    visited ??= <String>{};

    final required = ((schema['required'] as YamlList?) ?? [])
        .map((e) => e.toString())
        .toList();

    final props = _properties(schema);

    final properties = <String, dynamic>{};

    for (final field in props.entries) {
      final fieldName = field.key.toString();

      final fieldSchema = field.value is YamlMap
          ? field.value as YamlMap
          : YamlMap();

      final property = {
        'required': required.contains(fieldName),

        'type': fieldSchema['type'],

        'format': fieldSchema['format'],

        'description': fieldSchema['description'],

        'nullable': fieldSchema['nullable'] == true,

        'readOnly': fieldSchema['readOnly'] == true,

        'default': fieldSchema['default'],

        'schema': _resolveSchema(fieldSchema, visited: visited),
      };

      if (fieldSchema['enum'] is YamlList) {
        property['enum'] = (fieldSchema['enum'] as YamlList).toList();
      }

      if (fieldSchema['x-reference'] != null) {
        final ref = fieldSchema['x-reference'] as YamlMap;

        property['reference'] = {
          'table': ref['table'],

          'column': ref['column'],

          'lookup': {'endpoint': '/${ref['table']}', 'strategy': 'remote'},
        };
      }

      properties[fieldName] = property;
    }

    return {
      'type': schema['type'] ?? 'object',

      'description': schema['description'],

      'required': required,

      'properties': properties,
    };
  }

  Map<String, dynamic> _inlineProperties(YamlMap schema, Set<String> visited) {
    final props = schema['properties'] as YamlMap? ?? YamlMap();

    final required = ((schema['required'] as YamlList?) ?? [])
        .map((e) => e.toString())
        .toSet();

    final result = <String, dynamic>{};

    for (final entry in props.entries) {
      final fieldName = entry.key.toString();

      result[fieldName] = {
        'required': required.contains(fieldName),
        'schema': _resolveSchema(entry.value, visited: visited),
      };
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

  // Map<String, dynamic>? resolveSchema(dynamic schema) {
  //   if (schema == null) {
  //     return null;
  //   }

  //   if (schema is! YamlMap) {
  //     return null;
  //   }

  //   // $ref
  //   final ref = schema[r'$ref'];

  //   if (ref != null) {
  //     return {'type': 'ref', 'schema': ref.toString().split('/').last};
  //   }

  //   // array
  //   if (schema['type'] == 'array') {
  //     return {'type': 'array', 'items': resolveSchema(schema['items'])};
  //   }

  //   // object
  //   if (schema['type'] == 'object' || schema['properties'] != null) {
  //     return buildInlineSchema(schema);
  //   }

  //   // allOf
  //   if (schema['allOf'] != null) {
  //     return {
  //       'type': 'allOf',
  //       'schemas': (schema['allOf'] as YamlList).map(resolveSchema).toList(),
  //     };
  //   }

  //   // oneOf
  //   if (schema['oneOf'] != null) {
  //     return {
  //       'type': 'oneOf',
  //       'schemas': (schema['oneOf'] as YamlList).map(resolveSchema).toList(),
  //     };
  //   }

  //   return {'type': schema['type'] ?? 'string'};
  // }

  // Map<String, dynamic>? extractRequestSchema(YamlMap operation) {
  //   final req = operation['requestBody'];

  //   if (req == null) {
  //     return null;
  //   }

  //   final content = req['content'] as YamlMap?;

  //   final json = content?['application/json'] as YamlMap?;

  //   final schema = json?['schema'];

  //   return resolveSchema(schema);
  // }

  // Map<String, dynamic>? extractResponseSchema(YamlMap operation) {
  //   final responses = operation['responses'] as YamlMap?;

  //   if (responses == null) {
  //     return null;
  //   }

  //   for (final response in responses.entries) {
  //     final data = response.value as YamlMap;

  //     final content = data['content'] as YamlMap?;

  //     final json = content?['application/json'];

  //     if (json == null) {
  //       continue;
  //     }

  //     final schema = (json as YamlMap)['schema'];

  //     return resolveSchema(schema);
  //   }

  //   return null;
  // }

  // Map<String, dynamic> buildOperation(
  //   String method,
  //   String path,
  //   YamlMap operation,
  // ) {
  //   return {
  //     "method": method,

  //     "path": path,

  //     "requestSchema": extractRequestSchema(operation),

  //     "responseSchema": extractResponseSchema(operation),
  //   };
  // }

  String _humanize(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ');
  }
}
