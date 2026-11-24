import '../../api/rest_api.dart';
import '../models/module_metadata.dart';

/// Paged server response used by generated list pages.
class ModulePageResult {
  const ModulePageResult({required this.items, required this.total});

  final List<Map<String, dynamic>> items;
  final int total;
}

abstract interface class ModuleRecordRepository {
  Future<ModulePageResult> list({
    required ModuleMetadata metadata,
    required int page,
    required int pageSize,
    String? search,
    Map<String, dynamic> filters,
  });

  Future<Map<String, dynamic>> detail({
    required ModuleMetadata metadata,
    required String id,
  });

  Future<Map<String, dynamic>> create({
    required ModuleMetadata metadata,
    required Map<String, dynamic> data,
  });

  Future<Map<String, dynamic>> update({
    required ModuleMetadata metadata,
    required String id,
    required Map<String, dynamic> data,
  });

  Future<void> delete({required ModuleMetadata metadata, required String id});
}

/// REST implementation that resolves operation paths from metadata.
/// Authorization remains server-enforced; tenantId is sent as an explicit
/// scope header in addition to the authenticated request context.
class RestModuleRecordRepository implements ModuleRecordRepository {
  RestModuleRecordRepository({required this.api, required this.tenantId});

  final RestApi api;
  final String tenantId;

  @override
  Future<ModulePageResult> list({
    required ModuleMetadata metadata,
    required int page,
    required int pageSize,
    String? search,
    Map<String, dynamic> filters = const {},
  }) async {
    final data = await _request(
      metadata,
      'list',
      query: {
        'page': page,
        'pageSize': pageSize,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        ...filters,
      },
    );
    final body = _body(data);
    final items = body is List
        ? body
        : body is Map
        ? (body['items'] ?? body['results'] ?? body['rows'] ?? const [])
        : const [];
    final records = items is List
        ? items
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList(growable: false)
        : const <Map<String, dynamic>>[];
    final total = body is Map
        ? int.tryParse('${body['total'] ?? body['count'] ?? records.length}') ??
            records.length
        : records.length;
    return ModulePageResult(items: records, total: total);
  }

  @override
  Future<Map<String, dynamic>> detail({
    required ModuleMetadata metadata,
    required String id,
  }) async => _map(await _request(metadata, 'detail', id: id));

  @override
  Future<Map<String, dynamic>> create({
    required ModuleMetadata metadata,
    required Map<String, dynamic> data,
  }) async => _map(await _request(metadata, 'create', body: data));

  @override
  Future<Map<String, dynamic>> update({
    required ModuleMetadata metadata,
    required String id,
    required Map<String, dynamic> data,
  }) async => _map(await _request(metadata, 'update', id: id, body: data));

  @override
  Future<void> delete({required ModuleMetadata metadata, required String id}) async {
    await _request(metadata, 'delete', id: id);
  }

  Future<dynamic> _request(
    ModuleMetadata metadata,
    String operation, {
    String? id,
    Map<String, dynamic>? query,
    dynamic body,
  }) async {
    final apiOperation = metadata.schema.api?.getOperation(operation);
    if (apiOperation == null || apiOperation.enabled != true) {
      throw StateError('Operation "$operation" is not enabled.');
    }
    var path = apiOperation.path;
    if (path == null || path.isEmpty) throw StateError('Missing API path for "$operation".');
    if (id != null) {
      final encoded = Uri.encodeComponent(id);
      path = path
          .replaceAll(':id', encoded)
          .replaceAll('{id}', encoded)
          .replaceAll(':${metadata.primaryKey}', encoded)
          .replaceAll('{${metadata.primaryKey}}', encoded);
    }
    final method = apiOperation.effectiveMethod ??
        (switch (operation) {
          'list' || 'detail' => 'GET',
          'create' => 'POST',
          'update' => 'PUT',
          'delete' => 'DELETE',
          _ => throw StateError('Unsupported operation "$operation".'),
        });
    final response = await api.requestWithResponse<dynamic>(
      endpointPath: path,
      method: method,
      queryParams: query,
      body: body,
      headers: {'x-tenant-id': tenantId},
    );
    final status = response.statusCode ?? 500;
    if (status < 200 || status >= 300) {
      throw StateError('Operation "$operation" failed with status $status.');
    }
    return response.data;
  }

  dynamic _body(dynamic value) {
    if (value is Map && value['data'] != null) return value['data'];
    if (value is Map && value['body'] != null) return value['body'];
    return value;
  }

  Map<String, dynamic> _map(dynamic value) {
    final body = _body(value);
    if (body is! Map) throw StateError('Expected an object response.');
    return Map<String, dynamic>.from(body);
  }
}
