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

  return EntityMeta(
    entityName: json['entityName']?.toString() ?? 'Entity',
    fields: fields,
  );
}
