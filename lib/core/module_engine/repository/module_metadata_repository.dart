import 'dart:async';

import '../../../metadata_designer/models/metadata_module.dart';
import '../../../metadata_designer/repository/metadata_repository.dart';
import '../models/module_metadata.dart';

/// Tenant-aware in-memory metadata cache with in-flight request coalescing.
class ModuleMetadataCache {
  final Map<String, ModuleMetadata> _values = {};
  final Map<String, Future<ModuleMetadata>> _inFlight = {};

  ModuleMetadata? read({required String tenantId, required String moduleId}) {
    return _values[_key(tenantId, moduleId)];
  }

  Future<ModuleMetadata> getOrLoad({
    required String tenantId,
    required String moduleId,
    required Future<MetaModule> Function() loader,
  }) {
    final key = _key(tenantId, moduleId);
    final cached = _values[key];
    if (cached != null) return Future<ModuleMetadata>.value(cached);

    final pending = _inFlight[key];
    if (pending != null) return pending;

    final request = loader().then((module) {
      final metadata = ModuleMetadata.fromModule(
        tenantId: tenantId,
        module: module,
      );
      _values[key] = metadata;
      return metadata;
    });
    _inFlight[key] = request;
    return request.whenComplete(() => _inFlight.remove(key));
  }

  void invalidate({required String tenantId, required String moduleId}) {
    _values.remove(_key(tenantId, moduleId));
  }

  void clearTenant(String tenantId) {
    _values.removeWhere((key, _) => key.startsWith('$tenantId:'));
  }

  void clear() {
    _values.clear();
    _inFlight.clear();
  }

  String _key(String tenantId, String moduleId) => '$tenantId:$moduleId';
}

/// Reads published module metadata without coupling the CRUD engine to UI.
class ModuleMetadataRepository {
  const ModuleMetadataRepository({
    required this.source,
    required this.cache,
    required this.tenantId,
  });

  final MetadataRepository source;
  final ModuleMetadataCache cache;
  final String tenantId;

  Future<ModuleMetadata> get(String moduleId) {
    return cache.getOrLoad(
      tenantId: tenantId,
      moduleId: moduleId,
      loader: () async {
        final response = await source.fetchMetadataModuleById(moduleId);
        final module = response.body;
        if (!response.status || module == null) {
          throw StateError(response.message ?? 'Unable to load module metadata.');
        }
        return module;
      },
    );
  }

  void invalidate(String moduleId) {
    cache.invalidate(tenantId: tenantId, moduleId: moduleId);
  }
}
