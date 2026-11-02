import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

Future<void> main(List<String> args) async {
  final scanDir = args.isNotEmpty ? args.first : '.';

  final files = Directory(scanDir)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.openapi.yaml'))
      .toList();

  if (files.isEmpty) {
    throw Exception('No *.openapi.yaml files found');
  }

  for (final file in files) {
    try {
      await generateMeta(file);
    } catch (e) {
      print('Failed ${file.path}');
      print(e);
    }
  }

  print('Done');
}

Future<void> generateMeta(File file) async {
  print('Processing ${file.path}');

  final yaml = loadYaml(await file.readAsString());

  final generator = MetaGenerator(yaml);

  final meta = generator.generate();

  final module = file.uri.pathSegments.last.replaceAll('.openapi.yaml', '');

  final targetDir = Directory('modules/$module');

  targetDir.createSync(recursive: true);

  final target = File('${targetDir.path}/${module}_meta.json');

  target.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(meta));

  print('Generated ${target.path}');
}

class MetaGenerator {
  final YamlMap doc;

  MetaGenerator(this.doc);

  String get entityName {
    final schemas = doc['components']['schemas'] as YamlMap;

    final responseSchema = schemas.keys.firstWhere(
      (e) => e.toString().endsWith('Response'),
    );

    return responseSchema.toString().replaceAll('Response', '');
  }

  String get metaFileName => '${_snake(entityName)}_meta';

  Map<String, dynamic> generate() {
    final createSchema = _schema('${entityName}Request');

    final updateSchema = _schema('${entityName}UpdateRequest');

    final responseSchema = _schema('${entityName}Response');

    final references = _sqlReferences();

    final fields = _buildFields(
      createSchema,
      updateSchema,
      responseSchema,
      references,
    );

    return {
      'entity': entityName,
      'table': doc['x-sql-table'],
      'primaryKey': _primaryKey(responseSchema),
      'displayField': _displayField(responseSchema),
      'api': _api(),
      'datatable': _datatable(fields),
      'detail': {'fields': fields.map((e) => e['name']).toList()},
      'form': {
        'create': _formFields(fields, true),
        'update': _formFields(fields, false),
      },
      'references': references,
      'fields': fields,
    };
  }

  YamlMap _schema(String name) {
    return doc['components']['schemas'][name] as YamlMap;
  }

  Map<String, dynamic> _api() {
    final paths = doc['paths'] as YamlMap;

    final result = <String, dynamic>{};

    for (final entry in paths.entries) {
      final path = entry.key.toString();

      final methods = entry.value as YamlMap;

      methods.forEach((method, _) {
        final m = method.toString().toUpperCase();

        switch (m) {
          case 'GET':
            if (path.contains('{')) {
              result['detail'] = {'method': m, 'path': path};
            } else {
              result['list'] = {'method': m, 'path': path};
            }
            break;

          case 'POST':
            result['create'] = {'method': m, 'path': path};
            break;

          case 'PUT':
          case 'PATCH':
            result['update'] = {'method': m, 'path': path};
            break;

          case 'DELETE':
            result['delete'] = {'method': m, 'path': path};
            break;
        }
      });
    }

    return result;
  }

  Map<String, dynamic> _sqlReferences() {
    final refs = doc['x-sql-references'] as YamlList?;

    final result = <String, dynamic>{};

    if (refs == null) {
      return result;
    }

    for (final item in refs) {
      result[item['column']] = {
        'table': item['table'],
        'key': item['key'],
        'lookup': {'endpoint': '/${item['table']}'},
      };
    }

    return result;
  }

  List<Map<String, dynamic>> _buildFields(
    YamlMap create,
    YamlMap update,
    YamlMap response,
    Map<String, dynamic> references,
  ) {
    final createRequired = ((create['required'] as YamlList?) ?? [])
        .map((e) => e.toString())
        .toSet();

    final updateRequired = ((update['required'] as YamlList?) ?? [])
        .map((e) => e.toString())
        .toSet();

    final responseProps = response['properties'] as YamlMap;

    final createProps = create['properties'] as YamlMap;

    final updateProps = update['properties'] as YamlMap;

    final fields = <Map<String, dynamic>>[];

    for (final field in responseProps.entries) {
      final name = field.key.toString();

      final property = field.value as YamlMap;

      final item = <String, dynamic>{
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
        'showInTable': !_audit(name),
        'showInDetail': true,
      };

      final xRef = property['x-reference'];

      if (xRef != null) {
        final ref = xRef as YamlMap;

        item['reference'] = {
          'table': ref['table'],
          'column': ref['column'],
          'lookup': {'endpoint': '/${ref['table']}', 'strategy': 'remote'},
        };
      } else if (references.containsKey(name)) {
        item['reference'] = references[name];
      }

      if (property['enum'] != null) {
        item['options'] = (property['enum'] as YamlList).toList();
      }

      if (property['minimum'] != null) {
        item['minimum'] = property['minimum'];
      }

      if (property['maximum'] != null) {
        item['maximum'] = property['maximum'];
      }

      if (property['maxLength'] != null) {
        item['maxLength'] = property['maxLength'];
      }

      fields.add(item);
    }

    return fields;
  }

  String _primaryKey(YamlMap schema) {
    final props = schema['properties'] as YamlMap;

    for (final key in props.keys) {
      final name = key.toString();

      if (name.endsWith('_id') && name != 'account_id') {
        return name;
      }
    }

    return 'id';
  }

  String _displayField(YamlMap schema) {
    final props = schema['properties'] as YamlMap;

    const candidates = ['record_code', 'display_name', 'name', 'title'];

    for (final c in candidates) {
      if (props.containsKey(c)) {
        return c;
      }
    }

    return props.keys.first.toString();
  }

  Map<String, dynamic> _datatable(List<Map<String, dynamic>> fields) {
    return {
      'serverPaging': true,
      'serverSorting': true,
      'serverFiltering': true,
      'columns': fields
          .where((e) => e['showInTable'] == true)
          .map((e) => {'field': e['name'], 'label': e['label']})
          .toList(),
    };
  }

  List<String> _formFields(List<Map<String, dynamic>> fields, bool create) {
    return fields
        .where((field) {
          return create
              ? field['showInCreate'] == true
              : field['showInUpdate'] == true;
        })
        .map((e) => e['name'].toString())
        .toList();
  }

  bool _audit(String field) {
    return {
      'created_at',
      'created_by',
      'updated_at',
      'updated_by',
      'deleted_at',
    }.contains(field);
  }

  String _type(YamlMap property) {
    final type = property['type']?.toString();

    final format = property['format']?.toString();

    if (format == 'uuid') {
      return 'uuid';
    }

    if (format == 'date-time') {
      return 'datetime';
    }

    if (type == 'integer') {
      return 'integer';
    }

    if (type == 'boolean') {
      return 'boolean';
    }

    if (type == 'number') {
      return 'number';
    }

    return 'string';
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

  String _snake(String value) {
    return value
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m.group(1)}_${m.group(2)}',
        )
        .toLowerCase();
  }

  String _humanize(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ');
  }
}
