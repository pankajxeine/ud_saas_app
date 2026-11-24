import 'package:equatable/equatable.dart';

import '../../../metadata_designer/models/metadata_module.dart';
import '../../../metadata_designer/models/metadata_schema.dart';

/// Immutable runtime snapshot of a published module definition.
///
/// The snapshot is created once from the API response and is passed to the
/// CRUD engine. UI code must treat it as read-only; metadata editing belongs to
/// the metadata-designer flow.
class ModuleMetadata extends Equatable {
  const ModuleMetadata({
    required this.tenantId,
    required this.moduleId,
    required this.version,
    required this.module,
    required this.schema,
  });

  factory ModuleMetadata.fromModule({
    required String tenantId,
    required MetaModule module,
  }) {
    final version = module.activeVersion;
    if (version == null) {
      throw StateError('Module "${module.moduleId}" has no published version.');
    }

    return ModuleMetadata(
      tenantId: tenantId,
      moduleId: module.moduleId,
      version: version.versionNo,
      module: module,
      schema: version.schemaJson,
    );
  }

  final String tenantId;
  final String moduleId;
  final int version;
  final MetaModule module;
  final MetadataSchema schema;

  String get title => schema.title ?? module.moduleName;

  String get primaryKey => schema.primaryKey ?? 'id';

  @override
  List<Object?> get props => [tenantId, moduleId, version, module, schema];
}
