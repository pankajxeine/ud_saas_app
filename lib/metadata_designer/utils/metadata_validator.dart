import 'package:ud_sass_app/metadata_designer/metadata_designer.dart';

class MetadataValidator {
  static List<String> validate(MetadataSchema? metadata) {
    final errors = <String>[];

    if (metadata == null) {
      errors.add('Metadata is null.');
      return errors;
    }
    final entity = metadata.entity;
    if (entity == null || entity.toString().trim().isEmpty) {
      errors.add('Entity is required.');
    }

    final table = metadata.table;
    if (table == null || table.toString().trim().isEmpty) {
      errors.add('Database table is required.');
    }

    final fields = metadata.fields;

    if (fields.isEmpty) {
      errors.add('At least one field is required.');
      return errors;
    }

    final names = <String>{};

    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];

      if (field is! Map) {
        errors.add('Field at position ${i + 1} is invalid.');
        continue;
      }

      final name = field.name.toString().trim();

      if (name.isEmpty) {
        errors.add('Field at position ${i + 1} has no name.');
        continue;
      }

      if (!names.add(name)) {
        errors.add('Duplicate field name: $name.');
      }

      if ((field.label.toString().trim()).isEmpty) {
        errors.add('Field "$name" has no label.');
      }
    }

    final primaryKey = metadata.primaryKey?.toString();

    if (primaryKey != null && !names.contains(primaryKey)) {
      errors.add(
        'Primary key "$primaryKey" does not match any field in fields[].',
      );
    }

    return errors;
  }
}
