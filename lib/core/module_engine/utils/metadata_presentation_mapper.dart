import '../models/module_metadata.dart';
import '../models/presentation_models.dart';

/// Converts normalized module metadata into renderer-neutral presentation
/// models. It has no dependency on a module name or a concrete page widget.
class MetadataPresentationMapper {
  const MetadataPresentationMapper._();

  static MetadataTableModel table({
    required ModuleMetadata metadata,
    required List<Map<String, dynamic>> records,
  }) {
    final columns = metadata.schema.fields
        .where((field) => field.showInTable && !field.writeOnly)
        .map(
          (field) => MetadataTableColumn(
            field: field.name,
            label: field.label.isEmpty ? field.name : field.label,
            type: field.type,
            readOnly: field.readOnly,
          ),
        )
        .toList(growable: false);

    return MetadataTableModel(
      columns: List.unmodifiable(columns),
      rows: List.unmodifiable(
        records
            .map((record) => Map<String, dynamic>.unmodifiable(record))
            .toList(growable: false),
      ),
    );
  }

  static MetadataFormModel form(
    ModuleMetadata metadata, {
    bool edit = false,
  }) {
    final schema = metadata.schema.toJson();
    final fieldJson = (schema['fields'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map((json) {
          final name = json['name']?.toString();
          final field = metadata.schema.fields
              .where((item) => item.name == name)
              .firstOrNull;
          final validationRules = <String, dynamic>{
            if (json['validations'] is Map)
              ...Map<String, dynamic>.from(json['validations'] as Map),
          };
          final validation = json['validation'];
          if (validation is List) {
            for (final item in validation.whereType<Map>()) {
              final type = item['type']?.toString();
              if (type != null && item['value'] != null) {
                validationRules[type] = item['value'];
              }
            }
          }
          if ((edit && field?.requiredOnUpdate == true) ||
              (!edit && field?.requiredOnCreate == true)) {
            validationRules['required'] = true;
          }
          return {
            ...json,
            'type': switch (json['type']?.toString().toLowerCase()) {
              'uuid' => 'string',
              'datetime' || 'date-time' => 'date',
              final value => value ?? 'string',
            },
            'widget': switch (json['widget']?.toString().toLowerCase()) {
              'datetime' => 'date',
              final value => value,
            },
            'validations': validationRules,
          };
        })
        .toList(growable: false);
    return MetadataFormModel(
      entityName: metadata.schema.entity ?? metadata.module.moduleCode,
      json: Map<String, dynamic>.unmodifiable({
        'entityName': metadata.schema.entity ?? metadata.module.moduleCode,
        'formLayout': metadata.schema.extra['formLayout'],
        'sections': metadata.schema.sections
            .map((section) => section.toJson())
            .toList(growable: false),
        'fields': fieldJson,
      }),
    );
  }

  static MetadataViewModel view(ModuleMetadata metadata) {
    final fields = metadata.schema.fields
        .where((field) => field.showInDetail && !field.writeOnly)
        .map(
          (field) => MetadataViewField(
            field: field.name,
            label: field.label.isEmpty ? field.name : field.label,
            type: field.type,
          ),
        )
        .toList(growable: false);
    return MetadataViewModel(
      title: metadata.title,
      fields: List.unmodifiable(fields),
    );
  }
}
