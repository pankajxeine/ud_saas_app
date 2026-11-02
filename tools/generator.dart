import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:mustache_template/mustache.dart';
import 'package:logger/logger.dart';

final log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
);

void main() async {
  log.i('🚀 Starting generator...');

  final specsDir = Directory('specs');
  final templatesDir = Directory('templates');
  final outputDir = Directory('../lib/modules');

  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
    log.i('Created output directory: ${outputDir.path}');
  }

  final specsRoot = specsDir.absolute.path;
  final specFiles = specsDir.listSync(recursive: true).whereType<File>().where((
    file,
  ) {
    final extension = file.path.toLowerCase();
    return extension.endsWith('.yaml') || extension.endsWith('.yml');
  });
  final generatedRoutes = <Map<String, dynamic>>[];

  for (var file in specFiles) {
    log.i('Processing spec file: ${file.path}');
    final yaml = loadYaml(await file.readAsString());
    final moduleName = file.uri.pathSegments.last.split('.').first;
    log.i('Generating module: $moduleName');

    // Mirror the spec's directory structure beneath lib/modules. For example,
    // specs/cpanel/accounts/users.openapi.yaml generates into
    // lib/modules/cpanel/accounts/users.
    final relativeParent = file.parent.absolute.path
        .substring(specsRoot.length)
        .replaceFirst(RegExp(r'^[/\\]+'), '');
    final moduleDir = Directory(
      relativeParent.isEmpty
          ? '${outputDir.path}/$moduleName'
          : '${outputDir.path}/$relativeParent/$moduleName',
    );
    final parentDepth = relativeParent.isEmpty
        ? 0
        : relativeParent.split(RegExp(r'[/\\]+')).length;
    final coreImport = '${List.filled(3 + parentDepth, '../').join()}core';
    if (!moduleDir.existsSync()) {
      moduleDir.createSync(recursive: true);
      log.i('Created module directory: ${moduleDir.path}');
    }

    final modelDir = Directory('${moduleDir.path}/model')
      ..createSync(recursive: true);
    final repoDir = Directory('${moduleDir.path}/repository')
      ..createSync(recursive: true);
    final serviceDir = Directory('${moduleDir.path}/service')
      ..createSync(recursive: true);
    final blocDir = Directory('${moduleDir.path}/bloc')
      ..createSync(recursive: true);
    final viewDir = Directory('${moduleDir.path}/view')
      ..createSync(recursive: true);
    final metaDir = Directory('${moduleDir.path}/meta')
      ..createSync(recursive: true);

    // Generate models
    final schemas = yaml['components']?['schemas'] ?? {};
    String? requestClass;
    String? responseClass;

    final modelFieldsByClass = <String, List<Map<String, dynamic>>>{};
    for (var entry in schemas.entries) {
      final className = entry.key;
      if (entry.key.toLowerCase().contains('request')) requestClass = className;
      if (entry.key.toLowerCase().contains('response'))
        responseClass = className;

      print("className:" + className);
      final schema = entry.value as Map;
      final requiredRaw = schema['required'];
      final requiredList = (requiredRaw is Iterable)
          ? List<String>.from(requiredRaw.cast<String>())
          : <String>[];

      final vars = (schema['properties'] ?? {}).entries
          .map((prop) {
            final propName = prop.key as String;
            final propSchema = prop.value as Map;
            final baseType = _mapType(propSchema['type']);
            final isRequired = requiredList.contains(propName);
            final datatype = isRequired ? baseType : '$baseType?';
            final castType = isRequired ? baseType : '$baseType?';
            final maxLength = propSchema['maxLength'];
            final entityFieldType = _entityFieldType(
              propName,
              propSchema,
              baseType,
            );
            return {
              'name': _toLowerCamelCase(propName),
              'datatype': datatype,
              'baseName': propName,
              'required': isRequired,
              'castType': castType,
              'nullableSuffix': isRequired ? '' : '?',
              'isNumeric': baseType == 'int' || baseType == 'bouble',
              'isSensitive': _isSensitiveField(propName),
              'label': _toLabel(propName),
              'maxLength': maxLength,
              'hasMaxLength': maxLength is int,
              'entityFieldType': entityFieldType,
              'formFieldType': _appDynamicFieldType(entityFieldType),
              'isIntegerFormField': baseType == 'int',
              'isDoubleFormField': baseType == 'double',
              'isNumericField': entityFieldType == 'numer',
              'isBooleanField': entityFieldType == 'boolean',
            };
          })
          .toList()
          .cast<Map<String, dynamic>>();

      final modelTemplate = Template(
        await File('${templatesDir.path}/model.mustache').readAsString(),
        name: 'model',
      );

      final modelContent = modelTemplate.renderString({
        'classname': className,
        'vars': vars,
      });

      final fileName = _toSnakeCase(entry.key) + '.dart';
      File('${modelDir.path}/$fileName').writeAsStringSync(modelContent);
      log.i('Generated model: $fileName');
      modelFieldsByClass[className] = vars;
    }

    final models = modelDir
        .listSync()
        .whereType<File>()
        .map((f) => {'file': f.uri.pathSegments.last})
        .toList();

    final primaryEntityClass = responseClass ?? requestClass;
    final requestFieldNames = (modelFieldsByClass[requestClass] ?? [])
        .map((f) => f['baseName'] as String)
        .toSet();
    final entityFields = (modelFieldsByClass[primaryEntityClass] ?? [])
        .where((f) => f['isSensitive'] != true)
        .map(
          (f) => {
            ...f,
            'editable':
                requestClass == null ||
                requestFieldNames.contains(f['baseName']),
          },
        )
        .toSet();

    // Collect endpoints
    final paths = yaml['paths'] ?? {};
    final endpoints = <Map<String, dynamic>>[];

    for (var entry in paths.entries) {
      final path = entry.key as String;
      log.i('Found path: $path');

      final operations = entry.value as Map;
      for (var opEntry in operations.entries) {
        final httpMethod = opEntry.key.toUpperCase();
        final op = opEntry.value as Map;
        final opId = op['operationId'] ?? '${path}_${opEntry.key}';
        final operationIdPascal = _toUpperCamel(opId);

        // Detect path and query parameters
        final parameters = (op['parameters'] ?? []) as List;
        final pathParams = parameters.where((p) => p['in'] == 'path').map((p) {
          final paramName = p['name'] as String;
          final dartName = _toLowerCamelCase(paramName);
          final paramSchema = p['schema'] as Map? ?? {};
          return {
            'name': dartName,
            'original': paramName,
            'datatype': _mapType(paramSchema['type'] as String?),
            'required': p['required'] == true,
          };
        }).toList();

        final queryParams = parameters.where((p) => p['in'] == 'query').map((
          p,
        ) {
          final paramName = p['name'] as String;
          final dartName = _toLowerCamelCase(paramName);
          final paramSchema = p['schema'] as Map? ?? {};
          final isRequired = p['required'] == true;
          return {
            'name': dartName,
            'original': paramName,
            'datatype': isRequired
                ? _mapType(paramSchema['type'] as String?)
                : '${_mapType(paramSchema['type'] as String?)}?',
            'required': isRequired,
          };
        }).toList();

        if (pathParams.isNotEmpty) {
          log.i(
            'Path parameters detected: ${pathParams.map((p) => p['original']).join(', ')}',
          );
        }
        if (queryParams.isNotEmpty) {
          log.i(
            'Query parameters detected: ${queryParams.map((p) => p['original']).join(', ')}',
          );
        }

        print("path : $path , httpMethod $httpMethod");

        final requestBody = op['requestBody'] as Map?;
        final requestBodySchema =
            requestBody?['content']?['application/json']?['schema'] as Map?;
        final requestBodyClass =
            _extractRefClass(requestBodySchema) ??
            requestClass ??
            'Map<String, dynamic>';
        final hasRequestBody = requestBody != null;
        final requestBodyName = hasRequestBody ? 'request' : null;

        final isCreateOrDelete = httpMethod == 'POST' || httpMethod == 'DELETE';

        // Determine response shape for decoder
        Map? successResponse;
        String? successStatusCode;
        if (op['responses'] is Map) {
          for (var r in (op['responses'] as Map).entries) {
            if ((r.key as String).startsWith('2')) {
              successStatusCode = r.key as String;
              successResponse = r.value as Map?;
              break;
            }
          }
        }

        final responseSchema =
            successResponse?['content']?['application/json']?['schema'];
        final isArrayResponse =
            responseSchema is Map &&
            (responseSchema['type'] == 'array' ||
                responseSchema['items'] != null);

        final responseClassForEndpoint =
            _extractRefClass(responseSchema) ?? responseClass ?? 'Response';
        final hasNoContent =
            successResponse == null ||
            successResponse['content'] == null ||
            (successResponse['content'] is Map &&
                (successResponse['content'] as Map).isEmpty);

        final responseDecoder = isArrayResponse
            ? "return (json as List).map((e) => $responseClassForEndpoint.fromJson(e as Map<String, dynamic>)).toList();"
            : "return $responseClassForEndpoint.fromJson(json as Map<String, dynamic>);";

        final responseType = isCreateOrDelete
            ? 'Map<String, dynamic>'
            : isArrayResponse
            ? 'List<$responseClassForEndpoint>'
            : (hasNoContent
                  ? '$responseClassForEndpoint?'
                  : '$responseClassForEndpoint');

        final isListEndpoint =
            httpMethod == 'GET' && isArrayResponse && pathParams.isEmpty;
        final columns = (modelFieldsByClass[responseClassForEndpoint] ?? [])
            .where((field) => !field['isSensitive'])
            .toList();

        final methodParams = <String>[];
        for (final param in pathParams) {
          methodParams.add('${param['datatype']} ${param['name']}');
        }
        if (hasRequestBody) {
          methodParams.add('$requestBodyClass $requestBodyName');
        }
        for (final param in queryParams) {
          methodParams.add('${param['datatype']} ${param['name']}');
        }

        final methodCallParams = <String>[];
        for (final param in pathParams) {
          methodCallParams.add(param['name'] as String);
        }
        if (hasRequestBody) {
          methodCallParams.add(requestBodyName!);
        }
        for (final param in queryParams) {
          methodCallParams.add(param['name'] as String);
        }

        final endpointParams = <Map<String, dynamic>>[];
        endpointParams.addAll(pathParams);
        if (hasRequestBody) {
          endpointParams.add({
            'name': requestBodyName,
            'datatype': requestBodyClass,
            'required': true,
            'in': 'body',
          });
        }
        endpointParams.addAll(queryParams);

        final endpoint = {
          'operationId': opId,
          'OperationId': operationIdPascal,
          'methodName': opId,
          'moduleName': moduleName,
          'serviceName': _toUpperCamel(moduleName),
          'RequestClass': requestBodyClass,
          'ResponseClass': responseClassForEndpoint,
          'ResponseType': responseType,
          'path': path,
          'httpMethod': httpMethod,
          'requestFields': pathParams,
          'pathParams': pathParams,
          'queryParams': queryParams,
          'parameters': endpointParams,
          'methodParams': methodParams.join(', '),
          'methodCallEventParams': methodCallParams
              .map((p) => 'event.' + p)
              .join(', '),
          'methodCallParams': methodCallParams.join(', '),
          'endpointPathExpression': _dartPathExpression(path),
          'hasQueryParams': queryParams.isNotEmpty,
          'hasRequestBody': hasRequestBody,
          'requestBodyName': requestBodyName,
          'responseDecoder': responseDecoder,
          'isArrayResponse': isArrayResponse,
          'hasNoContent': hasNoContent,
          'isCreateOrDelete': isCreateOrDelete,
          'isParametersExist': endpointParams.isNotEmpty,
          'isListEndpoint': isListEndpoint,
          'columns': columns,
          'blocFieldName': _toSnakeCase(operationIdPascal),
        };
        endpoints.add(endpoint);

        await _generateFile(
          'bloc',
          templatesDir,
          blocDir,
          operationIdPascal,
          models: models,
          requestClass: requestClass,
          responseClass: responseClass,
          endpoint: endpoint,
          coreImport: coreImport,
        );
      }
    }

    // Generate repository and service
    await _generateFile(
      'repository',
      templatesDir,
      repoDir,
      moduleName,
      models: models,
      requestClass: requestClass,
      responseClass: responseClass,
      endpoints: endpoints,
      coreImport: coreImport,
    );

    await _generateFile(
      'service',
      templatesDir,
      serviceDir,
      moduleName,
      models: models,
      requestClass: requestClass,
      responseClass: responseClass,
      endpoints: endpoints,
      coreImport: coreImport,
    );

    final listEndpoint = endpoints.firstWhere(
      (e) => e['isListEndpoint'] == true,
      orElse: () => <String, dynamic>{},
    );
    final detailEndpoint = endpoints.firstWhere(
      (e) =>
          e['httpMethod'] == 'GET' &&
          e['isArrayResponse'] != true &&
          (e['pathParams'] as List).length == 1,
      orElse: () => <String, dynamic>{},
    );
    final createEndpoint = endpoints.firstWhere(
      (e) => e['httpMethod'] == 'POST' && e['hasRequestBody'] == true,
      orElse: () => <String, dynamic>{},
    );
    final updateEndpoint = endpoints.firstWhere(
      (e) =>
          (e['httpMethod'] == 'PUT' || e['httpMethod'] == 'PATCH') &&
          e['hasRequestBody'] == true &&
          (e['pathParams'] as List).isNotEmpty,
      orElse: () => <String, dynamic>{},
    );
    final deleteEndpoint = endpoints.firstWhere(
      (e) => e['httpMethod'] == 'DELETE',
      orElse: () => <String, dynamic>{},
    );
    final canGenerateForm =
        (createEndpoint.isNotEmpty || updateEndpoint.isNotEmpty) &&
        requestClass != null &&
        requestClass != 'Map<String, dynamic>' &&
        entityFields.isNotEmpty;
    final canGenerateDetail =
        detailEndpoint.isNotEmpty && entityFields.isNotEmpty;

    final listColumns = (listEndpoint['columns'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    final routePath = _moduleRoutePath(relativeParent, moduleName);
    final detailRouteExpression = canGenerateDetail
        ? _itemRouteExpression(
            routePath,
            (detailEndpoint['pathParams'] as List).cast<Map>(),
          )
        : null;
    final editRouteExpression =
        canGenerateForm && (updateEndpoint['pathParams'] as List).isNotEmpty
        ? _itemRouteExpression(
            routePath,
            (updateEndpoint['pathParams'] as List).cast<Map>(),
            suffix: '/edit',
          )
        : null;
    final cardTitleField = listColumns.isEmpty
        ? null
        : listColumns.firstWhere(
            (field) => field['isNumeric'] != true,
            orElse: () => listColumns.first,
          )['name'];
    final titleIndex = listColumns.indexWhere(
      (field) => field['name'] == cardTitleField,
    );
    final cardSubtitleField =
        titleIndex >= 0 && titleIndex + 1 < listColumns.length
        ? listColumns[titleIndex + 1]['name']
        : null;

    if (listEndpoint.isNotEmpty) {
      await _generateFile(
        'page',
        templatesDir,
        viewDir,
        moduleName,
        models: models,
        requestClass: requestClass,
        responseClass: responseClass,
        endpoint: listEndpoint,
        extra: {
          'basePath': routePath,
          'pageTitle': _toLabel(moduleName),
          'hasDetailPage': canGenerateDetail,
          'detailRouteExpression': detailRouteExpression,
          'detailRouteGuard': _itemRouteGuard(detailEndpoint),
          'hasFormPage': canGenerateForm && editRouteExpression != null,
          'editRouteExpression': editRouteExpression,
          'editRouteGuard': _itemRouteGuard(updateEndpoint),
          'hasCreatePage': canGenerateForm,
          'cardTitleField': cardTitleField,
          'hasCardTitleField': cardTitleField != null,
          'cardSubtitleField': cardSubtitleField,
          'hasCardSubtitle': cardSubtitleField != null,
        },
        coreImport: coreImport,
      );
    } else {
      log.w(
        'No List endpoint found for module $moduleName, skipping page generation',
      );
    }

    if (entityFields.isNotEmpty) {
      _generateFile(
        'meta',
        templatesDir,
        metaDir,
        moduleName,
        extra: {'fields': entityFields},
      );

      if (detailEndpoint.isNotEmpty) {
        await _generateFile(
          'details_page',
          templatesDir,
          viewDir,
          moduleName,
          models: models,
          requestClass: requestClass,
          responseClass: responseClass,
          endpoint: detailEndpoint,
          extra: {'fields': entityFields},
        );
      } else {
        log.w(
          'No get by id found for module $moduleName, skipping page generation',
        );
      }

      if (canGenerateForm) {
        await _generateFile(
          'form_page',
          templatesDir,
          viewDir,
          moduleName,
          models: models,
          requestClass: requestClass,
          responseClass: responseClass,
          endpoint: updateEndpoint.isNotEmpty ? updateEndpoint : createEndpoint,
          extra: {
            'fields': entityFields,
            'hasCreateEndpoint': createEndpoint.isNotEmpty,
            'hasUpdateEndpoint': updateEndpoint.isNotEmpty,
            'createEndpoint': createEndpoint,
            'updateEndpoint': updateEndpoint,
            'requestModelFile': _toSnakeCase(requestClass!),
            'updatePathParams': _withLastFlag(
              (updateEndpoint['pathParams'] ?? <Map<String, dynamic>>[])
                  .cast<Map<String, dynamic>>(),
            ),
            'createCallArgs': _widgetCallArguments(createEndpoint),
            'updateCallArgs': _widgetCallArguments(
              updateEndpoint,
              assertWidgetParamsNonNull: true,
            ),
          },
          coreImport: coreImport,
        );
      } else {
        log.w(
          'No create/update found for module $moduleName, skipping page generation',
        );
      }
    }

    if (deleteEndpoint.isNotEmpty) {
      await _generateFile(
        'delete_page',
        templatesDir,
        viewDir,
        moduleName,
        endpoint: deleteEndpoint,
        extra: {'deleteCallArgs': _widgetCallArguments(deleteEndpoint)},
        coreImport: coreImport,
      );
    }

    final moduleImportPath = [
      '..',
      'modules',
      if (relativeParent.isNotEmpty) ...relativeParent.split(RegExp(r'[/\\]+')),
      moduleName,
      'view',
    ].join('/');
    generatedRoutes.add({
      'alias': 'generatedModule${generatedRoutes.length}',
      'basePath': routePath,
      'pageClass': '${_toUpperCamel(moduleName)}Page',
      'pageImport': '$moduleImportPath/${_toSnakeCase(moduleName)}_page.dart',
      'hasListPage': listEndpoint.isNotEmpty,
      'detailPageClass': '${_toUpperCamel(moduleName)}DetailPage',
      'detailImport':
          '$moduleImportPath/${_toSnakeCase(moduleName)}_details_page.dart',
      'hasDetailPage': canGenerateDetail,
      'detailParams': detailEndpoint['pathParams'] ?? <Map<String, dynamic>>[],
      'formPageClass': '${_toUpperCamel(moduleName)}FormPage',
      'formImport':
          '$moduleImportPath/${_toSnakeCase(moduleName)}_form_page.dart',
      'hasFormPage': canGenerateForm,
      'updateParams': updateEndpoint['pathParams'] ?? <Map<String, dynamic>>[],
      'deletePageClass': '${_toUpperCamel(moduleName)}DeletePage',
      'deleteImport':
          '$moduleImportPath/${_toSnakeCase(moduleName)}_delete_page.dart',
      'hasDeletePage': deleteEndpoint.isNotEmpty,
      'deleteParams': deleteEndpoint['pathParams'] ?? <Map<String, dynamic>>[],
    });

    // Generate index file
    final indexTemplate = Template(
      await File('${templatesDir.path}/index.mustache').readAsString(),
      name: 'index',
    );

    final repositories = repoDir
        .listSync()
        .whereType<File>()
        .map((f) => {'file': f.uri.pathSegments.last})
        .toList();

    final services = serviceDir
        .listSync()
        .whereType<File>()
        .map((f) => {'file': f.uri.pathSegments.last})
        .toList();

    final blocs = blocDir
        .listSync()
        .whereType<File>()
        .map((f) => {'file': f.uri.pathSegments.last})
        .toList();

    final views = viewDir
        .listSync()
        .whereType<File>()
        .map((f) => {'file': f.uri.pathSegments.last})
        .toList();

    final metas = metaDir
        .listSync()
        .whereType<File>()
        .map((f) => {'file': f.uri.pathSegments.last})
        .toList();

    final indexContent = indexTemplate.renderString({
      'models': models,
      'repositories': repositories,
      'services': services,
      'blocs': blocs,
      'views': views,
      'metas': metas,
    });

    File('${moduleDir.path}/$moduleName.dart').writeAsStringSync(indexContent);
    log.i('Generated index file for module: $moduleName');
  }

  await _writeGeneratedRoutes(Directory('../lib/routes'), generatedRoutes);
  log.i('✅ Generator finished successfully.');
}

Future<void> _generateFile(
  String type,
  Directory templatesDir,
  Directory targetDir,
  String name, {
  List<Map<String, dynamic>>? models,
  String? requestClass,
  String? responseClass,
  List<Map<String, dynamic>>? endpoints,
  Map<String, dynamic>? endpoint,
  Map<String, dynamic>? extra,
  String coreImport = '../../../core',
}) async {
  log.i('Generating $type for $name');

  final templateFile = File('${templatesDir.path}/$type.mustache');
  if (!templateFile.existsSync()) {
    log.e('Template not found: ${templateFile.path}');
    return;
  }

  final template = Template(await templateFile.readAsString(), name: type);
  final content = template.renderString({
    'module': _toSnakeCase(name),
    'Module': _toUpperCamel(name),
    'models': models ?? [],
    'RequestClass': requestClass ?? 'Request',
    'ResponseClass': responseClass ?? 'Response',
    'endpoints': endpoints ?? [],
    'endpoint': endpoint ?? {},
    'coreImport': coreImport,
    ...?extra,
  });

  final fileName = _toSnakeCase(name) + '_' + type + '.dart';
  final outputFile = File('${targetDir.path}/$fileName');
  outputFile.writeAsStringSync(content);

  log.i('Generated file: ${outputFile.path}');
}

String _moduleRoutePath(String relativeParent, String moduleName) {
  final folders = relativeParent
      .split(RegExp(r'[/\\]+'))
      .where((folder) => folder.isNotEmpty)
      .toList();
  if (folders.isNotEmpty && folders.first == 'cpanel') folders.removeAt(0);
  if (folders.isEmpty) return '/cpanel/modules/$moduleName';
  return '/cpanel/${[...folders, moduleName].join('/')}';
}

Future<void> _writeGeneratedRoutes(
  Directory routesDir,
  List<Map<String, dynamic>> modules,
) async {
  final lines = <String>[
    "import '../core/navigation/app_route_definition.dart';",
  ];
  for (final module in modules) {
    final alias = module['alias'] as String;
    for (final key in [
      'pageImport',
      'detailImport',
      'formImport',
      'deleteImport',
    ]) {
      final enabled = switch (key) {
        'pageImport' => module['hasListPage'] == true,
        'detailImport' => module['hasDetailPage'] == true,
        'formImport' => module['hasFormPage'] == true,
        'deleteImport' => module['hasDeletePage'] == true,
        _ => false,
      };
      if (enabled) lines.add("import '${module[key]}' as $alias;");
    }
  }
  lines.add('');
  lines.add(
    'final List<AppRouteDefinition> generatedModuleRoutes = <AppRouteDefinition>[',
  );
  for (final module in modules) {
    final alias = module['alias'] as String;
    final base = module['basePath'] as String;
    if (module['hasListPage'] == true) {
      lines.add(
        '  AppRouteDefinition(path: \'$base\', builder: (_) => const $alias.${module['pageClass']}()),',
      );
    }
    if (module['hasDetailPage'] == true) {
      final params = (module['detailParams'] as List).cast<Map>();
      final path = _routePath(base, params);
      final args = _routeArguments(params);
      lines.add(
        '  AppRouteDefinition(path: \'$path\', builder: (parameters) => $alias.${module['detailPageClass']}($args)),',
      );
    }
    if (module['hasFormPage'] == true) {
      lines.add(
        '  AppRouteDefinition(path: \'$base/new\', builder: (_) => const $alias.${module['formPageClass']}()),',
      );
      final params = (module['updateParams'] as List).cast<Map>();
      if (params.isNotEmpty) {
        final path = _routePath(base, params, suffix: '/edit');
        final args = _routeArguments(params);
        lines.add(
          '  AppRouteDefinition(path: \'$path\', builder: (parameters) => $alias.${module['formPageClass']}($args)),',
        );
      }
    }
    if (module['hasDeletePage'] == true) {
      final params = (module['deleteParams'] as List).cast<Map>();
      final path = _routePath(base, params, suffix: '/delete');
      final args = _routeArguments(params);
      lines.add(
        '  AppRouteDefinition(path: \'$path\', builder: (parameters) => $alias.${module['deletePageClass']}($args)),',
      );
    }
  }
  lines.add('];');
  routesDir.createSync(recursive: true);
  File(
    '${routesDir.path}/generated_module_routes.dart',
  ).writeAsStringSync(lines.join('\n') + '\n');
}

String _routePath(String base, List<Map> params, {String suffix = ''}) {
  final segments = params.map((param) => ':${param['name']}').join('/');
  return '$base${segments.isEmpty ? '' : '/$segments'}$suffix';
}

String _itemRouteExpression(
  String base,
  List<Map> params, {
  String suffix = '',
}) {
  final segments = params
      .map((param) => r'${item.' + param['name'].toString() + '}')
      .join('/');
  return "'$base/$segments$suffix'";
}

String? _itemRouteGuard(Map<String, dynamic> endpoint) {
  final params = (endpoint['pathParams'] as List? ?? const []).cast<Map>();
  if (params.isEmpty) return null;
  final field = params.first['name'];
  return 'item.$field == null';
}

String _routeArguments(List<Map> params) => params
    .map((param) => '${param['name']}: ${_routeParameterExpression(param)}')
    .join(', ');

String _routeParameterExpression(Map param) {
  final name = param['name'];
  final value = "parameters['$name']!";
  switch (param['datatype']) {
    case 'int':
      return 'int.parse($value)';
    case 'double':
      return 'double.parse($value)';
    case 'bool':
      return '$value == \'true\'';
    default:
      return value;
  }
}

String _appDynamicFieldType(String entityFieldType) {
  switch (entityFieldType) {
    case 'email':
      return 'email';
    case 'password':
      return 'password';
    case 'number':
      return 'number';
    case 'textarea':
      return 'multiline';
    default:
      return 'text';
  }
}

List<Map<String, dynamic>> _withLastFlag(List<Map<String, dynamic>> params) => [
  for (var i = 0; i < params.length; i++)
    {...params[i], 'last': i == params.length - 1},
];

String _widgetCallArguments(
  Map<String, dynamic> endpoint, {
  bool assertWidgetParamsNonNull = false,
}) {
  if (endpoint.isEmpty) return '';
  final args = <String>[];
  for (final param in (endpoint['pathParams'] as List? ?? const [])) {
    args.add('widget.${param['name']}${assertWidgetParamsNonNull ? '!' : ''}');
  }
  if (endpoint['hasRequestBody'] == true) args.add('request');
  for (final _ in (endpoint['queryParams'] as List? ?? const [])) {
    args.add('null');
  }
  return args.join(', ');
}

bool _isSensitiveField(String propName) {
  final lower = propName.toLowerCase();
  return lower.contains('password') ||
      lower.contains('token') ||
      lower.contains('secret');
}

String _entityFieldType(String propName, Map propSchema, String baseType) {
  final lower = propName.toLowerCase();
  final format = propSchema['format'] as String?;
  final maxLength = propSchema['maxLength'];

  if (lower.contains('password')) return 'password';
  if (lower.contains('email')) return 'email';
  if (lower.contains('phone')) return 'phone';
  if (baseType == 'bool') return 'boolean';
  if (format == 'data-type' || format == 'date' || lower.contains('date')) {
    return 'date';
  }
  if (baseType == 'int' || baseType == 'double') return 'number';
  if (maxLength is int && maxLength > 100) return 'textarea';
  return 'text';
}

String _toLabel(String propName) {
  final words = propName.split(RegExp(r'[_\s]+')).where((w) => w.isNotEmpty);
  return words
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join();
}

String _mapType(String? openapiType) {
  switch (openapiType) {
    case 'string':
      return 'String';
    case 'integer':
      return 'int';
    case 'boolean':
      return 'bool';
    case 'number':
      return 'double';
    default:
      return 'dynamic';
  }
}

String _toSnakeCase(String input) {
  return input
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toLowerCase();
}

String _toUpperCamel(String input) {
  // Normalize: replace non-alphanumeric with underscores
  final normalized = input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  // Split into parts
  final parts = normalized.split('_').where((p) => p.isNotEmpty).toList();

  // Capitalize only the first letter of each part, keep the rest as-is
  return parts.map((p) {
    return p[0].toUpperCase() + p.substring(1);
  }).join();
}

String? _extractRefClass(dynamic schema) {
  if (schema is Map && schema[r'\$ref'] is String) {
    final ref = schema[r'\$ref'] as String;
    return ref.split('/').last;
  }
  if (schema is Map && schema['items'] is Map) {
    return _extractRefClass(schema['items']);
  }
  return null;
}

String _toLowerCamelCase(String input) {
  final normalized = input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  final parts = normalized.split('_').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  final first = parts.first.toLowerCase();
  final rest = parts.skip(1).map((p) {
    final lower = p.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }).join();
  return first + rest;
}

String _dartPathExpression(String path) {
  final escaped = path.replaceAll("'", "\\'");
  final expression = escaped.replaceAllMapped(RegExp(r'(?<!\$)\{([^}]+)\}'), (
    match,
  ) {
    final rawPlaceholder = match.group(1)!.trim();
    final replacement =
        RegExp(r'^[a-zA-Z_\$][a-zA-Z0-9_\$]*$').hasMatch(rawPlaceholder)
        ? _toLowerCamelCase(rawPlaceholder)
        : rawPlaceholder;
    return r'${' + replacement + r'}';
  });
  return "'$expression'";
}
