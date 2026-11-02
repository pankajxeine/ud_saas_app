import 'dart:io';
import 'package:yaml/yaml.dart';

Map<String, dynamic> toMap(Map<dynamic, dynamic> yamlMap) {
  return yamlMap.map((key, value) {
    if (value is Map) {
      return MapEntry(key.toString(), toMap(value));
    } else if (value is List) {
      return MapEntry(
        key.toString(),
        value.map((e) => e is Map ? toMap(e) : e).toList(),
      );
    } else {
      return MapEntry(key.toString(), value);
    }
  });
}

String toPascalCase(String str) {
  return str
      .split(RegExp(r'[_\s]+'))
      .map(
        (word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
      )
      .join();
}

String dartTypeFromSchema(
  Map<String, dynamic> schema,
  String name,
  Map<String, String> nestedClasses, {
  bool required = true,
}) {
  final type = schema['type'];
  String dartType;
  switch (type) {
    case 'string':
      dartType = 'String';
      break;
    case 'integer':
      dartType = 'int';
      break;
    case 'number':
      dartType = 'double';
      break;
    case 'boolean':
      dartType = 'bool';
      break;
    case 'array':
      final items = schema['items'] as Map?;
      final itemType = items != null
          ? dartTypeFromSchema(
              Map<String, dynamic>.from(items),
              name,
              nestedClasses,
              required: true,
            )
          : 'dynamic';
      dartType = 'List<$itemType>';
      break;
    case 'object':
      final className = "${name[0].toUpperCase()}${name.substring(1)}";
      nestedClasses[className] = generateModel(
        className,
        schema,
        nestedClasses,
      );
      dartType = className;
      break;
    default:
      dartType = 'dynamic';
  }

  final isNullable = schema['nullable'] == true || !required;
  return isNullable ? "$dartType?" : dartType;
}

/// Convert snake_case to lowerCamelCase for Dart field names
String toCamelCase(String name) {
  return name.replaceAllMapped(RegExp(r'_([a-z])'), (m) => m[1]!.toUpperCase());
}

/// Generate a Dart model class from an OpenAPI schema
String generateModel(
  String className,
  Map<String, dynamic> schema,
  Map<String, String> nestedClasses,
) {
  final props = schema['properties'] as Map<String, dynamic>? ?? {};
  final requiredFields =
      (schema['required'] as List?)?.map((e) => e.toString()).toList() ?? [];
  final buffer = StringBuffer();

  buffer.writeln("class $className {");

  // Fields
  props.forEach((name, def) {
    final isRequired = requiredFields.contains(name);
    final type = dartTypeFromSchema(
      Map<String, dynamic>.from(def),
      name,
      nestedClasses,
      required: isRequired,
    );
    final fieldName = toCamelCase(name);
    buffer.writeln("  final $type $fieldName;");
  });

  // Constructor
  buffer.write("  $className({");
  props.forEach((name, def) {
    final isRequired = requiredFields.contains(name);
    final fieldName = toCamelCase(name);
    buffer.write(
      isRequired ? "required this.$fieldName, " : "this.$fieldName, ",
    );
  });
  buffer.writeln("});");

  // fromJson
  buffer.writeln(
    "  factory $className.fromJson(Map<String, dynamic> json) => $className(",
  );
  props.forEach((name, def) {
    final isRequired = requiredFields.contains(name);
    final type = dartTypeFromSchema(
      Map<String, dynamic>.from(def),
      name,
      nestedClasses,
      required: isRequired,
    );
    final fieldName = toCamelCase(name);

    if (type.startsWith("List")) {
      buffer.writeln(
        "    $fieldName: (json['$name'] as List${isRequired ? '' : '?'})?.map((e) => e).toList(),",
      );
    } else if (nestedClasses.containsKey(type.replaceAll('?', ''))) {
      buffer.writeln(
        "    $fieldName: json['$name'] != null ? ${type.replaceAll('?', '')}.fromJson(json['$name']) : null,",
      );
    } else {
      if (isRequired) {
        buffer.writeln(
          "    $fieldName: json['$name'] as ${type.replaceAll('?', '')},",
        );
      } else {
        buffer.writeln(
          "    $fieldName: json['$name'] as ${type.replaceAll('?', '')}?,",
        );
      }
    }
  });
  buffer.writeln("  );");

  // toJson
  buffer.writeln("  Map<String, dynamic> toJson() => {");
  props.forEach((name, def) {
    final isRequired = requiredFields.contains(name);
    final type = dartTypeFromSchema(
      Map<String, dynamic>.from(def),
      name,
      nestedClasses,
      required: isRequired,
    );
    final fieldName = toCamelCase(name);

    if (nestedClasses.containsKey(type.replaceAll('?', ''))) {
      buffer.writeln("    '$name': $fieldName?.toJson(),");
    } else {
      buffer.writeln("    '$name': $fieldName,");
    }
  });
  buffer.writeln("  };");

  buffer.writeln("}");

  return buffer.toString();
}

void main() {
  final specsDir = Directory('specs');
  if (!specsDir.existsSync()) {
    print("Specs folder not found: ${specsDir.path}");
    exit(1);
  }

  final files = specsDir
      .listSync()
      .where((f) => f is File && f.path.endsWith('.openapi.yaml'))
      .cast<File>();

  for (final file in files) {
    final filename = file.uri.pathSegments.last;
    final moduleName = filename.replaceAll('.openapi.yaml', '');

    print("🔧 Generating module: $moduleName");

    final yaml = loadYaml(file.readAsStringSync()) as YamlMap;
    final spec = toMap(yaml);

    final paths = spec['paths'] as Map<String, dynamic>;
    final components =
        spec['components']?['schemas'] as Map<String, dynamic>? ?? {};

    final generatedModels = <String>{};

    Map<String, dynamic>? resolveSchema(dynamic schema) {
      if (schema == null) return null;
      if (schema is Map && schema.containsKey(r'$ref')) {
        final ref = schema[r'$ref'] as String;
        final parts = ref.split('/');
        final name = parts.last;
        return components[name] as Map<String, dynamic>?;
      }
      return schema as Map<String, dynamic>?;
    }

    String? resolveSchemaName(dynamic schema) {
      if (schema == null) return null;
      if (schema is Map && schema.containsKey(r'$ref')) {
        final ref = schema[r'$ref'] as String;
        return toPascalCase(ref.split('/').last);
      }
      return null;
    }

    final baseDir = Directory('../lib/modules/$moduleName');
    final modelDir = Directory('${baseDir.path}/models')
      ..createSync(recursive: true);
    final repoDir = Directory('${baseDir.path}/repositories')
      ..createSync(recursive: true);
    final serviceDir = Directory('${baseDir.path}/services')
      ..createSync(recursive: true);
    final blocDir = Directory('${baseDir.path}/bloc')
      ..createSync(recursive: true);

    final exports = <String>[];

    // Generate all component schemas once
    components.forEach((schemaName, schemaDef) {
      if (!generatedModels.contains(schemaName)) {
        final modelCode = generateModel(
          toPascalCase(schemaName),
          schemaDef as Map<String, dynamic>,
          {},
        );
        File(
          "${modelDir.path}/${toPascalCase(schemaName)}.dart",
        ).writeAsStringSync(modelCode);
        exports.add("export 'models/${toPascalCase(schemaName)}.dart';");
        generatedModels.add(schemaName);
      }
    });

    // Process paths
    paths.forEach((endpoint, methods) {
      (methods as Map<String, dynamic>).forEach((method, details) {
        final opId =
            details['operationId'] ??
            "${method}_${endpoint.replaceAll('/', '_')}";
        final shortName = toPascalCase(opId);

        final requestSchema =
            details['requestBody']?['content']?['application/json']?['schema'];
        final responseSchema =
            details['responses']?['200']?['content']?['application/json']?['schema'] ??
            details['responses']?['201']?['content']?['application/json']?['schema'];

        final requestModelName = resolveSchemaName(requestSchema);
        final responseModelName = resolveSchemaName(responseSchema);

        // Repository
        final repoName = "${shortName}Repository";
        File("${repoDir.path}/$repoName.dart").writeAsStringSync("""
import '../../utils/rest_api.dart';
${requestModelName != null ? "import '../models/$requestModelName.dart';" : ""}
${responseModelName != null ? "import '../models/$responseModelName.dart';" : ""}

class $repoName {
  final api = RestApi();

  Future<${responseModelName ?? 'Map<String,dynamic>'}> fetch(${requestModelName ?? 'Map<String,dynamic>'} request) async {
    final response = await api.request(
      endpoint: '$endpoint',
      method: '${method.toUpperCase()}',
      body: request.toJson(),
    );
    return ${responseModelName != null ? "$responseModelName.fromJson(response.data)" : "response.data"};
  }
}
""");
        exports.add("export 'repositories/$repoName.dart';");

        // Service
        final serviceName = "${shortName}Service";
        File("${serviceDir.path}/$serviceName.dart").writeAsStringSync("""
import '../repositories/$repoName.dart';
${requestModelName != null ? "import '../models/$requestModelName.dart';" : ""}
${responseModelName != null ? "import '../models/$responseModelName.dart';" : ""}

class $serviceName {
  final _repo = $repoName();

  Future<${responseModelName ?? 'Map<String,dynamic>'}> getData(${requestModelName ?? 'Map<String,dynamic>'} request) =>
      _repo.fetch(request);
}
""");
        exports.add("export 'services/$serviceName.dart';");

        // Bloc
        final blocName = "${shortName}Bloc";
        File("${blocDir.path}/$blocName.dart").writeAsStringSync("""
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/$serviceName.dart';
${requestModelName != null ? "import '../models/$requestModelName.dart';" : ""}
${responseModelName != null ? "import '../models/$responseModelName.dart';" : ""}

class ${shortName}Event {
  final ${requestModelName ?? 'Map<String,dynamic>'} request;
  ${shortName}Event(this.request);
}

class ${shortName}State {
  final bool loading;
  final String? error;
  final ${responseModelName ?? 'Map<String,dynamic>'}? data;

  ${shortName}State({this.loading = false, this.error, this.data});
}

class $blocName extends Bloc<${shortName}Event, ${shortName}State> {
  final $serviceName service;

  $blocName(this.service) : super(${shortName}State()) {
    on<${shortName}Event>((event, emit) async {
      emit(${shortName}State(loading: true));
      try {
        final data = await service.getData(event.request);
        emit(${shortName}State(data: data));
      } catch (e) {
        emit(${shortName}State(error: e.toString()));
      }
    });
  }
}
""");
        exports.add("export 'bloc/$blocName.dart';");
      });
    });

    File("${baseDir.path}/index.dart").writeAsStringSync(exports.join("\n"));
  }

  print(
    "✅ Codegen complete. Models generated once per schema and reused with proper types in repos, services, and blocs.",
  );
}
