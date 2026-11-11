import 'package:equatable/equatable.dart';

import '../models/metadata_module.dart';
import '../models/metadata_module_version.dart';

/// Base event for all metadata designer operations.
abstract class MetadataEvent extends Equatable {
  const MetadataEvent();

  @override
  List<Object?> get props => [];
}

// -----------------------------------------------------------------------------
// Metadata loading and lifecycle
// -----------------------------------------------------------------------------

class LoadMetadata extends MetadataEvent {
  final MetaModule metadata;

  const LoadMetadata({required this.metadata});

  @override
  List<Object?> get props => [metadata];
}

class ReplaceMetadata extends MetadataEvent {
  final MetaModuleVersion metadata;

  const ReplaceMetadata(this.metadata);

  @override
  List<Object?> get props => [metadata];
}

class ResetMetadata extends MetadataEvent {
  const ResetMetadata();
}

class ValidateMetadata extends MetadataEvent {
  const ValidateMetadata();
}

class SaveMetadata extends MetadataEvent {
  const SaveMetadata();
}

class PublishMetadata extends MetadataEvent {
  const PublishMetadata();
}

// -----------------------------------------------------------------------------
// Root metadata properties
// -----------------------------------------------------------------------------

class UpdateRootProperty extends MetadataEvent {
  final String key;
  final dynamic value;

  const UpdateRootProperty(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

class UpdateRootProperties extends MetadataEvent {
  final Map<String, dynamic> properties;

  const UpdateRootProperties(this.properties);

  @override
  List<Object?> get props => [properties];
}

// -----------------------------------------------------------------------------
// Field selection and CRUD
// -----------------------------------------------------------------------------

class SelectMetadataField extends MetadataEvent {
  final String? fieldName;

  const SelectMetadataField(this.fieldName);

  @override
  List<Object?> get props => [fieldName];
}

class AddMetadataField extends MetadataEvent {
  final int? index;

  const AddMetadataField({this.index});

  @override
  List<Object?> get props => [index];
}

class UpdateMetadataField extends MetadataEvent {
  final String fieldName;
  final Map<String, dynamic> updates;

  const UpdateMetadataField({required this.fieldName, required this.updates});

  @override
  List<Object?> get props => [fieldName, updates];
}

class UpdateFieldProperty extends MetadataEvent {
  final String fieldName;
  final String property;
  final dynamic value;

  const UpdateFieldProperty(this.fieldName, this.property, this.value);

  @override
  List<Object?> get props => [fieldName, property, value];
}

class DeleteMetadataField extends MetadataEvent {
  final String fieldName;

  const DeleteMetadataField(this.fieldName);

  @override
  List<Object?> get props => [fieldName];
}

class DuplicateMetadataField extends MetadataEvent {
  final String fieldName;

  const DuplicateMetadataField(this.fieldName);

  @override
  List<Object?> get props => [fieldName];
}

class ReorderMetadataFields extends MetadataEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderMetadataFields({required this.oldIndex, required this.newIndex});

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

// -----------------------------------------------------------------------------
// Field validations
// -----------------------------------------------------------------------------

class UpdateFieldValidations extends MetadataEvent {
  final String fieldName;
  final Map<String, dynamic> validations;

  const UpdateFieldValidations({
    required this.fieldName,
    required this.validations,
  });

  @override
  List<Object?> get props => [fieldName, validations];
}

class AddFieldValidation extends MetadataEvent {
  final String fieldName;
  final String validationName;
  final dynamic value;

  const AddFieldValidation({
    required this.fieldName,
    required this.validationName,
    required this.value,
  });

  @override
  List<Object?> get props => [fieldName, validationName, value];
}

class RemoveFieldValidation extends MetadataEvent {
  final String fieldName;
  final String validationName;

  const RemoveFieldValidation({
    required this.fieldName,
    required this.validationName,
  });

  @override
  List<Object?> get props => [fieldName, validationName];
}

// -----------------------------------------------------------------------------
// Field permissions
// -----------------------------------------------------------------------------

class UpdateFieldPermissions extends MetadataEvent {
  final String fieldName;
  final Map<String, dynamic> permissions;

  const UpdateFieldPermissions({
    required this.fieldName,
    required this.permissions,
  });

  @override
  List<Object?> get props => [fieldName, permissions];
}

// -----------------------------------------------------------------------------
// Field reference and lookup
// -----------------------------------------------------------------------------

class UpdateFieldReference extends MetadataEvent {
  final String fieldName;
  final Map<String, dynamic>? reference;

  const UpdateFieldReference({required this.fieldName, this.reference});

  @override
  List<Object?> get props => [fieldName, reference];
}

class UpdateFieldLookup extends MetadataEvent {
  final String fieldName;
  final Map<String, dynamic>? lookup;

  const UpdateFieldLookup({required this.fieldName, this.lookup});

  @override
  List<Object?> get props => [fieldName, lookup];
}

// -----------------------------------------------------------------------------
// API configuration
// -----------------------------------------------------------------------------

class UpdateApiOperation extends MetadataEvent {
  final String operation;
  final Map<String, dynamic> configuration;

  const UpdateApiOperation({
    required this.operation,
    required this.configuration,
  });

  @override
  List<Object?> get props => [operation, configuration];
}

class UpdateApiOperationProperty extends MetadataEvent {
  final String operation;
  final String property;
  final dynamic value;

  const UpdateApiOperationProperty({
    required this.operation,
    required this.property,
    required this.value,
  });

  @override
  List<Object?> get props => [operation, property, value];
}

// -----------------------------------------------------------------------------
// Grid and sorting
// -----------------------------------------------------------------------------

class UpdateGridProperty extends MetadataEvent {
  final String property;
  final dynamic value;

  const UpdateGridProperty(this.property, this.value);

  @override
  List<Object?> get props => [property, value];
}

class UpdateDefaultSort extends MetadataEvent {
  final String field;
  final String direction;

  const UpdateDefaultSort({required this.field, required this.direction});

  @override
  List<Object?> get props => [field, direction];
}

// -----------------------------------------------------------------------------
// Search and filters
// -----------------------------------------------------------------------------

class UpdateSearchProperty extends MetadataEvent {
  final String property;
  final dynamic value;

  const UpdateSearchProperty(this.property, this.value);

  @override
  List<Object?> get props => [property, value];
}

class UpdateQuickSearch extends MetadataEvent {
  final List<String> fields;

  const UpdateQuickSearch(this.fields);

  @override
  List<Object?> get props => [fields];
}

class AddSearchFilter extends MetadataEvent {
  final Map<String, dynamic> filter;

  const AddSearchFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class UpdateSearchFilter extends MetadataEvent {
  final String fieldName;
  final Map<String, dynamic> updates;

  const UpdateSearchFilter({required this.fieldName, required this.updates});

  @override
  List<Object?> get props => [fieldName, updates];
}

class RemoveSearchFilter extends MetadataEvent {
  final String fieldName;

  const RemoveSearchFilter(this.fieldName);

  @override
  List<Object?> get props => [fieldName];
}

// -----------------------------------------------------------------------------
// Datatable columns
// -----------------------------------------------------------------------------

class AddDatatableColumn extends MetadataEvent {
  final Map<String, dynamic> column;

  const AddDatatableColumn(this.column);

  @override
  List<Object?> get props => [column];
}

class UpdateDatatableColumn extends MetadataEvent {
  final String fieldName;
  final Map<String, dynamic> updates;

  const UpdateDatatableColumn({required this.fieldName, required this.updates});

  @override
  List<Object?> get props => [fieldName, updates];
}

class RemoveDatatableColumn extends MetadataEvent {
  final String fieldName;

  const RemoveDatatableColumn(this.fieldName);

  @override
  List<Object?> get props => [fieldName];
}

class ReorderDatatableColumns extends MetadataEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderDatatableColumns({
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

// -----------------------------------------------------------------------------
// Detail view fields
// -----------------------------------------------------------------------------

class AddDetailField extends MetadataEvent {
  final String fieldName;

  const AddDetailField(this.fieldName);

  @override
  List<Object?> get props => [fieldName];
}

class RemoveDetailField extends MetadataEvent {
  final String fieldName;

  const RemoveDetailField(this.fieldName);

  @override
  List<Object?> get props => [fieldName];
}

class ReorderDetailFields extends MetadataEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderDetailFields({required this.oldIndex, required this.newIndex});

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

// -----------------------------------------------------------------------------
// Designer UI state
// -----------------------------------------------------------------------------

class ChangeMetadataSection extends MetadataEvent {
  final String section;

  const ChangeMetadataSection(this.section);

  @override
  List<Object?> get props => [section];
}

class SetMetadataJsonMode extends MetadataEvent {
  final bool enabled;

  const SetMetadataJsonMode(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

// -----------------------------------------------------------------------------
// Designer navigation and selection
// -----------------------------------------------------------------------------

class SelectSection extends MetadataEvent {
  final String section;

  const SelectSection(this.section);

  @override
  List<Object?> get props => [section];
}

class SelectField extends MetadataEvent {
  final String? fieldName;

  const SelectField(this.fieldName);

  @override
  List<Object?> get props => [fieldName];
}

// -----------------------------------------------------------------------------
// Metadata save status
// -----------------------------------------------------------------------------

class MarkMetadataSaved extends MetadataEvent {
  const MarkMetadataSaved();
}

class LoadMetadataModules extends MetadataEvent {
  final bool forceRefresh;

  const LoadMetadataModules({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class LoadMetadataModuleById extends MetadataEvent {
  final bool forceRefresh;
  final String moduleId;

  const LoadMetadataModuleById({
    this.forceRefresh = false,
    required this.moduleId,
  });

  @override
  List<Object?> get props => [forceRefresh];
}

class LoadMetadataModuleVersionById extends MetadataEvent {
  final String moduleId;
  final String versionId;

  const LoadMetadataModuleVersionById({
    required this.moduleId,
    required this.versionId,
  });

  @override
  List<Object?> get props => [moduleId, versionId];
}

/// CREATE NEW MODULE
/// ------------------------------------------------------------
class CreateNewModule extends MetadataEvent {
  const CreateNewModule();
}

class SelectEntityMetadata extends MetadataEvent {
  final MetaModule module;

  const SelectEntityMetadata(this.module);

  @override
  List<Object?> get props => [module];
}

class InitializeSelectedMetadata extends MetadataEvent {
  const InitializeSelectedMetadata();
}

class BackToEntitySelection extends MetadataEvent {
  const BackToEntitySelection();
}

/// Select an existing metadata version for editing.
class SelectModuleVersionMetadata extends MetadataEvent {
  final MetaModule module;
  final MetaModuleVersion version;

  const SelectModuleVersionMetadata({
    required this.module,
    required this.version,
  });

  @override
  List<Object?> get props => [module, version];
}

/// Create a new metadata version from the current module schema.
class CreateNewModuleVersionMetadata extends MetadataEvent {
  final MetaModuleVersion module;

  const CreateNewModuleVersionMetadata({required this.module});

  @override
  List<Object?> get props => [module];
}
