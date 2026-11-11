class MetadataApi {
  final ApiOperation? list;
  final ApiOperation? create;
  final ApiOperation? detail;
  final ApiOperation? update;
  final ApiOperation? delete;
  final Map<String, dynamic> extra;

  const MetadataApi({
    this.list,
    this.create,
    this.detail,
    this.update,
    this.delete,
    this.extra = const {},
  });

  factory MetadataApi.fromJson(Map<String, dynamic> json) {
    const known = {'list', 'create', 'detail', 'update', 'delete'};

    ApiOperation? operation(String key) {
      final value = json[key];

      if (value is! Map) return null;

      return ApiOperation.fromJson(Map<String, dynamic>.from(value));
    }

    return MetadataApi(
      list: operation('list'),
      create: operation('create'),
      detail: operation('detail'),
      update: operation('update'),
      delete: operation('delete'),
      extra: Map<String, dynamic>.fromEntries(
        json.entries.where((entry) => !known.contains(entry.key)),
      ),
    );
  }

  MetadataApi copyWith({
    ApiOperation? list,
    ApiOperation? create,
    ApiOperation? detail,
    ApiOperation? update,
    ApiOperation? delete,
    Map<String, dynamic>? extra,
  }) {
    return MetadataApi(
      list: list ?? this.list,
      create: create ?? this.create,
      detail: detail ?? this.detail,
      update: update ?? this.update,
      delete: delete ?? this.delete,
      extra: extra ?? this.extra,
    );
  }

  Map<String, dynamic> toJson() => {
    ...extra,
    if (list != null) 'list': list!.toJson(),
    if (create != null) 'create': create!.toJson(),
    if (detail != null) 'detail': detail!.toJson(),
    if (update != null) 'update': update!.toJson(),
    if (delete != null) 'delete': delete!.toJson(),
  };

  factory MetadataApi.empty({required String entity}) {
    return MetadataApi(
      list: ApiOperation.empty(path: '/$entity'),
      create: ApiOperation.empty(path: '/$entity'),
      detail: ApiOperation.empty(path: '/$entity/:id'),
      update: ApiOperation.empty(path: '/$entity/:id'),
      delete: ApiOperation.empty(path: '/$entity/:id'),
    );
  }
}

class ApiOperation {
  final String? path;
  final bool enabled;
  final String? permission;
  final Map<String, dynamic> extra;

  const ApiOperation({
    this.path,
    this.enabled = true,
    this.permission,
    this.extra = const {},
  });

  ApiOperation copyWith({
    String? path,
    bool? enabled,
    String? permission,
    Map<String, dynamic>? extra,
  }) {
    return ApiOperation(
      path: path ?? this.path,
      enabled: enabled ?? this.enabled,
      permission: permission ?? this.permission,
      extra: extra ?? this.extra,
    );
  }

  factory ApiOperation.fromJson(Map<String, dynamic> json) {
    const known = {'path', 'enabled', 'permission'};

    return ApiOperation(
      path: json['path']?.toString(),
      enabled: json['enabled'] != false,
      permission: json['permission']?.toString(),
      extra: Map<String, dynamic>.fromEntries(
        json.entries.where((entry) => !known.contains(entry.key)),
      ),
    );
  }

  factory ApiOperation.empty({
    required String path,
    bool enabled = true,
    String? permission,
  }) {
    return ApiOperation(path: path, enabled: enabled, permission: permission);
  }

  Map<String, dynamic> toJson() => {
    ...extra,
    if (path != null) 'path': path,
    'enabled': enabled,
    if (permission != null) 'permission': permission,
  };
}
