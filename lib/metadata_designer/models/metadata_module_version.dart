import 'package:equatable/equatable.dart';
import 'metadata_schema.dart';

class MetaModuleVersion extends Equatable {
  final String? moduleVersionId;
  final String? moduleId;
  final int versionNo;
  final MetadataSchema schemaJson;
  final String publicationStatus;
  final String? publishedAt;
  final String? draftAt;
  final Map<String, dynamic> metaModule;
  const MetaModuleVersion({
    this.moduleVersionId,
    this.moduleId,
    this.draftAt,
    this.publishedAt,
    required this.versionNo,
    required this.schemaJson,
    required this.publicationStatus,
    this.metaModule = const {},
  });

  factory MetaModuleVersion.fromJson(Map<String, dynamic> json) {
    final versionNo = json['versionNo'] ?? json['version_no'];

    return MetaModuleVersion(
      moduleVersionId: (json['moduleVersionId'] ?? json['module_version_id'])
          ?.toString(),
      moduleId: (json['moduleId'] ?? json['module_id'])?.toString(),
      versionNo: versionNo is num
          ? versionNo.toInt()
          : int.tryParse(versionNo?.toString() ?? '') ?? 1,
      schemaJson: MetadataSchema.fromJson(
        Map<String, dynamic>.from(
          json['schemaJson'] ?? json['schema_json'] ?? {},
        ),
      ),
      publicationStatus:
          (json['publicationStatus'] ?? json['publication_status'] ?? 'draft')
              .toString(),
      publishedAt: (json['publishedAt'] ?? json['publishedAt'])?.toString(),
      draftAt: (json['updatedAt'] ?? json['updatedAt'])?.toString(),
      metaModule: _map(json['meta_module']),
    );
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is! Map) return {};

    return Map<String, dynamic>.from(value);
  }

  factory MetaModuleVersion.empty({
    String? moduleId,
    required String entity,
    int versionNo = 1,
    String? moduleVersionId,
  }) {
    return MetaModuleVersion(
      moduleVersionId: moduleVersionId,
      moduleId: moduleId,
      versionNo: versionNo,
      schemaJson: MetadataSchema.empty(entity: entity),
      publicationStatus: 'draft',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleVersionId': moduleVersionId,
      'moduleId': moduleId,
      'versionNo': versionNo,
      'schemaJson': schemaJson.toJson(),
      'publicationStatus': publicationStatus,
    };
  }

  MetaModuleVersion copyWith({
    String? moduleVersionId,
    String? moduleId,
    int? versionNo,
    MetadataSchema? schemaJson,
  }) {
    return MetaModuleVersion(
      moduleVersionId: moduleVersionId ?? this.moduleVersionId,
      moduleId: moduleId ?? this.moduleId,
      versionNo: versionNo ?? this.versionNo,
      schemaJson: schemaJson ?? this.schemaJson,
      publicationStatus: publicationStatus,
    );
  }

  @override
  List<Object?> get props => [
    moduleVersionId,
    moduleId,
    versionNo,
    schemaJson,
    publicationStatus,
    publishedAt,
    draftAt,
  ];
}
