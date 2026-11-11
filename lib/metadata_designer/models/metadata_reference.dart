class MetadataReference {
  final String? table;
  final String? column;
  final MetadataLookup? lookup;
  final Map<String, dynamic> extra;

  const MetadataReference({
    this.table,
    this.column,
    this.lookup,
    this.extra = const {},
  });

  factory MetadataReference.fromJson(Map<String, dynamic> json) {
    const known = {'table', 'column', 'lookup'};

    return MetadataReference(
      table: json['table']?.toString(),
      column: json['column']?.toString(),
      lookup: json['lookup'] is Map
          ? MetadataLookup.fromJson(Map<String, dynamic>.from(json['lookup']))
          : null,
      extra: Map.fromEntries(
        json.entries.where((entry) => !known.contains(entry.key)),
      ),
    );
  }

  MetadataReference copyWith({
    String? table,
    String? column,
    MetadataLookup? lookup,
    Map<String, dynamic>? extra,
  }) {
    return MetadataReference(
      table: table ?? this.table,
      column: column ?? this.column,
      lookup: lookup ?? this.lookup,
      extra: extra ?? this.extra,
    );
  }

  Map<String, dynamic> toJson() => {
    ...extra,
    if (table != null) 'table': table,
    if (column != null) 'column': column,
    if (lookup != null) 'lookup': lookup!.toJson(),
  };
}

class MetadataLookup {
  final String? strategy;
  final String? endpoint;
  final String? displayField;
  final String? valueField;
  final Map<String, dynamic> extra;

  const MetadataLookup({
    this.strategy,
    this.endpoint,
    this.displayField,
    this.valueField,
    this.extra = const {},
  });

  factory MetadataLookup.fromJson(Map<String, dynamic> json) {
    const known = {'strategy', 'endpoint', 'displayField', 'valueField'};

    return MetadataLookup(
      strategy: json['strategy']?.toString(),
      endpoint: json['endpoint']?.toString(),
      displayField: json['displayField']?.toString(),
      valueField: json['valueField']?.toString(),
      extra: Map.fromEntries(
        json.entries.where((entry) => !known.contains(entry.key)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    ...extra,
    if (strategy != null) 'strategy': strategy,
    if (endpoint != null) 'endpoint': endpoint,
    if (displayField != null) 'displayField': displayField,
    if (valueField != null) 'valueField': valueField,
  };
}
