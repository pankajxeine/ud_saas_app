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
  final mode = switch (layout['mode']?.toString().toLowerCase()) {
    'tabs' => EntityFormLayoutMode.tabs,
    'stepper' => EntityFormLayoutMode.stepper,
    _ => EntityFormLayoutMode.basic,
  };
  final sections = (layout['sections'] as List? ?? const [])
      .whereType<Map>()
      .map(
        (item) => EntityFormSection(
          id: item['id']?.toString() ?? item['title']?.toString() ?? 'section',
          title: item['title']?.toString() ?? 'Section',
          fields: (item['fields'] as List? ?? const [])
              .map((field) => field.toString())
              .toList(),
        ),
      )
      .toList();

  return EntityMeta(
    entityName: json['entityName']?.toString() ?? 'Entity',
    fields: fields,
    formLayout: mode,
    sections: sections,
  );
}
