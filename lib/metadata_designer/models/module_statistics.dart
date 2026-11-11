import 'metadata_module.dart';

class ModuleStatistics {
  final int totalModules;
  final int publishedModules;
  final int draftModules;
  final int totalFields;

  const ModuleStatistics({
    required this.totalModules,
    required this.publishedModules,
    required this.draftModules,
    required this.totalFields,
  });

  factory ModuleStatistics.fromModules(List<MetaModule> modules) {
    int published = 0;
    int draft = 0;
    int fields = 0;

    for (final module in modules) {
      final moduleVersions = module.metaModuleVersions.last;
      final status = moduleVersions.publicationStatus.toString().toLowerCase();

      if (status == 'published') {
        published++;
      } else {
        draft++;
      }

      final moduleFields = moduleVersions.schemaJson.fields;

      fields = moduleFields.length + 1;
    }

    return ModuleStatistics(
      totalModules: modules.length,
      publishedModules: published,
      draftModules: draft,
      totalFields: fields,
    );
  }
}
