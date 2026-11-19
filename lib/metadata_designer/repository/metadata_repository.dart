import 'dart:convert';

import '../../../core/config/app_logger.dart';
import '../../../core/api/api.dart';
import '../../../core/models/api_operation_response.dart';
import '../models/metadata_module.dart';
import '../models/metadata_module_version.dart';
import '../models/metadata_schema.dart';
import '../utils/metadata_utils.dart';

abstract class MetadataRepository {
  Future<Map<String, dynamic>> load();
  Future<void> save(MetaModuleVersion metadata);
  Future<ApiOperationResponse<List<MetaModule>>> fetchAllMetadata();
  Future<ApiOperationResponse<MetaModuleVersion>> createMetadata(
    MetaModuleVersion metadata,
  );
  Future<ApiOperationResponse<MetaModule>> createModule({
    required MetaModule module,
    required MetadataSchema schema,
  });
  Future<ApiOperationResponse<MetaModule>> updateModule(MetaModule module);
  Future<ApiOperationResponse<MetaModuleVersion>> createModuleVersion(
    MetaModuleVersion metadata,
  );
  Future<ApiOperationResponse<MetaModuleVersion>> updateModuleVersion(
    MetaModuleVersion metadata,
  );
  Future<ApiOperationResponse<MetaModule>> fetchMetadataModuleById(
    String moduleId,
  );
  Future<ApiOperationResponse<MetaModuleVersion>>
  fetchMetadataModuleVersionById({
    required String moduleId,
    required String versionId,
  });
}

class LocalMetadataRepository implements MetadataRepository {
  MetaModuleVersion? _document;
  final RestApi api;
  final log = AppLogger.getLogger('AuthRepository');

  LocalMetadataRepository({
    required String baseUrl,
    Map<String, String> headers = const {},
    MetaModuleVersion? initialMetadata,
  }) : api = RestApi(baseUrl: baseUrl, defaultHeaders: headers) {
    _document = initialMetadata;
  }

  @override
  Future<Map<String, dynamic>> load() async {
    if (_document == null) {
      throw StateError('No metadata document has been loaded.');
    }

    return Map<String, dynamic>.from(jsonDecode(jsonEncode(_document)) as Map);
  }

  @override
  Future<void> save(MetaModuleVersion metadata) async {
    _document = deepCopyModel(metadata.toJson(), MetaModuleVersion.fromJson);
  }

  @override
  Future<ApiOperationResponse<List<MetaModule>>> fetchAllMetadata() async {
    try {
      const endpointPath = '/meta-module';

      log.info('Calling GET $endpointPath');

      final response = await api.requestWithResponse<dynamic>(
        endpointPath: endpointPath,
        method: 'GET',
      );

      log.info('Response from $endpointPath: ${response.data}');

      final success =
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      if (!success) {
        return ApiOperationResponse.error(
          'Request failed with status ${response.statusCode}',
        );
      }

      final data = ApiParser.parseList<MetaModule>(
        response.data,
        (json) => MetaModule.fromJson(Map<String, dynamic>.from(json)),
      );

      return ApiOperationResponse.success(
        data,
        message: 'Metadata fetched successfully',
      );
    } catch (e, stack) {
      log.error('Error in fetchAllMetadata: $e\n$stack');

      return ApiOperationResponse.error('Exception occurred: $e');
    }
  }

  // ----------------------------------------------------------
  // CREATE METADATA
  // POST /meta-module
  // ----------------------------------------------------------
  @override
  Future<ApiOperationResponse<MetaModuleVersion>> createMetadata(
    MetaModuleVersion metadata,
  ) async {
    try {
      const endpointPath = '/meta-module';

      log.info('Calling POST $endpointPath with metadata: $metadata');

      final response = await api.requestWithResponse<dynamic>(
        endpointPath: endpointPath,
        method: 'POST',
        body: metadata,
      );

      log.info('Response from $endpointPath: ${response.data}');

      final success =
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      if (!success) {
        return ApiOperationResponse.error(
          'Request failed with status ${response.statusCode}',
        );
      }

      final body = ApiParser.parseObject<MetaModuleVersion>(
        response.data,
        (json) => MetaModuleVersion.fromJson(Map<String, dynamic>.from(json)),
      );

      return ApiOperationResponse.success(
        body,
        message: 'Metadata created successfully',
      );
    } catch (e, stack) {
      log.error('Error in createMetadata: $e\n$stack');

      return ApiOperationResponse.error('Exception occurred: $e');
    }
  }

  @override
  Future<ApiOperationResponse<MetaModule>> createModule({
    required MetaModule module,
    required MetadataSchema schema,
  }) async {
    try {
      final response = await api.requestWithResponse<dynamic>(
        endpointPath: MetadataApiPaths.modules,
        method: 'POST',
        body: {
          'module_code': module.moduleCode,
          'module_name': module.moduleName,
          'api_base_path': module.apiBasePath,
          'icon': module.icon,
          'description': module.description,
          'schema_name': module.schemaName,
          'table_name': module.tableName,
          'is_active': module.isActive,
          'schema_json': schema.toJson(),
        },
      );

      final success = _isSuccess(response.statusCode);
      if (!success) {
        return ApiOperationResponse.error(
          'Request failed with status ${response.statusCode}',
        );
      }

      final body = ApiParser.parseObject<MetaModule>(
        response.data,
        (json) => MetaModule.fromJson(Map<String, dynamic>.from(json)),
      );
      return ApiOperationResponse.success(body, message: 'Module created');
    } catch (e, stack) {
      log.error('Error creating metadata module: $e\n$stack');
      return ApiOperationResponse.error('Exception occurred: $e');
    }
  }

  @override
  Future<ApiOperationResponse<MetaModule>> updateModule(
    MetaModule module,
  ) async {
    try {
      if (module.moduleId.isEmpty) {
        return ApiOperationResponse.error('Module id is required');
      }
      final response = await api.requestWithResponse<dynamic>(
        endpointPath: MetadataApiPaths.moduleById(module.moduleId),
        method: 'PUT',
        body: {
          'module_code': module.moduleCode,
          'module_name': module.moduleName,
          'api_base_path': module.apiBasePath,
          'icon': module.icon,
          'description': module.description,
          'schema_name': module.schemaName,
          'table_name': module.tableName,
          'is_active': module.isActive,
        },
      );
      if (!_isSuccess(response.statusCode)) {
        return ApiOperationResponse.error(
          'Request failed with status ${response.statusCode}',
        );
      }
      final body = ApiParser.parseObject<MetaModule>(
        response.data,
        (json) => MetaModule.fromJson(Map<String, dynamic>.from(json)),
      );
      return ApiOperationResponse.success(body, message: 'Module updated');
    } catch (e, stack) {
      log.error('Error updating metadata module: $e\n$stack');
      return ApiOperationResponse.error('Exception occurred: $e');
    }
  }

  @override
  Future<ApiOperationResponse<MetaModuleVersion>> createModuleVersion(
    MetaModuleVersion metadata,
  ) async {
    return _writeModuleVersion(metadata, method: 'POST');
  }

  @override
  Future<ApiOperationResponse<MetaModuleVersion>> updateModuleVersion(
    MetaModuleVersion metadata,
  ) async {
    if (metadata.moduleVersionId == null ||
        metadata.moduleVersionId!.isEmpty) {
      return ApiOperationResponse.error('Module version id is required');
    }
    return _writeModuleVersion(metadata, method: 'PUT');
  }

  Future<ApiOperationResponse<MetaModuleVersion>> _writeModuleVersion(
    MetaModuleVersion metadata, {
    required String method,
  }) async {
    try {
      final endpoint = metadata.moduleVersionId == null
          ? MetadataApiPaths.moduleVersions
          : MetadataApiPaths.versionById(metadata.moduleVersionId!);
      final response = await api.requestWithResponse<dynamic>(
        endpointPath: endpoint,
        method: method,
        body: {
          'module_id': metadata.moduleId,
          'version_no': metadata.versionNo,
          'schema_json': metadata.schemaJson.toJson(),
          'publication_status': metadata.publicationStatus,
          if (metadata.publishedAt != null)
            'published_at': metadata.publishedAt,
        },
      );
      if (!_isSuccess(response.statusCode)) {
        return ApiOperationResponse.error(
          'Request failed with status ${response.statusCode}',
        );
      }
      final body = ApiParser.parseObject<MetaModuleVersion>(
        response.data,
        (json) => MetaModuleVersion.fromJson(Map<String, dynamic>.from(json)),
      );
      return ApiOperationResponse.success(body, message: 'Module version saved');
    } catch (e, stack) {
      log.error('Error saving metadata module version: $e\n$stack');
      return ApiOperationResponse.error('Exception occurred: $e');
    }
  }

  bool _isSuccess(int? statusCode) =>
      statusCode != null && statusCode >= 200 && statusCode < 300;

  @override
  Future<ApiOperationResponse<MetaModule>> fetchMetadataModuleById(
    String moduleId,
  ) async {
    try {
      log.info("enter fetchMetadataModuleById param , ModuleId $moduleId");
      final endpointPath = MetadataApiPaths.moduleById(moduleId);

      log.info('Calling GET $endpointPath');

      final response = await api.requestWithResponse<dynamic>(
        endpointPath: endpointPath,
        method: 'GET',
      );

      log.info('Response from $endpointPath: ${response.data}');

      final success =
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      if (!success) {
        return ApiOperationResponse.error(
          'Request failed with status ${response.statusCode}',
        );
      }

      // final data = ApiParser.parseList<MetaModule>(
      //   response.data,
      //   (json) => MetaModule.fromJson(Map<String, dynamic>.from(json)),
      // );

      final module = ApiParser.parseObject<MetaModule>(
        response.data,
        (json) => MetaModule.fromJson(Map<String, dynamic>.from(json)),
      );

      return ApiOperationResponse.success(
        module,
        message: 'Metadata fetched successfully',
      );
    } catch (e, stack) {
      log.error('Error in fetchMetadataModuleById: $e\n$stack');

      return ApiOperationResponse.error('Exception occurred: $e');
    }
  }

  @override
  Future<ApiOperationResponse<MetaModuleVersion>>
  fetchMetadataModuleVersionById({
    required String moduleId,
    required String versionId,
  }) async {
    try {
      final endpointPath = MetadataApiPaths.versionById(versionId);

      log.info('Calling GET $endpointPath');

      final response = await api.requestWithResponse<dynamic>(
        endpointPath: endpointPath,
        method: 'GET',
      );

      log.info('Response from $endpointPath: ${response.data}');

      final success =
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      if (!success) {
        return ApiOperationResponse.error(
          'Request failed with status ${response.statusCode}',
        );
      }

      final version = ApiParser.parseObject<MetaModuleVersion>(
        response.data,
        (json) => MetaModuleVersion.fromJson(Map<String, dynamic>.from(json)),
      );

      return ApiOperationResponse.success(
        version,
        message: 'Metadata module version fetched successfully',
      );
    } catch (e, stack) {
      log.error(
        'Error in fetchMetadataModuleVersion('
        '$moduleId, $versionId): $e\n$stack',
      );

      return ApiOperationResponse.error('Exception occurred: $e');
    }
  }
}

// class MetadataRepository {
//   // Keep your existing constructor and RestApi dependency.
//   // Example:
//   // MetadataRepository({required this.restApi});
//   // final RestApi restApi;

//   Future<List<MetaModule>> getModules() async {
//     final response = await restApi.requestWithResponse<dynamic>(
//       endpointPath: MetadataApiPaths.modules,
//       method: 'GET',
//     );

//     final payload = _unwrapResponse(response.data);

//     if (payload is! List) {
//       throw const FormatException('Invalid metadata modules response.');
//     }

//     return payload
//         .whereType<Map<String, dynamic>>()
//         .map(MetaModule.fromJson)
//         .toList();
//   }

//   Future<MetaModule> getModuleById(String moduleId) async {
//     final response = await restApi.requestWithResponse<dynamic>(
//       endpointPath: MetadataApiPaths.moduleById(moduleId),
//       method: 'GET',
//     );

//     final payload = _unwrapResponse(response.data);

//     if (payload is! Map<String, dynamic>) {
//       throw const FormatException('Invalid metadata module response.');
//     }

//     return MetaModule.fromJson(payload);
//   }

//   Future<MetaModuleVersion> getVersionById({
//     required String moduleId,
//     required String versionId,
//   }) async {
//     final response = await restApi.requestWithResponse<dynamic>(
//       endpointPath: MetadataApiPaths.versionById(moduleId, versionId),
//       method: 'GET',
//     );

//     final payload = _unwrapResponse(response.data);

//     if (payload is! Map<String, dynamic>) {
//       throw const FormatException('Invalid metadata version response.');
//     }

//     return MetaModuleVersion.fromJson(payload);
//   }

//   dynamic _unwrapResponse(dynamic value) {
//     if (value is Map<String, dynamic>) {
//       // Supports { data: ... } and { body: ... } API envelopes.
//       if (value.containsKey('data')) return value['data'];
//       if (value.containsKey('body')) return value['body'];
//     }

//     return value;
//   }
// }

class MetadataApiPaths {
  MetadataApiPaths._();

  static const modules = '/meta-module';
  static const moduleVersions = '/meta-module-version';

  static String moduleById(String moduleId) =>
      '/meta-module/${Uri.encodeComponent(moduleId)}';

  static String versionById(String versionId) =>
      '/meta-module-version/${Uri.encodeComponent(versionId)}';
}
