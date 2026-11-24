import 'package:equatable/equatable.dart';

/// Normalized column definition used by generated list pages.
class MetadataTableColumn extends Equatable {
  const MetadataTableColumn({
    required this.field,
    required this.label,
    required this.type,
    this.sortable = true,
    this.readOnly = true,
  });

  final String field;
  final String label;
  final String type;
  final bool sortable;
  final bool readOnly;

  @override
  List<Object?> get props => [field, label, type, sortable, readOnly];
}

/// Metadata-derived table model. Rows are copied snapshots and must not be
/// mutated by widgets.
class MetadataTableModel extends Equatable {
  const MetadataTableModel({required this.columns, required this.rows});

  final List<MetadataTableColumn> columns;
  final List<Map<String, dynamic>> rows;

  @override
  List<Object?> get props => [columns, rows];
}

/// Metadata-derived form model consumed by the existing reactive form layer.
class MetadataFormModel extends Equatable {
  const MetadataFormModel({required this.entityName, required this.json});

  final String entityName;
  final Map<String, dynamic> json;

  @override
  List<Object?> get props => [entityName, json];
}

/// Metadata-derived read-only view model.
class MetadataViewModel extends Equatable {
  const MetadataViewModel({required this.title, required this.fields});

  final String title;
  final List<MetadataViewField> fields;

  @override
  List<Object?> get props => [title, fields];
}

class MetadataViewField extends Equatable {
  const MetadataViewField({
    required this.field,
    required this.label,
    required this.type,
  });

  final String field;
  final String label;
  final String type;

  @override
  List<Object?> get props => [field, label, type];
}
