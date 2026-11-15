class MetadataApi {
  final List<ApiOperation> operations;

  const MetadataApi({this.operations = const []});

  /// JSON array:
  ///
  /// [
  ///   {
  ///     "operation": "list",
  ///     "path": "/contact",
  ///     "enabled": true,
  ///     "permission": "crm_contact.operation.list"
  ///   }
  /// ]
  factory MetadataApi.fromJson(List<dynamic> json) {
    return MetadataApi(
      operations: json
          .whereType<Map>()
          .map((item) => ApiOperation.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  /// Returns the operation matching the supplied name.
  ApiOperation? getOperation(String operation) {
    for (final item in operations) {
      if (item.operation == operation) {
        return item;
      }
    }

    return null;
  }

  /// Add or replace an operation.
  MetadataApi updateOperation(ApiOperation operation) {
    final updated = [...operations];

    final index = updated.indexWhere(
      (item) => item.operation == operation.operation,
    );

    if (index >= 0) {
      updated[index] = operation;
    } else {
      updated.add(operation);
    }

    return copyWith(operations: updated);
  }

  /// Remove an operation.
  MetadataApi removeOperation(String operation) {
    return copyWith(
      operations: operations
          .where((item) => item.operation != operation)
          .toList(),
    );
  }

  MetadataApi copyWith({List<ApiOperation>? operations}) {
    return MetadataApi(operations: operations ?? this.operations);
  }

  /// Serialize directly to JSON array.
  List<Map<String, dynamic>> toJson() {
    return operations.map((item) => item.toJson()).toList();
  }

  /// Create default API operations for an entity.
  factory MetadataApi.empty({required String entity}) {
    return MetadataApi(
      operations: [
        ApiOperation.empty(
          operation: 'list',
          path: '/$entity',
          permission: '${entity}.operation.list',
        ),
        ApiOperation.empty(
          operation: 'create',
          path: '/$entity',
          permission: '${entity}.operation.create',
        ),
        ApiOperation.empty(
          operation: 'detail',
          path: '/$entity/{${entity}_id}',
          permission: '${entity}.operation.detail',
        ),
        ApiOperation.empty(
          operation: 'update',
          path: '/$entity/{${entity}_id}',
          permission: '${entity}.operation.update',
        ),
        ApiOperation.empty(
          operation: 'delete',
          path: '/$entity/{${entity}_id}',
          permission: '${entity}.operation.delete',
        ),
      ],
    );
  }
}

class ApiOperation {
  final String? operation;
  final String? path;
  final bool enabled;
  final String? permission;
  final Map<String, dynamic> extra;

  const ApiOperation({
    this.operation,
    this.path,
    this.enabled = true,
    this.permission,
    this.extra = const {},
  });

  factory ApiOperation.fromJson(Map<String, dynamic> json) {
    const known = {'operation', 'path', 'enabled', 'permission'};

    return ApiOperation(
      operation: json['operation']?.toString(),
      path: json['path']?.toString(),
      enabled: json['enabled'] != false,
      permission: json['permission']?.toString(),
      extra: Map<String, dynamic>.fromEntries(
        json.entries.where((entry) => !known.contains(entry.key)),
      ),
    );
  }

  factory ApiOperation.empty({
    required String operation,
    required String path,
    bool enabled = true,
    String? permission,
  }) {
    return ApiOperation(
      operation: operation,
      path: path,
      enabled: enabled,
      permission: permission,
    );
  }

  ApiOperation copyWith({
    String? operation,
    String? path,
    bool? enabled,
    String? permission,
    Map<String, dynamic>? extra,
  }) {
    return ApiOperation(
      operation: operation ?? this.operation,
      path: path ?? this.path,
      enabled: enabled ?? this.enabled,
      permission: permission ?? this.permission,
      extra: extra ?? this.extra,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...extra,
      if (operation != null) 'operation': operation,
      if (path != null) 'path': path,
      'enabled': enabled,
      if (permission != null) 'permission': permission,
    };
  }
}
