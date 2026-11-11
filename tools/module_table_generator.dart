import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final inputDir = Directory(_argument(args, '--input') ?? 'openapi').absolute;
  final outputDir = Directory(
    _argument(args, '--output') ?? '../lib/modules',
  ).absolute;
  final selectedMeta = _argument(args, '--meta');

  if (!inputDir.existsSync()) {
    throw StateError('Metadata input directory not found: ${inputDir.path}');
  }

  final inputRoot = _normalizedPath(inputDir.path);
  final metadataFiles = selectedMeta == null
      ? inputDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.toLowerCase().endsWith('_meta.json'))
            .toList()
      : <File>[File(selectedMeta).absolute];

  if (metadataFiles.isEmpty) {
    throw StateError('No *_meta.json files found under ${inputDir.path}');
  }

  for (final metadataFile in metadataFiles) {
    final metadataPath = _normalizedPath(metadataFile.absolute.path);
    if (!metadataPath.startsWith('$inputRoot${Platform.pathSeparator}')) {
      throw ArgumentError(
        'Selected metadata must be inside ${inputDir.path}: '
        '${metadataFile.path}',
      );
    }
    if (!metadataFile.existsSync()) {
      throw StateError('Metadata file not found: ${metadataFile.path}');
    }

    await _generateTable(metadataFile, inputRoot, outputDir);
  }
}

Future<void> _generateTable(
  File metadataFile,
  String inputRoot,
  Directory outputDir,
) async {
  final decoded = jsonDecode(await metadataFile.readAsString());
  if (decoded is! Map) {
    throw FormatException('Expected an object in ${metadataFile.path}');
  }
  final metadata = Map<String, dynamic>.from(decoded);
  final entity = metadata['entity']?.toString();
  final title = metadata['title']?.toString();
  final api = metadata['api'];
  final listApi = api is Map ? api['list'] : null;
  if (entity == null || entity.isEmpty) {
    throw FormatException('Metadata is missing "entity": ${metadataFile.path}');
  }
  if (listApi is! Map ||
      listApi['method']?.toString().toUpperCase() != 'GET' ||
      listApi['path'] is! String ||
      (listApi['path'] as String).isEmpty) {
    throw FormatException(
      'Metadata must define a GET api.list path: ${metadataFile.path}',
    );
  }

  final rawFields = metadata['fields'];
  if (rawFields is! List) {
    throw FormatException('Metadata must define fields: ${metadataFile.path}');
  }
  final columns = rawFields
      .map((value) {
        if (value is! Map) {
          throw FormatException(
            'Each table field must be an object: ${metadataFile.path}',
          );
        }
        return Map<String, dynamic>.from(value);
      })
      .where((field) {
        return field['showInTable'] == true;
      })
      .map((field) {
        final fieldName = field['name']?.toString();
        if (fieldName == null || fieldName.isEmpty) {
          throw FormatException(
            'Each table field needs a name: ${metadataFile.path}',
          );
        }
        return <String, dynamic>{
          'field': fieldName,
          'label': field['label']?.toString() ?? _humanize(fieldName),
          'type': field['type']?.toString() ?? 'string',
        };
      })
      .toList();
  if (columns.isEmpty) {
    throw FormatException(
      'Metadata has no fields with showInTable: true: ${metadataFile.path}',
    );
  }

  final metadataDir = _normalizedPath(metadataFile.parent.absolute.path);
  final relativeDir = metadataDir
      .substring(inputRoot.length)
      .replaceFirst(RegExp(r'^[/\\]+'), '');
  final moduleName = _snakeCase(
    metadataFile.uri.pathSegments.last.replaceFirst(
      RegExp(r'_meta\.json$', caseSensitive: false),
      '',
    ),
  );
  final className = '${_pascalCase(entity)}TablePage';
  final targetDir = Directory(
    '${outputDir.path}${Platform.pathSeparator}'
    '${relativeDir.isEmpty ? '' : '$relativeDir${Platform.pathSeparator}'}'
    'view',
  )..createSync(recursive: true);
  final target = File(
    '${targetDir.path}${Platform.pathSeparator}${moduleName}_table.dart',
  );

  await target.writeAsString(
    _renderTable(
      className: className,
      blocName: '${_pascalCase(entity)}TableBloc',
      title: title ?? _humanize(entity),
      endpoint: listApi['path'].toString(),
      primaryKey: metadata['primaryKey']?.toString(),
      columns: columns,
    ),
  );
  stdout.writeln('Generated ${target.path}');
}

String _renderTable({
  required String className,
  required String blocName,
  required String title,
  required String endpoint,
  required String? primaryKey,
  required List<Map<String, dynamic>> columns,
}) {
  final buffer = StringBuffer()
    ..writeln("import 'dart:convert';")
    ..writeln()
    ..writeln(
      "import 'package:flutter/material.dart' hide DataTable, Scaffold;",
    )
    ..writeln("import 'package:flutter_bloc/flutter_bloc.dart';")
    ..writeln("import 'package:ud_sass_app/core/api/rest_api.dart';")
    ..writeln("import 'package:ud_sass_app/core/config/environment.dart';")
    ..writeln(
      "import 'package:ud_sass_app/core/widgets/components/loading.dart';",
    )
    ..writeln(
      "import 'package:ud_sass_app/core/widgets/data_table/data_table.dart' as app_table;",
    )
    ..writeln("import 'package:ud_sass_app/ui/dashcn/components/button.dart';")
    ..writeln(
      "import 'package:ud_sass_app/ui/dashcn/components/scaffold.dart' as app_scaffold;",
    )
    ..writeln()
    ..writeln('sealed class ${blocName}Event {}')
    ..writeln()
    ..writeln(
      'final class Load${className.replaceFirst('Page', '')}Event extends ${blocName}Event {}',
    )
    ..writeln()
    ..writeln('sealed class ${blocName}State {}')
    ..writeln()
    ..writeln('final class ${blocName}Initial extends ${blocName}State {}')
    ..writeln()
    ..writeln('final class ${blocName}Loading extends ${blocName}State {}')
    ..writeln()
    ..writeln('final class ${blocName}Loaded extends ${blocName}State {')
    ..writeln('  ${blocName}Loaded(this.rows);')
    ..writeln('  final List<Map<String, dynamic>> rows;')
    ..writeln('}')
    ..writeln()
    ..writeln('final class ${blocName}Failure extends ${blocName}State {')
    ..writeln('  ${blocName}Failure(this.message);')
    ..writeln('  final String message;')
    ..writeln('}')
    ..writeln()
    ..writeln(
      'class $blocName extends Bloc<${blocName}Event, ${blocName}State> {',
    )
    ..writeln('  $blocName({required this.api, required this.endpoint})')
    ..writeln('    : super(${blocName}Initial()) {')
    ..writeln('    on<Load${className.replaceFirst('Page', '')}Event>(_load);')
    ..writeln('  }')
    ..writeln()
    ..writeln('  final RestApi api;')
    ..writeln('  final String endpoint;')
    ..writeln()
    ..writeln('  Future<void> _load(')
    ..writeln('    Load${className.replaceFirst('Page', '')}Event event,')
    ..writeln('    Emitter<${blocName}State> emit,')
    ..writeln('  ) async {')
    ..writeln('    emit(${blocName}Loading());')
    ..writeln('    try {')
    ..writeln('      final response = await api.get<dynamic>(endpoint);')
    ..writeln('      emit(${blocName}Loaded(_parseRows(response)));')
    ..writeln('    } catch (error, stackTrace) {')
    ..writeln('      addError(error, stackTrace);')
    ..writeln('      emit(${blocName}Failure(error.toString()));')
    ..writeln('    }')
    ..writeln('  }')
    ..writeln('}')
    ..writeln()
    ..writeln('List<Map<String, dynamic>> _parseRows(dynamic response) {')
    ..writeln('  dynamic records = response;')
    ..writeln('  while (records is Map && records.containsKey(\'data\')) {')
    ..writeln('    records = records[\'data\'];')
    ..writeln('  }')
    ..writeln('  if (records is! List) {')
    ..writeln(
      "    throw const FormatException('List API response must be an array or a data envelope');",
    )
    ..writeln('  }')
    ..writeln('  return records.map((record) {')
    ..writeln('    if (record is! Map) {')
    ..writeln(
      "      throw const FormatException('List API response contains a non-object record');",
    )
    ..writeln('    }')
    ..writeln('    return Map<String, dynamic>.from(record);')
    ..writeln('  }).toList(growable: false);')
    ..writeln('}')
    ..writeln()
    ..writeln('class $className extends StatelessWidget {')
    ..writeln('  const $className({super.key});')
    ..writeln()
    ..writeln('  @override')
    ..writeln(
      '  Widget build(BuildContext context) => BlocProvider<$blocName>(',
    )
    ..writeln('    create: (_) => $blocName(')
    ..writeln('      api: RestApi(baseUrl: ProfileConstants.api.toString()),')
    ..writeln('      endpoint: ${jsonEncode(endpoint)},')
    ..writeln('    )..add(Load${className.replaceFirst('Page', '')}Event()),')
    ..writeln('    child: app_scaffold.Scaffold(')
    ..writeln('      child: Padding(')
    ..writeln('        padding: const EdgeInsets.all(16),')
    ..writeln('        child: BlocBuilder<$blocName, ${blocName}State>(')
    ..writeln('          builder: (context, state) {')
    ..writeln('            if (state is ${blocName}Loading ||')
    ..writeln('                state is ${blocName}Initial) {')
    ..writeln('              return const Center(child: Loading());')
    ..writeln('            }')
    ..writeln('            if (state is ${blocName}Failure) {')
    ..writeln('              return Center(')
    ..writeln('                child: Column(')
    ..writeln('                  mainAxisSize: MainAxisSize.min,')
    ..writeln('                  children: [')
    ..writeln('                    Text(state.message),')
    ..writeln('                    const SizedBox(height: 12),')
    ..writeln('                    Button(')
    ..writeln(
      '                      onPressed: () => context.read<$blocName>().add('
      'Load${className.replaceFirst('Page', '')}Event()),',
    )
    ..writeln('                      child: const Text(\'Retry\'),')
    ..writeln('                    ),')
    ..writeln('                  ],')
    ..writeln('                ),')
    ..writeln('              );')
    ..writeln('            }')
    ..writeln('            if (state is ${blocName}Loaded) {')
    ..writeln('              final columns = <app_table.TrinaColumn>[');

  for (final column in columns) {
    final field = column['field'] as String;
    final type = column['type'] as String;
    final gridType = {'integer', 'number'}.contains(type)
        ? 'app_table.TrinaColumnType.number()'
        : 'app_table.TrinaColumnType.text()';
    buffer
      ..writeln('                app_table.TrinaColumn(')
      ..writeln('                  title: ${jsonEncode(column['label'])},')
      ..writeln('                  field: ${jsonEncode(field)},')
      ..writeln('                  type: $gridType,')
      ..writeln('                ),');
  }

  buffer
    ..writeln('              ];')
    ..writeln('              final rows = state.rows.map((record) {')
    ..writeln('                return app_table.TrinaRow<dynamic>(')
    ..writeln('                  cells: <String, app_table.TrinaCell>{');

  for (final column in columns) {
    final field = column['field'] as String;
    final type = column['type'] as String;
    buffer.writeln(
      '                    ${jsonEncode(field)}: app_table.TrinaCell('
      'value: _displayCell(record[${jsonEncode(field)}], '
      '${jsonEncode(type)})),',
    );
  }

  buffer
    ..writeln('                  },')
    ..writeln('                );')
    ..writeln('              }).toList(growable: false);')
    ..writeln('              return app_table.DataTable(')
    ..writeln('                title: ${jsonEncode(title)},')
    ..writeln('                columns: columns,')
    ..writeln('                rows: rows,');
  if (primaryKey != null && primaryKey.isNotEmpty) {
    buffer.writeln(
      '                mobileRowKey: (row) => '
      "row.cells[${jsonEncode(primaryKey)}]?.value.toString() ?? '',",
    );
  }
  buffer
    ..writeln('              );')
    ..writeln('            }')
    ..writeln('            return const SizedBox.shrink();')
    ..writeln('          },')
    ..writeln('        ),')
    ..writeln('      ),')
    ..writeln('    ),')
    ..writeln('  );')
    ..writeln('}')
    ..writeln()
    ..writeln('dynamic _displayCell(dynamic value, String type) {')
    ..writeln("  if (value == null) return '-';")
    ..writeln('  if (type == \'integer\' || type == \'number\') {')
    ..writeln('    if (value is num) return value;')
    ..writeln('    return num.tryParse(value.toString()) ?? value.toString();')
    ..writeln('  }')
    ..writeln("  if (type == 'boolean') {")
    ..writeln("    if (value == true) return 'Yes';")
    ..writeln("    if (value == false) return 'No';")
    ..writeln('  }')
    ..writeln('  if (value is Map || value is List) return jsonEncode(value);')
    ..writeln('  return value.toString();')
    ..writeln('}');
  return buffer.toString();
}

String? _argument(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1) return null;
  if (index + 1 >= args.length || args[index + 1].startsWith('--')) {
    throw ArgumentError('Expected a value after $name');
  }
  return args[index + 1];
}

String _normalizedPath(String path) =>
    Directory(path).absolute.path.replaceAll('/', r'\').toLowerCase();

String _snakeCase(String value) => value
    .replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match[1]}_${match[2]}',
    )
    .toLowerCase();

String _pascalCase(String value) {
  final words = value
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match[1]} ${match[2]}',
      )
      .split(RegExp(r'[^A-Za-z0-9]+'))
      .where((word) => word.isNotEmpty);
  return words
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join();
}

String _humanize(String value) => value
    .replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match[1]} ${match[2]}',
    )
    .replaceAll(RegExp(r'[_-]+'), ' ')
    .split(RegExp(r'\s+'))
    .where((word) => word.isNotEmpty)
    .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');
