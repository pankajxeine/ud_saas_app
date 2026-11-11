import 'package:equatable/equatable.dart';

import '../models/metadata_module.dart';
import '../models/metadata_module_version.dart';

class MetadataState extends Equatable {
  // Current editable metadata schema.
  final MetaModuleVersion? metadata;

  // Currently selected module version.
  final MetaModule? module;

  // Available modules.
  final List<MetaModule> allMetadata;

  // Selected module code.
  final String? selectedEntity;

  // Module loading and creation.
  final bool isLoadingModules;
  final bool isCreatingMetadata;
  final bool hasLoadedModules;

  // Editor visibility.
  final bool isEditorOpen;

  // Error and feedback.
  final String? loadError;

  // Designer UI state.
  final String selectedSection;
  final String? selectedField;

  // Editing and saving.
  final bool isDirty;
  final bool isSaving;

  // Validation errors.
  final List<String> errors;

  // String selectedDesignerTab;

  const MetadataState({
    this.metadata,
    this.module,
    this.allMetadata = const [],
    this.selectedEntity,
    this.isLoadingModules = false,
    this.isCreatingMetadata = false,
    this.hasLoadedModules = false,
    this.isEditorOpen = false,
    this.loadError,
    this.selectedSection = 'general',
    this.selectedField,
    this.isDirty = false,
    this.isSaving = false,
    this.errors = const [],
  });

  /// Initial state: no module selected and no editor open.
  factory MetadataState.initial() {
    return const MetadataState();
  }

  MetadataState copyWith({
    MetaModuleVersion? metadata,
    MetaModule? module,
    List<MetaModule>? allMetadata,
    String? selectedEntity,
    bool? isLoadingModules,
    bool? isCreatingMetadata,
    bool? hasLoadedModules,
    bool? isEditorOpen,
    String? loadError,
    String? selectedSection,
    String? selectedField,
    bool? isDirty,
    bool? isSaving,
    List<String>? errors,
    String selectedDesignerTab = 'general',

    // Explicit clearing options for nullable properties.
    bool clearMetadata = false,
    bool clearSelectedMetaVersion = false,
    bool clearSelectedEntity = false,
    bool clearLoadError = false,
    bool clearSelectedField = false,
  }) {
    return MetadataState(
      metadata: clearMetadata ? null : metadata ?? this.metadata,

      module: clearSelectedMetaVersion ? null : module ?? this.module,

      allMetadata: allMetadata ?? this.allMetadata,

      selectedEntity: clearSelectedEntity
          ? null
          : selectedEntity ?? this.selectedEntity,

      isLoadingModules: isLoadingModules ?? this.isLoadingModules,
      isCreatingMetadata: isCreatingMetadata ?? this.isCreatingMetadata,
      hasLoadedModules: hasLoadedModules ?? this.hasLoadedModules,
      isEditorOpen: isEditorOpen ?? this.isEditorOpen,

      loadError: clearLoadError ? null : loadError ?? this.loadError,

      selectedSection: selectedSection ?? this.selectedSection,

      selectedField: clearSelectedField
          ? null
          : selectedField ?? this.selectedField,

      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
    metadata,
    module,
    allMetadata,
    selectedEntity,
    isLoadingModules,
    isCreatingMetadata,
    hasLoadedModules,
    isEditorOpen,
    loadError,
    selectedSection,
    selectedField,
    isDirty,
    isSaving,
    errors,
  ];
}
