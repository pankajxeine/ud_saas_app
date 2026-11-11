enum MetadataRouteType {
  moduleList,
  createModule,
  moduleDetails,
  createVersion,
  versionDetails,
}

class MetadataRouteMatch {
  const MetadataRouteMatch({required this.type, this.moduleId, this.versionId});

  final MetadataRouteType type;
  final String? moduleId;
  final String? versionId;

  static MetadataRouteMatch? parse(Uri uri) {
    final segments = uri.pathSegments;

    // /metadata/modules
    if (segments.length == 2 &&
        segments[0] == 'metadata' &&
        segments[1] == 'modules') {
      return const MetadataRouteMatch(type: MetadataRouteType.moduleList);
    }

    // /metadata/modules/new
    if (segments.length == 3 &&
        segments[0] == 'metadata' &&
        segments[1] == 'modules' &&
        segments[2] == 'new') {
      return const MetadataRouteMatch(type: MetadataRouteType.createModule);
    }

    // /metadata/modules/:moduleId/versions/new
    if (segments.length == 5 &&
        segments[0] == 'metadata' &&
        segments[1] == 'modules' &&
        segments[3] == 'versions' &&
        segments[4] == 'new' &&
        segments[2].isNotEmpty) {
      return MetadataRouteMatch(
        type: MetadataRouteType.createVersion,
        moduleId: segments[2],
      );
    }

    // /metadata/modules/:moduleId/versions/:versionId
    if (segments.length == 5 &&
        segments[0] == 'metadata' &&
        segments[1] == 'modules' &&
        segments[3] == 'versions' &&
        segments[2].isNotEmpty &&
        segments[4].isNotEmpty) {
      return MetadataRouteMatch(
        type: MetadataRouteType.versionDetails,
        moduleId: segments[2],
        versionId: segments[4],
      );
    }

    // /metadata/modules/:moduleId
    if (segments.length == 3 &&
        segments[0] == 'metadata' &&
        segments[1] == 'modules' &&
        segments[2].isNotEmpty) {
      return MetadataRouteMatch(
        type: MetadataRouteType.moduleDetails,
        moduleId: segments[2],
      );
    }

    return null;
  }
}
