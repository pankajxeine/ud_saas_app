class MetadataGrid {
  final int pageSize;
  final MetadataSort? defaultSort;
  final MetadataSelection selection;
  final Map<String, dynamic> extra;

  const MetadataGrid({
    this.pageSize = 20,
    this.defaultSort,
    this.selection = const MetadataSelection(),
    this.extra = const {},
  });

  MetadataGrid copyWith({
    int? pageSize,
    MetadataSort? defaultSort,
    MetadataSelection? selection,
    Map<String, dynamic>? extra,
  }) {
    return MetadataGrid(
      pageSize: pageSize ?? this.pageSize,
      defaultSort: defaultSort ?? this.defaultSort,
      selection: selection ?? this.selection,
      extra: extra ?? this.extra,
    );
  }

  factory MetadataGrid.fromJson(Map<String, dynamic> json) {
    const known = {'pageSize', 'defaultSort', 'selection'};

    final sort = json['defaultSort'];
    final selection = json['selection'];

    return MetadataGrid(
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      defaultSort: sort is Map
          ? MetadataSort.fromJson(Map<String, dynamic>.from(sort))
          : null,
      selection: selection is Map
          ? MetadataSelection.fromJson(Map<String, dynamic>.from(selection))
          : const MetadataSelection(),
      extra: Map<String, dynamic>.fromEntries(
        json.entries.where((entry) => !known.contains(entry.key)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    ...extra,
    'pageSize': pageSize,
    if (defaultSort != null) 'defaultSort': defaultSort!.toJson(),
    'selection': selection.toJson(),
  };

  factory MetadataGrid.empty() {
    return const MetadataGrid(
      pageSize: 20,
      defaultSort: MetadataSort(),
      selection: MetadataSelection(),
    );
  }
}

// ------------------------------------------------------------
// GRID SORT
// ------------------------------------------------------------

class MetadataSort {
  final List<String> fields;
  final String direction;
  final Map<String, dynamic> extra;

  const MetadataSort({
    this.fields = const [],
    this.direction = 'asc',
    this.extra = const {},
  });

  /// Backward-compatible access to the first sort field.
  String? get field => fields.isNotEmpty ? fields.first : null;

  factory MetadataSort.fromJson(Map<String, dynamic> json) {
    const known = {'field', 'fields', 'direction', 'order'};

    final rawFields = json['fields'];
    final rawField = json['field'];

    final fields = rawFields is List
        ? rawFields.map((value) => value.toString()).toList()
        : rawField != null
        ? [rawField.toString()]
        : <String>[];

    final direction = (json['direction'] ?? json['order'] ?? 'asc')
        .toString()
        .toLowerCase();

    return MetadataSort(
      fields: fields,
      direction: direction == 'desc' ? 'desc' : 'asc',
      extra: Map<String, dynamic>.fromEntries(
        json.entries.where((entry) => !known.contains(entry.key)),
      ),
    );
  }

  MetadataSort copyWith({
    List<String>? fields,
    String? direction,
    Map<String, dynamic>? extra,
  }) {
    return MetadataSort(
      fields: fields ?? this.fields,
      direction: direction ?? this.direction,
      extra: extra ?? this.extra,
    );
  }

  Map<String, dynamic> toJson() => {
    ...extra,
    if (fields.isNotEmpty) 'fields': fields,
    'direction': direction,
  };

  factory MetadataSort.empty() {
    return const MetadataSort();
  }
}

// ------------------------------------------------------------
// GRID SELECTION
// ------------------------------------------------------------

class MetadataSelection {
  /// Enable or disable row selection.
  final bool enabled;

  /// single or multiple
  final String mode;

  /// Display checkbox for each row.
  final bool showCheckbox;

  /// Display select-all checkbox in table header.
  final bool showSelectAll;

  /// Keep selected records when changing pages.
  final bool persistAcrossPages;

  /// Maximum number of selectable records.
  /// Null means unlimited.
  final int? maxSelection;

  final Map<String, dynamic> extra;

  const MetadataSelection({
    this.enabled = false,
    this.mode = 'multiple',
    this.showCheckbox = true,
    this.showSelectAll = true,
    this.persistAcrossPages = false,
    this.maxSelection,
    this.extra = const {},
  });

  bool get isSingle => mode == 'single';

  bool get isMultiple => mode == 'multiple';

  MetadataSelection copyWith({
    bool? enabled,
    String? mode,
    bool? showCheckbox,
    bool? showSelectAll,
    bool? persistAcrossPages,
    int? maxSelection,
    Map<String, dynamic>? extra,
  }) {
    return MetadataSelection(
      enabled: enabled ?? this.enabled,
      mode: mode ?? this.mode,
      showCheckbox: showCheckbox ?? this.showCheckbox,
      showSelectAll: showSelectAll ?? this.showSelectAll,
      persistAcrossPages: persistAcrossPages ?? this.persistAcrossPages,
      maxSelection: maxSelection ?? this.maxSelection,
      extra: extra ?? this.extra,
    );
  }

  factory MetadataSelection.fromJson(Map<String, dynamic> json) {
    const known = {
      'enabled',
      'mode',
      'showCheckbox',
      'showSelectAll',
      'persistAcrossPages',
      'maxSelection',
    };

    final mode = json['mode']?.toString().toLowerCase() ??
        (json['multiple'] == true ? 'multiple' : 'single');

    return MetadataSelection(
      enabled: json['enabled'] == true,
      mode: mode == 'single' ? 'single' : 'multiple',
      showCheckbox: json['showCheckbox'] != false,
      showSelectAll: json['showSelectAll'] != false,
      persistAcrossPages: json['persistAcrossPages'] == true,
      maxSelection: (json['maxSelection'] as num?)?.toInt(),
      extra: Map<String, dynamic>.fromEntries(
        json.entries.where((entry) => !known.contains(entry.key)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    ...extra,
    'enabled': enabled,
    'mode': mode,
    'showCheckbox': showCheckbox,
    'showSelectAll': showSelectAll,
    'persistAcrossPages': persistAcrossPages,
    if (maxSelection != null) 'maxSelection': maxSelection,
  };

  factory MetadataSelection.empty() {
    return const MetadataSelection();
  }
}
