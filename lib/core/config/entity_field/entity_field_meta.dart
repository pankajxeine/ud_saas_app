enum EntityFieldType {
  text,
  email,
  password,
  phone,
  number,
  currency,
  boolean,
  date,
  dataRange,
  select,
  mutiselect,
  textarea,
  slider
}

enum EntityMode { view, edit, create }

class EntityFieldOption {
  const EntityFieldOption({required this.value, required this.label});

  final dynamic value;
  final String label;
}

class EntityFieldMeta {
  const EntityFieldMeta({
    required this.name,
    required this.label,
    this.type = EntityFieldType.text,
    this.required = false,
    this.maxLength,
    this.editable = true,
    this.placeholder,
    this.group = '',
    this.columnSpan = 1,
    this.rowSpan = 1,
    this.options = const [],
    this.sensitive = false,
  });

  final String name;
  final String label;
  final EntityFieldType type;
  final bool required;
  final int? maxLength;
  final bool editable;
  final String? placeholder;
  final String group;
  final int columnSpan;
  final int rowSpan;
  final List<EntityFieldOption> options;
  final bool sensitive;

  bool visibleIn(EntityMode mode) {
    switch (mode) {
      case EntityMode.view:
        return !sensitive;
      case EntityMode.create:
      case EntityMode.edit:
        return editable;
    }
  }
}

class EntityMeta {
  const EntityMeta({
    required this.entityName,
    required this.fields,
  });

  final String entityName;
  final List<EntityFieldMeta> fields;

  // factory EntityMeta.fromJsonSchema(
  //   Map<String, dynamic> schema, {
  //   String? entityName,
  // }) {
  //   final requirdName = ((schema['required'] as List?) ?? const [])
  //       .map((value) => value.toString())
  //       .toSet();
  //   final properties = Map<String, dynamic>.from(
  //     (schema['properties'] as Map?) ?? const {},
  //   );

  //   return EntityMeta(
  //       entityName: entityName ?? schema['title']?.toString() ?? 'Entity',
  //       fields: properties.entries.map((entry) {
  //         final property = Map<String, dynamic>.from(entry.value as Map);
  //         final values = (property['enum'] as List?) ?? const [];
  //         final labels = (property['x-enum-labels'] as List?) ?? const [];
  //         return EntityFieldMeta(name: entry.key, label: label)
  //         });
  //   );
  // }

  List<EntityFieldMeta> fieldsFor(EntityMode mode) =>
      fields.where((f) => f.visibleIn(mode)).toList();

  List<MapEntry<String, String>> toDetailsEntries(Map<String, dynamic> values,
      {EntityMode mode = EntityMode.view}) {
    return fieldsFor(
      mode,
    ).map((f) => MapEntry(f.label, values[f.name]?.toString() ?? '_')).toList();
  }
}
