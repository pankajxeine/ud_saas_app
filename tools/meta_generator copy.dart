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
    final primaryKey = _primaryKey(fields, entity);
    for (final field in fields) {
      field['isPrimaryKey'] = field['name'] == primaryKey;
    }

    return {
      'schemaVersion': 2,
      'entity': entity,
      'title': _humanize(entity),
      'table': doc['x-sql-table'],
      'primaryKey': primaryKey,
      'schemas': _buildComponentSchemas(),
      'api': _buildApi(),
      'datatable': {
        'columns': fields
            .where((e) => e['showInTable'] == true)
            .map(
              (field) => {
                'field': field['name'],
                'label': field['label'],
                'type': field['type'],
                'format': field['format'],
                'sortable': field['sortable'],
                'filterable': field['filterable'],
              },
            )
            .toList(),
      },
      'form': {
        'create': fields
            .where((field) => field['showInCreate'] == true)
            .map((field) => field['name'])
            .toList(),
        'update': fields
            .where((field) => field['showInUpdate'] == true)
            .map((field) => field['name'])
            .toList(),
      },
      'detail': {
        'fields': fields
            .where((field) => field['showInDetail'] == true)
            .map((field) => field['name'])
            .toList(),
      },
      'references': references,
      'fields': fields,
      'diagnostics': _diagnostics(fields),
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
    if (list != null) {
      for (final item in list) {
        if (item is! YamlMap || item['column'] == null) continue;
        final column = item['column'].toString();
        result[column] = _referenceMetadata(
          table: item['table']?.toString(),
          column: item['key']?.toString(),
          lookup: item['lookup'] is YamlMap ? item['lookup'] as YamlMap : null,
        );
      }
    }

    for (final schema in schemas.values.whereType<YamlMap>()) {
      for (final entry in _properties(schema).entries) {
        final property = entry.value;
        if (property is! YamlMap || property['x-reference'] is! YamlMap) {
          continue;
        }
        final ref = _referenceMetadataFromProperty(property);
        if (ref != null) result.putIfAbsent(entry.key.toString(), () => ref);
      }
    }
    return result;
  }

  List<Map<String, dynamic>> _buildFields(
    YamlMap? createSchema,
    YamlMap? updateSchema,
    YamlMap? responseSchema,
    Map<String, dynamic> globalRefs,
  ) {
    final createProps = _properties(createSchema);
    final updateProps = _properties(updateSchema);
    final responseProps = _properties(responseSchema);
    final createRequired = _required(createSchema);
    final updateRequired = _required(updateSchema);
    final fields = <Map<String, dynamic>>[];

    final names = <String>{
      ...responseProps.keys.map((key) => key.toString()),
      ...createProps.keys.map((key) => key.toString()),
      ...updateProps.keys.map((key) => key.toString()),
    };

    for (final name in names) {
      final responseProperty = _property(responseProps, name);
      final createProperty = _property(createProps, name);
      final updateProperty = _property(updateProps, name);
      final primaryProperty =
          responseProperty ?? createProperty ?? updateProperty ?? YamlMap();
      final typeProperty =
          responseProperty != null &&
              (responseProperty['type'] != null ||
                  responseProperty['format'] != null)
          ? responseProperty
          : createProperty ?? updateProperty ?? primaryProperty;
      final createField = createProperty == null
          ? null
          : _schemaProperty(
              createProperty,
              required: createRequired.contains(name),
            );
      final updateField = updateProperty == null
          ? null
          : _schemaProperty(
              updateProperty,
              required: updateRequired.contains(name),
            );
      final resolvedType = _type(typeProperty);
      final referenceProperty =
          [
            responseProperty,
            createProperty,
            updateProperty,
          ].whereType<YamlMap>().firstWhere(
            (property) => property['x-reference'] is YamlMap,
            orElse: () => primaryProperty,
          );
      final reference = _referenceFor(referenceProperty, name, globalRefs);
      final constraints = _constraints(typeProperty);
      final field = <String, dynamic>{
        'order': fields.length,
        'name': name,
        'label': _humanize(name),
        'type': resolvedType,
        if (typeProperty['format'] != null)
          'format': typeProperty['format'].toString(),
        'widget': _widget(typeProperty, hasReference: reference != null),
        if (typeProperty['description'] != null)
          'description': typeProperty['description'].toString(),
        'nullable': typeProperty['nullable'] == true,
        'readOnly': typeProperty['readOnly'] == true,
        'requiredOnCreate': createRequired.contains(name),
        'requiredOnUpdate': updateRequired.contains(name),
        'requiredValueOnCreate':
            createRequired.contains(name) &&
            createProperty?['nullable'] != true,
        'requiredValueOnUpdate':
            updateRequired.contains(name) &&
            updateProperty?['nullable'] != true,
        'nullableOnCreate': createProperty?['nullable'] == true,
        'nullableOnUpdate': updateProperty?['nullable'] == true,
        'showInCreate': createProps.containsKey(name),
        'showInUpdate': updateProps.containsKey(name),
        'editableOnCreate':
            createProperty != null &&
            createProperty['readOnly'] != true &&
            typeProperty['readOnly'] != true,
        'editableOnUpdate':
            updateProperty != null &&
            updateProperty['readOnly'] != true &&
            typeProperty['readOnly'] != true,
        'showInDetail': responseProps.containsKey(name),
        'showInTable': !_isAudit(name),
        'sortable': _isSortableType(resolvedType),
        'filterable': _isFilterableType(resolvedType),
        'constraints': constraints,
        if (createProperty != null)
          'createConstraints': _constraints(createProperty),
        if (updateProperty != null)
          'updateConstraints': _constraints(updateProperty),
        if (createField != null) 'create': createField,
        if (updateField != null) 'update': updateField,
      };

      if (typeProperty.containsKey('default')) {
        field['default'] = _plainValue(typeProperty['default']);
      }
      if (createProperty?.containsKey('default') == true) {
        field['defaultOnCreate'] = _plainValue(createProperty!['default']);
      }
      if (updateProperty?.containsKey('default') == true) {
        field['defaultOnUpdate'] = _plainValue(updateProperty!['default']);
      }
      if (typeProperty['enum'] is YamlList) {
        field['options'] = _plainValue(typeProperty['enum']);
      }
      final fieldSchema = _schemaNode(typeProperty);
      if (fieldSchema != null &&
          fieldSchema['kind'] != 'primitive' &&
          fieldSchema['kind'] != 'unknown' &&
          fieldSchema['kind'] != 'enum') {
        field['schema'] = fieldSchema;
      }
      if (reference != null) field['reference'] = reference;

      fields.add(field);
    }
    return fields;
  }

  Map<String, dynamic> _buildApi() {
    final paths = doc['paths'] as YamlMap? ?? YamlMap();
    final api = <String, dynamic>{};
    final allOperations = <Map<String, dynamic>>[];

    for (final pathEntry in paths.entries) {
      final path = pathEntry.key.toString();
      if (pathEntry.value is! YamlMap) continue;
      final pathItem = pathEntry.value as YamlMap;
      final pathParameters = pathItem['parameters'] as YamlList? ?? YamlList();
      for (final opEntry in pathItem.entries) {
        if (opEntry.value is! YamlMap) continue;
        final method = opEntry.key.toString().toUpperCase();
        if (!{'GET', 'POST', 'PUT', 'PATCH', 'DELETE'}.contains(method)) {
          continue;
        }
        final operation = opEntry.value as YamlMap;
        final successResponse = _successResponse(operation);
        final responseSchema = _extractResponseSchema(operation);
        final operationMeta = <String, dynamic>{
          'method': method,
          'path': path,
          if (operation['operationId'] != null)
            'operationId': operation['operationId'].toString(),
          if (operation['summary'] != null)
            'summary': operation['summary'].toString(),
          'parameters': _operationParameters(pathParameters, operation),
          'requestBodyRequired':
              (operation['requestBody'] as YamlMap?)?['required'] == true,
          'requestSchema': _extractRequestSchema(operation),
          'responseSchema': responseSchema,
          if (successResponse != null) ...{
            'successStatus': successResponse['status'],
            if ((successResponse['value'] as YamlMap?)?['description'] != null)
              'successDescription':
                  (successResponse['value'] as YamlMap)['description']
                      .toString(),
          },
        };
        final operationId =
            operationMeta['operationId']?.toString() ??
            '${method.toLowerCase()}_${_snakeCase(path)}';
        operationMeta['key'] = operationId;
        allOperations.add(operationMeta);

        switch (method) {
          case 'GET':
            if (path.contains('{')) {
              api['detail'] = _operationPointer(operationMeta);
            } else {
              api['list'] = _operationPointer(operationMeta);
            }
            break;

          case 'POST':
            api['create'] = _operationPointer(operationMeta);
            break;

          case 'PUT':
          case 'PATCH':
            api['update'] = _operationPointer(operationMeta);
            break;

          case 'DELETE':
            api['delete'] = _operationPointer(operationMeta);
            break;
        }
      }
    }
    api['operations'] = allOperations;
    return api;
  }

  Map<String, dynamic> _operationPointer(Map<String, dynamic> operation) => {
    'operationId': operation['operationId'],
    'key': operation['key'],
    'method': operation['method'],
    'path': operation['path'],
  };

  Map<String, dynamic>? _extractRequestSchema(YamlMap operation) {
    final requestBody = operation['requestBody'] as YamlMap?;
    final content = requestBody?['content'] as YamlMap?;
    final jsonContent = content?['application/json'] as YamlMap?;
    return _schemaNode(jsonContent?['schema']);
  }

  Map<String, dynamic>? _schemaNode(dynamic schema) {
    if (schema is! YamlMap) return null;
    final ref = schema[r'$ref'];
    if (ref != null) {
      return {'kind': 'ref', 'schema': ref.toString().split('/').last};
    }
    if (schema['enum'] is YamlList) {
      return {
        'kind': 'enum',
        'type': schema['type']?.toString() ?? 'string',
        'values': _plainValue(schema['enum']),
        if (_constraints(schema).isNotEmpty)
          'constraints': _constraints(schema),
      };
    }
    if (schema['type'] == 'array') {
      return {
        'kind': 'array',
        'items': _schemaNode(schema['items']),
        if (_constraints(schema).isNotEmpty)
          'constraints': _constraints(schema),
      };
    }
    for (final union in ['allOf', 'oneOf', 'anyOf']) {
      if (schema[union] is YamlList) {
        return {
          'kind': union,
          'schemas': (schema[union] as YamlList).map(_schemaNode).toList(),
        };
      }
    }
    if (schema['type'] == 'object' || schema['properties'] != null) {
      final properties = schema['properties'] as YamlMap? ?? YamlMap();
      final required = _required(schema);
      return {
        'kind': 'object',
        'required': required.toList(),
        'properties': {
          for (final entry in properties.entries)
            entry.key.toString(): _schemaProperty(
              entry.value is YamlMap ? entry.value as YamlMap : YamlMap(),
              required: required.contains(entry.key.toString()),
            ),
        },
      };
    }
    final type = schema['type']?.toString();
    return {
      'kind': type == null ? 'unknown' : 'primitive',
      if (type != null) 'type': type,
      if (schema['format'] != null) 'format': schema['format'].toString(),
      if (schema['nullable'] == true) 'nullable': true,
      if (schema.containsKey('default'))
        'default': _plainValue(schema['default']),
      if (_constraints(schema).isNotEmpty) 'constraints': _constraints(schema),
    };
  }

  Map<String, dynamic> _buildComponentSchemas() {
    return {
      for (final entry in schemas.entries)
        entry.key.toString(): _schemaDefinition(
          entry.value is YamlMap ? entry.value as YamlMap : YamlMap(),
        ),
    };
  }

  Map<String, dynamic> _schemaDefinition(YamlMap schema) {
    final properties = _properties(schema);
    final required = _required(schema);
    return {
      if (schema['type'] != null) 'type': schema['type'].toString(),
      if (schema['format'] != null) 'format': schema['format'].toString(),
      if (schema['description'] != null)
        'description': schema['description'].toString(),
      'required': required.toList(),
      if (properties.isNotEmpty)
        'properties': {
          for (final entry in properties.entries)
            entry.key.toString(): _schemaProperty(
              entry.value is YamlMap ? entry.value as YamlMap : YamlMap(),
              required: required.contains(entry.key.toString()),
            ),
        },
      if (schema['enum'] is YamlList) 'enum': _plainValue(schema['enum']),
      if (schema['default'] != null) 'default': _plainValue(schema['default']),
      if (_constraints(schema).isNotEmpty) 'constraints': _constraints(schema),
      if (schema[r'$ref'] != null ||
          schema['type'] == 'array' ||
          schema['allOf'] is YamlList ||
          schema['oneOf'] is YamlList ||
          schema['anyOf'] is YamlList)
        'schema': _schemaNode(schema),
    };
  }

  Map<String, dynamic> _schemaProperty(
    YamlMap schema, {
    required bool required,
  }) {
    final reference = _referenceMetadataFromProperty(schema);
    final schemaNode = _schemaNode(schema);
    final schemaKind = schemaNode?['kind'];
    return {
      'required': required,
      'type': schema['type']?.toString() ?? 'unknown',
      if (schema['format'] != null) 'format': schema['format'].toString(),
      if (schema['description'] != null)
        'description': schema['description'].toString(),
      'nullable': schema['nullable'] == true,
      'readOnly': schema['readOnly'] == true,
      if (schema.containsKey('default'))
        'default': _plainValue(schema['default']),
      if (schema['enum'] is YamlList) 'enum': _plainValue(schema['enum']),
      if (_constraints(schema).isNotEmpty) 'constraints': _constraints(schema),
      if (schemaKind != 'primitive' && schemaKind != 'unknown')
        'schema': schemaNode,
      if (reference != null) 'reference': reference,
    };
  }

  Map<String, dynamic>? _referenceMetadataFromProperty(YamlMap property) {
    final reference = property['x-reference'] as YamlMap?;
    if (reference == null) return null;
    final lookup = reference['lookup'] as YamlMap?;
    return _referenceMetadata(
      table: reference['table']?.toString(),
      column: reference['column']?.toString(),
      lookup: lookup,
    );
  }

  Map<String, dynamic> _referenceMetadata({
    String? table,
    String? column,
    YamlMap? lookup,
  }) {
    final endpoint = lookup?['endpoint']?.toString();
    return {
      if (table != null) 'table': table,
      if (column != null) ...{'column': column, 'valueField': column},
      'lookup': {
        'strategy': 'remote',
        'configured': endpoint != null,
        if (endpoint != null) 'endpoint': endpoint,
        'labelField': lookup?['labelField']?.toString(),
      },
    };
  }

  Map<String, dynamic>? _referenceFor(
    YamlMap property,
    String fieldName,
    Map<String, dynamic> globalRefs,
  ) {
    final propertyReference = _referenceMetadataFromProperty(property);
    if (propertyReference != null) return propertyReference;
    return globalRefs[fieldName] as Map<String, dynamic>?;
  }

  List<Map<String, dynamic>> _operationParameters(
    YamlList pathParameters,
    YamlMap operation,
  ) {
    final parameters = <String, YamlMap>{};
    for (final item in pathParameters) {
      if (item is YamlMap) {
        parameters['${item['in']}:${item['name']}'] = item;
      }
    }
    final operationParameters =
        operation['parameters'] as YamlList? ?? YamlList();
    for (final item in operationParameters) {
      if (item is YamlMap) {
        parameters['${item['in']}:${item['name']}'] = item;
      }
    }
    return parameters.values.map((parameter) {
      final schema = parameter['schema'] as YamlMap? ?? YamlMap();
      return {
        'name': parameter['name']?.toString(),
        'in': parameter['in']?.toString(),
        'required': parameter['required'] == true,
        if (parameter['description'] != null)
          'description': parameter['description'].toString(),
        'schema': _schemaNode(schema),
      };
    }).toList();
  }

  Map<String, dynamic>? _extractResponseSchema(YamlMap operation) {
    final success = _successResponse(operation);
    if (success == null) return null;
    final response = success['value'] as YamlMap?;
    final content = response?['content'] as YamlMap?;
    final jsonContent = content?['application/json'] as YamlMap?;
    return _schemaNode(jsonContent?['schema']);
  }

  Map<String, dynamic>? _successResponse(YamlMap operation) {
    final responses = operation['responses'] as YamlMap?;
    if (responses == null) return null;
    final entries = responses.entries.toList()
      ..sort((first, second) {
        final firstCode = int.tryParse(first.key.toString()) ?? 0;
        final secondCode = int.tryParse(second.key.toString()) ?? 0;
        final firstSuccess = firstCode >= 200 && firstCode < 300;
        final secondSuccess = secondCode >= 200 && secondCode < 300;
        if (firstSuccess != secondSuccess) return firstSuccess ? -1 : 1;
        return firstCode.compareTo(secondCode);
      });
    for (final entry in entries) {
      final status = entry.key.toString();
      final code = int.tryParse(status);
      if (code == null || code < 200 || code >= 300) continue;
      if (entry.value is YamlMap) {
        return {'status': code, 'value': entry.value as YamlMap};
      }
    }
    return null;
  }

  String _primaryKey(List<Map<String, dynamic>> fields, String entity) {
    final names = fields.map((field) => field['name'].toString()).toSet();
    final configured =
        doc['x-sql-primary-key']?.toString() ??
        doc['x-primary-key']?.toString();
    if (configured != null) {
      if (!names.contains(configured)) {
        throw FormatException(
          'Configured primary key "$configured" is not present in the entity schema',
        );
      }
      return configured;
    }

    final conventional = '${_snakeCase(entity)}_id';
    if (names.contains(conventional)) return conventional;
    if (names.contains('id')) return 'id';

    final readOnlyIds = fields
        .where(
          (field) =>
              field['readOnly'] == true &&
              field['name'].toString().endsWith('_id'),
        )
        .map((field) => field['name'].toString())
        .toList();
    if (readOnlyIds.length == 1) return readOnlyIds.single;

    throw FormatException(
      'Unable to determine primary key for $entity. '
      'Set x-sql-primary-key in the OpenAPI document.',
    );
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

  YamlMap? _property(YamlMap properties, String name) {
    final value = properties[name];
    return value is YamlMap ? value : null;
  }

  String _type(YamlMap property) {
    final format = property['format']?.toString();
    if (format == 'uuid') {
      return 'uuid';
    }
    if (format == 'date-time') {
      return 'datetime';
    }
    if (format == 'date') return 'date';
    return property['type']?.toString() ?? 'unknown';
  }

  String _widget(YamlMap property, {required bool hasReference}) {
    final type = _type(property);
    if (hasReference) return 'reference';
    if (property['enum'] is YamlList) return 'select';
    switch (type) {
      case 'boolean':
        return 'switch';
      case 'integer':
      case 'number':
        return 'number';
      case 'datetime':
      case 'date':
        return 'datetime';
      case 'unknown':
        return 'unsupported';
      default:
        if (property['format'] == 'email') return 'email';
        if (((property['maxLength'] as num?)?.toInt() ?? 0) > 100) {
          return 'textarea';
        }
        return 'text';
    }
  }

  Map<String, dynamic> _constraints(YamlMap schema) {
    const keys = <String>[
      'minimum',
      'maximum',
      'exclusiveMinimum',
      'exclusiveMaximum',
      'multipleOf',
      'minLength',
      'maxLength',
      'pattern',
      'minItems',
      'maxItems',
      'uniqueItems',
      'minProperties',
      'maxProperties',
    ];
    return {
      for (final key in keys)
        if (schema.containsKey(key)) key: _plainValue(schema[key]),
    };
  }

  dynamic _plainValue(dynamic value) {
    if (value is YamlMap) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _plainValue(entry.value),
      };
    }
    if (value is YamlList) {
      return value.map(_plainValue).toList();
    }
    return value;
  }

  bool _isSortableType(String type) => {
    'string',
    'uuid',
    'integer',
    'number',
    'boolean',
    'date',
    'datetime',
  }.contains(type);

  bool _isFilterableType(String type) => _isSortableType(type);

  String _snakeCase(String value) => value
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match[1]}_${match[2]}',
      )
      .toLowerCase();

  List<Map<String, dynamic>> _diagnostics(
    List<Map<String, dynamic>> fields,
  ) => [
    for (final field in fields)
      if (field['type'] == 'unknown')
        {
          'severity': 'warning',
          'code': 'missing_field_type',
          'field': field['name'],
          'message':
              'OpenAPI property "${field['name']}" has no type; '
              'generated form widget is unsupported.',
        },
    for (final field in fields)
      if (field['reference']?['lookup']?['configured'] == false)
        {
          'severity': 'warning',
          'code': 'reference_lookup_not_configured',
          'field': field['name'],
          'message':
              'Reference field "${field['name']}" has no lookup endpoint or '
              'display field; configure these in x-reference.lookup.',
        },
  ];

  String _humanize(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ');
  }
}
