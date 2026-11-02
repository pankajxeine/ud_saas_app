enum MetaFieldType {
  string,
  text,
  integer,
  decimal,
  boolean,
  date,
  datetime,
  email,
  phone,
  reference,
  object,
  association,
  array,
}

enum MetaWidget {
  text,
  textarea,
  email,
  phone,
  number,
  currency,
  checkbox,
  switchWidget,
  select,
  multiSelect,
  lookup,
  badge,
  date,
  datetime,
  card,
}

class MetaSchema {
  final String entity;
  final String title;
  final List<MetaSection> sections;

  const MetaSchema({
    required this.entity,
    required this.title,
    required this.sections,
  });
}

class MetaSection {
  final String title;
  final List<MetaField> fields;

  const MetaSection({required this.title, required this.fields});
}

class MetaField {
  final String name;
  final String label;

  final MetaFieldType type;
  final MetaWidget widget;

  final bool readOnly;
  final bool required;

  final bool showInForm;
  final bool showInDetail;
  final bool showInList;

  final String? placeholder;

  final List<dynamic>? options;

  final MetaReference? reference;

  final List<MetaField>? fields;

  const MetaField({
    required this.name,
    required this.label,
    required this.type,
    required this.widget,
    this.readOnly = false,
    this.required = false,
    this.showInForm = true,
    this.showInDetail = true,
    this.showInList = false,
    this.placeholder,
    this.options,
    this.reference,
    this.fields,
  });
}

class MetaReference {
  final String schema;
  final String valueField;
  final String displayField;

  const MetaReference({
    required this.schema,
    required this.valueField,
    required this.displayField,
  });
}
