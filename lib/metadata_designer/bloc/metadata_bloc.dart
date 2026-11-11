import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/app_logger.dart';
import 'metadata_event.dart';
import 'metadata_state.dart';
import '../utils/metadata_utils.dart';
import '../repository/metadata_repository.dart';
import '../utils/metadata_validator.dart';
import '../models/metadata_module.dart';
import '../models/metadata_module_version.dart';

class MetadataBloc extends Bloc<MetadataEvent, MetadataState> {
  final MetadataRepository repository;
  final log = AppLogger.getLogger('AuthLoginBloc');
  MetadataBloc({required this.repository}) : super(const MetadataState()) {
    on<LoadMetadata>(_onLoad);
    on<SelectSection>(_onSelectSection);
    on<SelectField>(_onSelectField);
    on<UpdateRootProperty>(_onUpdateRootProperty);
    on<UpdateFieldProperty>(_onUpdateFieldProperty);
    on<AddMetadataField>(_onAddField);
    on<DeleteMetadataField>(_onDeleteField);
    on<ReplaceMetadata>(_onReplaceMetadata);
    on<ValidateMetadata>(_onValidate);
    on<MarkMetadataSaved>(_onMarkSaved);

    // Modules
    on<LoadMetadataModules>(_onLoadMetadataModules);
    on<SelectEntityMetadata>(_onSelectEntityMetadata);
    on<InitializeSelectedMetadata>(_onInitializeSelectedMetadata);

    // Module
    on<LoadMetadataModuleById>(_onLoadMetadataModuleById);
    on<LoadMetadataModuleVersionById>(_onLoadMetadataModuleVersionById);

    on<BackToEntitySelection>(_onBackToEntitySelection);
    on<CreateNewModule>(_onCreateNewModule);
    on<SelectModuleVersionMetadata>(_onSelectModuleVersionMetadata);
    on<CreateNewModuleVersionMetadata>(_onCreateNewModuleVersionMetadata);
  }

  void _onLoad(LoadMetadata event, Emitter<MetadataState> emit) {
    emit(
      MetadataState(
        metadata: deepCopyModel(event.metadata, MetaModuleVersion.fromJson),
      ),
    );
  }

  void _onSelectSection(SelectSection event, Emitter<MetadataState> emit) {
    emit(
      state.copyWith(selectedSection: event.section, clearSelectedField: true),
    );
  }

  void _onSelectField(SelectField event, Emitter<MetadataState> emit) {
    emit(
      state.copyWith(
        selectedField: event.fieldName,
        clearSelectedField: event.fieldName == null,
      ),
    );
  }

  void _onUpdateRootProperty(
    UpdateRootProperty event,
    Emitter<MetadataState> emit,
  ) {
    final metadata = deepCopyModel(state.metadata, MetaModuleVersion.fromJson);
    //metadata[event.key] = event.value;

    emit(state.copyWith(metadata: metadata, isDirty: true, errors: []));
  }

  void _onUpdateFieldProperty(
    UpdateFieldProperty event,
    Emitter<MetadataState> emit,
  ) {
    final metadata = deepCopyModel(state.metadata, MetaModuleVersion.fromJson);

    final newFields = metadata.schemaJson.fields;
    final index = metadata.schemaJson.fields.indexWhere(
      (field) => field.name == event.fieldName,
    );

    if (index == -1) return;

    newFields[index] = newFields[index].copyWith(
      name: event.fieldName,
      label: event.value,
    );
    metadata.schemaJson.copyWith(fields: newFields);

    emit(
      state.copyWith(
        metadata: metadata.copyWith(
          schemaJson: metadata.schemaJson.copyWith(fields: newFields),
        ),
        isDirty: true,
        errors: [],
      ),
    );
  }

  void _onAddField(AddMetadataField event, Emitter<MetadataState> emit) {
    final metadata = deepCopyModel(state.metadata, MetaModuleVersion.fromJson);
    // final fields = List<Map<String, dynamic>>.from(
    //   (metadata['fields'] as List? ?? []).whereType<Map>().map(
    //     (field) => Map<String, dynamic>.from(field),
    //   ),
    // );

    var index = metadata.schemaJson.fields.length + 1;
    var name = 'new_field_$index';

    while (metadata.schemaJson.fields.any((field) => field.name == name)) {
      index++;
      name = 'new_field_$index';
    }

    // final field = MetadataField({
    //   'name': name,
    //   'label': 'New Field',
    //   'type': 'string',
    //   'widget': 'text',
    //   'showInTable': false,
    //   'showInDetail': true,
    //   'showInCreate': true,
    //   'showInUpdate': true,
    //   'requiredOnCreate': false,
    //   'requiredOnUpdate': false,
    //   'nullable': true,
    //   'readOnly': false,
    //   'writeOnly': false,
    //   'deprecated': false,
    //   'permissions': {'read': true, 'create': true, 'update': true},
    //   'validations': {},
    // });

    // metadata['fields'] = fields;

    emit(
      state.copyWith(
        metadata: metadata,
        selectedField: name,
        selectedSection: 'fields',
        isDirty: true,
        errors: [],
      ),
    );
  }

  void _onDeleteField(DeleteMetadataField event, Emitter<MetadataState> emit) {
    final metadata = deepCopyModel(state.metadata, MetaModuleVersion.fromJson);
    // final fields = getJsonMapList(metadata.toJson(), 'fields');
    final newSchema = metadata.schemaJson;
    newSchema.fields.removeWhere((field) => field.name == event.fieldName);
    final updatedSchema = newSchema.copyWith(fields: [...newSchema.fields]);
    final newMetaData = metadata.copyWith(schemaJson: updatedSchema);

    emit(
      state.copyWith(
        metadata: newMetaData,
        clearSelectedField: true,
        isDirty: true,
        errors: [],
      ),
    );
  }

  void _onReplaceMetadata(ReplaceMetadata event, Emitter<MetadataState> emit) {
    emit(
      state.copyWith(
        metadata: deepCopyModel(event.metadata, MetaModuleVersion.fromJson),
        isDirty: true,
        errors: [],
      ),
    );
  }

  void _onValidate(ValidateMetadata event, Emitter<MetadataState> emit) {
    emit(
      state.copyWith(
        errors: MetadataValidator.validate(state.metadata?.schemaJson),
      ),
    );
  }

  void _onMarkSaved(MarkMetadataSaved event, Emitter<MetadataState> emit) {
    emit(state.copyWith(isDirty: false));
  }

  Future<void> _onLoadMetadataModules(
    LoadMetadataModules event,
    Emitter<MetadataState> emit,
  ) async {
    log.info(' LoadMetadataModules  enter call -> _onLoadMetadataModules ');

    /// Already loaded → no API call.
    if (state.hasLoadedModules && !event.forceRefresh) {
      return;
    }

    /// Prevent duplicate API calls.
    if (state.isLoadingModules) {
      return;
    }
    emit(state.copyWith(isLoadingModules: true, loadError: null));

    try {
      final result = await repository.fetchAllMetadata();
      log.info(
        'LoadMetadataModules Rest call success repository.fetchAllMetadata',
      );

      emit(
        state.copyWith(
          allMetadata: result.body ?? [],
          isLoadingModules: false,
          selectedEntity: null,
          isEditorOpen: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingModules: false, loadError: e.toString()));
    }
  }

  Future<void> _onLoadMetadataModuleById(
    LoadMetadataModuleById event,
    Emitter<MetadataState> emit,
  ) async {
    log.info(' LoadMetadataModules  enter call -> _onLoadMetadataModuleById ');

    /// Already loaded → no API call.
    if (state.hasLoadedModules &&
        !event.forceRefresh &&
        event.moduleId.isEmpty) {
      return;
    }

    /// Prevent duplicate API calls.
    if (state.isLoadingModules) {
      return;
    }
    emit(state.copyWith(isLoadingModules: true, loadError: null));

    try {
      final result = await repository.fetchMetadataModuleById(event.moduleId);
      log.info(
        'LoadMetadataModules Rest call success repository.fetchMetadataModuleById',
      );

      emit(
        state.copyWith(
          module: result.body,
          isLoadingModules: false,
          selectedEntity: null,
          isEditorOpen: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingModules: false, loadError: e.toString()));
    }
  }

  Future<void> _onLoadMetadataModuleVersionById(
    LoadMetadataModuleVersionById event,
    Emitter<MetadataState> emit,
  ) async {
    log.info(
      ' LoadMetadataModules  enter call -> _onLoadMetadataModuleVersionById ',
    );

    /// Already loaded → no API call.
    if (state.hasLoadedModules &&
        event.moduleId.isEmpty &&
        event.versionId.isEmpty) {
      return;
    }

    /// Prevent duplicate API calls.
    if (state.isLoadingModules) {
      return;
    }
    emit(state.copyWith(isLoadingModules: true, loadError: null));

    try {
      final result = await repository.fetchMetadataModuleVersionById(
        moduleId: event.moduleId,
        versionId: event.versionId,
      );
      log.info(
        'LoadMetadataModules Rest call success repository.fetchAllMetadata',
      );

      emit(
        state.copyWith(
          metadata: result.body,
          isLoadingModules: false,
          selectedEntity: null,
          isEditorOpen: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingModules: false, loadError: e.toString()));
    }
  }

  /// ----------------------------------------------------------
  /// OPEN EXISTING MODULE
  /// ----------------------------------------------------------

  void _onSelectEntityMetadata(
    SelectEntityMetadata event,
    Emitter<MetadataState> emit,
  ) {
    final metadata = event.module;

    emit(
      state.copyWith(
        module: deepCopyModel(metadata, MetaModule.fromJson),
        isEditorOpen: true,
        isDirty: false,
        selectedSection: 'general',
        errors: const [],
        loadError: null,
      ),
    );
  }

  Future<void> _onInitializeSelectedMetadata(
    InitializeSelectedMetadata event,
    Emitter<MetadataState> emit,
  ) async {
    final entity = state.selectedEntity;

    if (entity == null) return;

    emit(state.copyWith(isCreatingMetadata: true, loadError: null));

    try {
      final defaultMetadata = MetaModuleVersion.empty(entity: entity);

      final savedMetadata = await repository.createMetadata(defaultMetadata);

      // final updatedModules = [...state.allMetadata, savedMetadata.body ?? {}];

      emit(
        state.copyWith(
          metadata: deepCopyModel(
            savedMetadata.body ?? {},
            MetaModuleVersion.fromJson,
          ),
          // allMetadata: updatedModules,
          isCreatingMetadata: false,
          isEditorOpen: true,
          isDirty: false,
          errors: [],
        ),
      );
    } catch (e) {
      emit(state.copyWith(isCreatingMetadata: false, loadError: e.toString()));
    }
  }

  /// ----------------------------------------------------------
  /// BACK TO MODULE LIST
  /// ----------------------------------------------------------

  void _onBackToEntitySelection(
    BackToEntitySelection event,
    Emitter<MetadataState> emit,
  ) {
    emit(
      state.copyWith(
        metadata: null,
        isEditorOpen: false,
        isDirty: false,
        selectedSection: 'general',
        errors: const [],
        clearSelectedField: true,
        loadError: null,
      ),
    );
  }

  // ----------------------------------------------------------
  // 5. DEFAULT METADATA FACTORY
  // ----------------------------------------------------------

  // MetaModuleVersion initializeMetadata(String entity) {
  //   final title = _toTitleCase(entity);

  //   return {
  //     'entity': entity,
  //     'title': title,
  //     'table': entity,
  //     'primaryKey': 'id',

  //     'api': {
  //       'list': {'path': '/$entity', 'enabled': false, 'permission': null},
  //       'create': {'path': '/$entity', 'enabled': false, 'permission': null},
  //       'detail': {
  //         'path': '/$entity/:id',
  //         'enabled': false,
  //         'permission': null,
  //       },
  //       'update': {
  //         'path': '/$entity/:id',
  //         'enabled': false,
  //         'permission': null,
  //       },
  //       'delete': {
  //         'path': '/$entity/:id',
  //         'enabled': false,
  //         'permission': null,
  //       },
  //     },

  //     'grid': {'pageSize': 20, 'defaultSort': {}},

  //     'search': {'quickSearch': [], 'filters': []},

  //     'datatable': {'columns': []},

  //     'detail': {'fields': []},

  //     'fields': [],
  //   };
  // }

  // ----------------------------------------------------------
  // HELPERS
  // ----------------------------------------------------------

  String _toTitleCase(String value) {
    return value
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  Future<void> _onCreateNewModule(
    CreateNewModule event,
    Emitter<MetadataState> emit,
  ) async {
    /// Check duplicate locally.
    // final module = state.allMetadata.any(
    //   (module) =>
    //       module['entity']?.toString().toLowerCase() == entity.toLowerCase(),
    // );

    // if (exists) {
    //   emit(state.copyWith(loadError: 'Module "$entity" already exists'));
    //   return;
    // }
    log.info("CreateNewModule Enter to function _onCreateNewModule");
    final module = MetaModule.empty();

    log.info("CreateNewModule default module $module");
    emit(
      state.copyWith(
        module: module,
        isEditorOpen: true,
        isCreatingMetadata: true,
        loadError: null,
      ),
    );

    try {
      // final defaultMetadata = event.module ?? MetaModuleVersion.empty(entity: "new module");

      // final result = await repository.createMetadata(module);

      // if (!result.status || result.body == null) {
      //   emit(
      //     state.copyWith(isCreatingMetadata: false, loadError: result.message),
      //   );
      //   return;
      // }

      // final createdMetadata = result.body!;

      // // final updatedModules = [...state.allMetadata, createdMetadata];

      // emit(
      //   state.copyWith(
      //     metadata: deepCopyModel(createdMetadata, MetaModuleVersion.fromJson),
      //     // allMetadata: updatedModules,
      //     selectedEntity: entity,
      //     hasLoadedModules: true,
      //     isCreatingMetadata: false,
      //     isEditorOpen: true,
      //     selectedSection: 'general',
      //     isDirty: false,
      //     errors: const [],
      //   ),
      // );
    } catch (e) {
      emit(state.copyWith(isCreatingMetadata: false, loadError: e.toString()));
    }
  }

  void _onSelectModuleVersionMetadata(
    SelectModuleVersionMetadata event,
    Emitter<MetadataState> emit,
  ) {
    final moduleVersion = event.version;
    //final schema = moduleVersion.schemaJson;

    emit(
      state.copyWith(
        selectedEntity: event.module.moduleCode,
        metadata: moduleVersion,
        isEditorOpen: true,
        isDirty: false,
        selectedSection: 'general',
        clearSelectedField: true,
        clearLoadError: true,
        errors: const [],
      ),
    );
  }

  void _onCreateNewModuleVersionMetadata(
    CreateNewModuleVersionMetadata event,
    Emitter<MetadataState> emit,
  ) {
    final module = event.module;

    emit(
      state.copyWith(
        metadata: module,
        isEditorOpen: true,
        isDirty: true,
        selectedSection: 'general',
        clearSelectedField: true,
        clearLoadError: true,
        errors: const [],
      ),
    );
  }

  String _normalizeEntity(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
}
