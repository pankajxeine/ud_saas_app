import 'dart:convert';

import '../../../core/config/app_logger.dart';
import '../../../core/api/api.dart';
import '../../../core/models/api_operation_response.dart';
import '../models/metadata_module.dart';
import '../models/metadata_module_version.dart';
import '../utils/metadata_utils.dart';

abstract class MetadataRepository {
  Future<Map<String, dynamic>> load();
  Future<void> save(MetaModuleVersion metadata);
  Future<ApiOperationResponse<List<MetaModule>>> fetchAllMetadata();
  Future<ApiOperationResponse<MetaModuleVersion>> createMetadata(
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

  static String moduleById(String moduleId) =>
      '/meta-module/${Uri.encodeComponent(moduleId)}';

  static String versionById(String versionId) =>
      '/meta-module-version/${Uri.encodeComponent(versionId)}';
}
