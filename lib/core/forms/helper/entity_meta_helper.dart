import 'field_meta_helper.dart';
import '../models/entity_meta.dart';

EntityMeta entityMetaFromJson(Map<String, dynamic> json) {
  final fieldsJson = json['fields'] as List<dynamic>? ?? [];

  final fields = fieldsJson.map((item) {
    if (item is! Map) {
      throw FormatException('Invalid field definition: $item');
    }

    return fieldMetaFromJson(Map<String, dynamic>.from(item));
  }).toList();

  final layout = json['layout'] is Map
      ? Map<String, dynamic>.from(json['layout'] as Map)
      : const <String, dynamic>{};

  // Support both the current nested layout shape and the legacy/root shape
  // used by metadata designer schemas (`formLayout` + `sections`).
  final formLayout = json.containsKey('formLayout')
      ? json['formLayout']
      : layout['mode'];
  final mode = switch (formLayout?.toString().toLowerCase()) {
    'tabs' => EntityFormLayoutMode.tabs,
    'stepper' => EntityFormLayoutMode.stepper,
    _ => EntityFormLayoutMode.basic,
  };
  final stepperOrientation = parseStepperOrientation(
    json['stepperOrientation'] ??
        layout['stepperOrientation'] ??
        layout['orientation'],
  );
  final sectionsJson = json['sections'] ?? layout['sections'];
  final sections = (sectionsJson as List? ?? const [])
      .whereType<Map>()
      .map((item) => EntityFormSection.fromJson(Map<String, dynamic>.from(item)))
      .toList();

  return EntityMeta(
    entityName: json['entityName']?.toString() ?? 'Entity',
    fields: fields,
    formLayout: mode,
    stepperOrientation: stepperOrientation,
    sections: sections,
  );
}
