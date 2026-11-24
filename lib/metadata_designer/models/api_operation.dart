/// A configurable API operation and its catalog definition.
///
/// Catalog properties:
/// - value
/// - label
/// - pathPattern
/// - description
///
/// Metadata properties:
/// - operation
/// - path
/// - method
/// - enabled
/// - permission
/// - extra
class ApiOperationOption {
  // ------------------------------------------------------------
  // Catalog properties
  // ------------------------------------------------------------

  final String? label;
  final String? pathPattern;
  final String? description;

  // ------------------------------------------------------------
  // Metadata properties
  // ------------------------------------------------------------

  final String? operation;
  final String? path;
  final String? method;
  final bool enabled;
  final String? permission;
  final Map<String, dynamic> extra;

  const ApiOperationOption({
    this.label,
    this.pathPattern,
    this.description,
    this.operation,
    this.path,
    this.method,
    this.enabled = true,
    this.permission,
    this.extra = const {},
  });

  /// Alias used by the operation catalog.
  String? get value => operation;

  /// Returns the effective HTTP method.
  ///
  /// Uses the configured method first, then falls back to
  /// the standard method associated with the operation.
  String? get effectiveMethod {
    final configuredMethod = method?.trim();

    if (configuredMethod != null && configuredMethod.isNotEmpty) {
      return configuredMethod.toUpperCase();
    }

    switch (operation?.toLowerCase()) {
      case 'list':
      case 'detail':
      case 'search':
      case 'count':
      case 'export':
        return 'GET';

      case 'create':
      case 'bulk_create':
      case 'import':
      case 'approve':
      case 'reject':
      case 'submit':
      case 'cancel':
        return 'POST';

      case 'update':
      case 'bulk_update':
        return 'PUT';

      case 'patch':
      case 'activate':
      case 'deactivate':
      case 'archive':
      case 'restore':
        return 'PATCH';

      case 'delete':
      case 'bulk_delete':
        return 'DELETE';

      default:
        return null;
    }
  }

  /// Build an endpoint path for a particular entity.
  ///
  /// Example:
  /// pathPattern: '/{entity}/{entity_id}'
  /// entity: 'contact'
  /// result: '/contact/{contact_id}'
  String buildPath(String entity) {
    final pattern = pathPattern;

    if (pattern == null || pattern.isEmpty) {
      return path ?? '';
    }

    return pattern
        .replaceAll('{entity}', entity)
        .replaceAll('{entity_id}', '{${entity}_id}');
  }

  /// Create an operation from JSON metadata.
  factory ApiOperationOption.fromJson(Map<String, dynamic> json) {
    const known = {'operation', 'path', 'method', 'enabled', 'permission'};

    return ApiOperationOption(
      operation: json['operation']?.toString(),
      path: json['path']?.toString(),
      method: json['method']?.toString(),
      enabled: json['enabled'] != false,
      permission: json['permission']?.toString(),
      extra: Map<String, dynamic>.fromEntries(
        json.entries.where((entry) => !known.contains(entry.key)),
      ),
    );
  }

  /// Create a configured operation.
  factory ApiOperationOption.empty({
    required String operation,
    required String path,
    String? method,
    bool enabled = true,
    String? permission,
  }) {
    return ApiOperationOption(
      operation: operation,
      path: path,
      method: method,
      enabled: enabled,
      permission: permission,
    );
  }

  /// Create a configured operation using a catalog definition.
  factory ApiOperationOption.fromCatalog({
    required ApiOperationOption option,
    required String entity,
    bool enabled = true,
  }) {
    final operation = option.operation ?? '';

    return ApiOperationOption(
      operation: operation,
      path: option.buildPath(entity),
      method: option.method,
      enabled: enabled,
      permission: '$entity.operation.$operation',
      label: option.label,
      pathPattern: option.pathPattern,
      description: option.description,
    );
  }

  ApiOperationOption copyWith({
    String? label,
    String? pathPattern,
    String? description,
    String? operation,
    String? path,
    String? method,
    bool? enabled,
    String? permission,
    Map<String, dynamic>? extra,
  }) {
    return ApiOperationOption(
      label: label ?? this.label,
      pathPattern: pathPattern ?? this.pathPattern,
      description: description ?? this.description,
      operation: operation ?? this.operation,
      path: path ?? this.path,
      method: method ?? this.method,
      enabled: enabled ?? this.enabled,
      permission: permission ?? this.permission,
      extra: extra ?? this.extra,
    );
  }

  /// Serialize only metadata properties.
  ///
  /// Catalog-only properties are intentionally excluded.
  Map<String, dynamic> toJson() {
    return {
      ...extra,
      if (path != null) 'path': path,
      if (method != null) 'method': method!.toUpperCase(),
      'enabled': enabled,
      if (operation != null) 'operation': operation,
      if (permission != null) 'permission': permission,
    };
  }
}

/// Centralized API operation catalog.
class ApiOperationOptions {
  ApiOperationOptions._();

  // ------------------------------------------------------------
  // CRUD
  // ------------------------------------------------------------

  static const list = ApiOperationOption(
    operation: 'list',
    label: 'List',
    method: 'GET',
    pathPattern: '/{entity}',
    description: 'Fetch records with pagination, sorting and filters.',
  );

  static const create = ApiOperationOption(
    operation: 'create',
    label: 'Create',
    method: 'POST',
    pathPattern: '/{entity}',
    description: 'Create a new record.',
  );

  static const detail = ApiOperationOption(
    operation: 'detail',
    label: 'Detail',
    method: 'GET',
    pathPattern: '/{entity}/{entity_id}',
    description: 'Fetch a single record by ID.',
  );

  static const update = ApiOperationOption(
    operation: 'update',
    label: 'Update',
    method: 'PUT',
    pathPattern: '/{entity}/{entity_id}',
    description: 'Update an existing record.',
  );

  static const patch = ApiOperationOption(
    operation: 'patch',
    label: 'Partial Update',
    method: 'PATCH',
    pathPattern: '/{entity}/{entity_id}',
    description: 'Update selected fields of a record.',
  );

  static const delete = ApiOperationOption(
    operation: 'delete',
    label: 'Delete',
    method: 'DELETE',
    pathPattern: '/{entity}/{entity_id}',
    description: 'Delete a record by ID.',
  );

  // ------------------------------------------------------------
  // BULK
  // ------------------------------------------------------------

  static const bulkCreate = ApiOperationOption(
    operation: 'bulk_create',
    label: 'Bulk Create',
    method: 'POST',
    pathPattern: '/{entity}/bulk',
    description: 'Create multiple records.',
  );

  static const bulkUpdate = ApiOperationOption(
    operation: 'bulk_update',
    label: 'Bulk Update',
    method: 'PUT',
    pathPattern: '/{entity}/bulk',
    description: 'Update multiple records.',
  );

  static const bulkDelete = ApiOperationOption(
    operation: 'bulk_delete',
    label: 'Bulk Delete',
    method: 'DELETE',
    pathPattern: '/{entity}/bulk',
    description: 'Delete multiple records.',
  );

  // ------------------------------------------------------------
  // SEARCH AND DATA
  // ------------------------------------------------------------

  static const search = ApiOperationOption(
    operation: 'search',
    label: 'Search',
    method: 'GET',
    pathPattern: '/{entity}/search',
    description: 'Search records.',
  );

  static const count = ApiOperationOption(
    operation: 'count',
    label: 'Count',
    method: 'GET',
    pathPattern: '/{entity}/count',
    description: 'Count matching records.',
  );

  static const export = ApiOperationOption(
    operation: 'export',
    label: 'Export',
    method: 'GET',
    pathPattern: '/{entity}/export',
    description: 'Export records.',
  );

  static const import = ApiOperationOption(
    operation: 'import',
    label: 'Import',
    method: 'POST',
    pathPattern: '/{entity}/import',
    description: 'Import records.',
  );

  // ------------------------------------------------------------
  // WORKFLOW
  // ------------------------------------------------------------

  static const approve = ApiOperationOption(
    operation: 'approve',
    label: 'Approve',
    method: 'POST',
    pathPattern: '/{entity}/{entity_id}/approve',
    description: 'Approve a record or workflow.',
  );

  static const reject = ApiOperationOption(
    operation: 'reject',
    label: 'Reject',
    method: 'POST',
    pathPattern: '/{entity}/{entity_id}/reject',
    description: 'Reject a record or workflow.',
  );

  static const submit = ApiOperationOption(
    operation: 'submit',
    label: 'Submit',
    method: 'POST',
    pathPattern: '/{entity}/{entity_id}/submit',
    description: 'Submit a record for processing.',
  );

  static const cancel = ApiOperationOption(
    operation: 'cancel',
    label: 'Cancel',
    method: 'POST',
    pathPattern: '/{entity}/{entity_id}/cancel',
    description: 'Cancel a record or process.',
  );

  // ------------------------------------------------------------
  // STATUS
  // ------------------------------------------------------------

  static const activate = ApiOperationOption(
    operation: 'activate',
    label: 'Activate',
    method: 'PATCH',
    pathPattern: '/{entity}/{entity_id}/activate',
    description: 'Activate a record.',
  );

  static const deactivate = ApiOperationOption(
    operation: 'deactivate',
    label: 'Deactivate',
    method: 'PATCH',
    pathPattern: '/{entity}/{entity_id}/deactivate',
    description: 'Deactivate a record.',
  );

  static const archive = ApiOperationOption(
    operation: 'archive',
    label: 'Archive',
    method: 'PATCH',
    pathPattern: '/{entity}/{entity_id}/archive',
    description: 'Archive a record.',
  );

  static const restore = ApiOperationOption(
    operation: 'restore',
    label: 'Restore',
    method: 'PATCH',
    pathPattern: '/{entity}/{entity_id}/restore',
    description: 'Restore an archived record.',
  );

  // ------------------------------------------------------------
  // CATALOG GROUPS
  // ------------------------------------------------------------

  static const List<ApiOperationOption> crud = [
    list,
    create,
    detail,
    update,
    patch,
    delete,
  ];

  static const List<ApiOperationOption> bulk = [
    bulkCreate,
    bulkUpdate,
    bulkDelete,
  ];

  static const List<ApiOperationOption> data = [search, count, export, import];

  static const List<ApiOperationOption> workflow = [
    approve,
    reject,
    submit,
    cancel,
  ];

  static const List<ApiOperationOption> status = [
    activate,
    deactivate,
    archive,
    restore,
  ];

  static const List<ApiOperationOption> all = [
    ...crud,
    ...bulk,
    ...data,
    ...workflow,
    ...status,
  ];

  /// Default operations generated for a new entity.
  static const List<ApiOperationOption> defaults = [
    list,
    create,
    detail,
    update,
    delete,
  ];

  static ApiOperationOption? getByValue(String value) {
    for (final option in all) {
      if (option.operation == value) {
        return option;
      }
    }

    return null;
  }

  static List<ApiOperationOption> getByGroup(String group) {
    switch (group) {
      case 'crud':
        return crud;
      case 'bulk':
        return bulk;
      case 'data':
        return data;
      case 'workflow':
        return workflow;
      case 'status':
        return status;
      default:
        return all;
    }
  }
}
