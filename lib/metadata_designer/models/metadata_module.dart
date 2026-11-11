import 'package:equatable/equatable.dart';
import 'metadata_module_version.dart';
import 'metadata_schema.dart';

class MetaModule extends Equatable {
  final String moduleId;
  final String moduleCode;
  final String moduleName;
  final String apiBasePath;
  final String? icon;
  final String? description;
  final String schemaName;
  final String tableName;
  final int currentVersion;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<MetaModuleVersion> metaModuleVersions;

  const MetaModule({
    required this.moduleId,
    required this.moduleCode,
    required this.moduleName,
    required this.apiBasePath,
    this.icon,
    this.description,
    required this.schemaName,
    required this.tableName,
    required this.currentVersion,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.metaModuleVersions = const [],
  });

  factory MetaModule.fromJson(Map<String, dynamic> json) {
    final versions =
        json['meta_module_version'] ??
        json['metaModuleVersion'] ??
        json['meta_module_versions'] ??
        const <dynamic>[];
    final currentVersion = json['current_version'] ?? json['currentVersion'];
    final versionList = versions is List ? versions : const <dynamic>[];

    return MetaModule(
      moduleId: (json['module_id'] ?? json['moduleId'] ?? '').toString(),
      moduleCode: (json['module_code'] ?? json['moduleCode'] ?? '').toString(),
      moduleName: (json['module_name'] ?? json['moduleName'] ?? '').toString(),
      apiBasePath: (json['api_base_path'] ?? json['apiBasePath'] ?? '')
          .toString(),
      icon: json['icon'],
      description: json['description'],
      schemaName: (json['schema_name'] ?? json['schemaName'] ?? '').toString(),
      tableName: (json['table_name'] ?? json['tableName'] ?? '').toString(),
      currentVersion: currentVersion is num
          ? currentVersion.toInt()
          : int.tryParse(currentVersion?.toString() ?? '') ?? 0,
      isActive: json['is_active'] ?? json['isActive'] ?? false,
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.tryParse(
              (json['created_at'] ?? json['createdAt']).toString(),
            )
          : null,
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.tryParse(
              (json['updated_at'] ?? json['updatedAt']).toString(),
            )
          : null,
      metaModuleVersions: versionList
          .map(
            (item) =>
                MetaModuleVersion.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  factory MetaModule.empty({
    String? moduleCode,
    String? moduleName,
    String? schemaName,
    String? moduleId,
    String? apiBasePath,
    String? icon,
    String? description,
    String? tableName,
    bool isActive = true,
  }) {
    final resolvedTableName = tableName ?? 'new_module';

    final resolvedModuleId = moduleId ?? '';

    return MetaModule(
      moduleId: resolvedModuleId,
      moduleCode: moduleCode ?? 'new_module',
      moduleName: moduleName ?? "new module",
      apiBasePath: apiBasePath ?? '/${moduleCode ?? 'new_module'}',
      icon: icon ?? 'box',
      description: description,
      schemaName: schemaName ?? "new schema",
      tableName: resolvedTableName,
      currentVersion: 0,
      isActive: isActive,
      metaModuleVersions: const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module_id': moduleId,
      'module_code': moduleCode,
      'module_name': moduleName,
      'api_base_path': apiBasePath,
      'icon': icon,
      'description': description,
      'schema_name': schemaName,
      'table_name': tableName,
      'current_version': currentVersion,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'meta_module_version': metaModuleVersions
          .map((item) => item.toJson())
          .toList(),
    };
  }

  /// Returns the version matching currentVersion.
  MetaModuleVersion? get activeVersion {
    for (final version in metaModuleVersions) {
      if (version.versionNo == currentVersion) {
        return version;
      }
    }
    return null;
  }

  /// Convenient access to the current metadata schema.
  MetadataSchema? get currentSchema => activeVersion?.schemaJson;

  @override
  List<Object?> get props => [
    moduleId,
    moduleCode,
    moduleName,
    apiBasePath,
    icon,
    description,
    schemaName,
    tableName,
    currentVersion,
    isActive,
    createdAt,
    updatedAt,
    metaModuleVersions,
  ];
}
