class MetadataGrid {
  final int pageSize;
  final MetadataSort? defaultSort;
  final Map<String, dynamic> extra;

  const MetadataGrid({
    this.pageSize = 20,
    this.defaultSort,
    this.extra = const {},
  });

  // final updatedGrid = grid.copyWith(
  //   pageSize: 50,
  //   defaultSort: {'field': 'created_at', 'order': 'desc'},
  // );

  MetadataGrid copyWith({int? pageSize, MetadataSort? defaultSort}) {
    return MetadataGrid(
      pageSize: pageSize ?? this.pageSize,
      defaultSort: defaultSort ?? this.defaultSort,
    );
  }

  factory MetadataGrid.fromJson(Map<String, dynamic> json) {
    const known = {'pageSize', 'defaultSort'};

    final sort = json['defaultSort'];

    return MetadataGrid(
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      defaultSort: sort is Map
          ? MetadataSort.fromJson(Map<String, dynamic>.from(sort))
          : null,
      extra: Map.fromEntries(
        json.entries.where((entry) => !known.contains(entry.key)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    ...extra,
    'pageSize': pageSize,
    if (defaultSort != null) 'defaultSort': defaultSort!.toJson(),
  };

  factory MetadataGrid.empty() {
    return const MetadataGrid(pageSize: 20, defaultSort: MetadataSort());
  }
}

class MetadataSort {
  final List<String> fields;
  final String direction;
  final Map<String, dynamic> extra;

  const MetadataSort({
    this.fields = const [],
    this.direction = 'asc',
    this.extra = const {},
  });

  factory MetadataSort.fromJson(Map<String, dynamic> json) {
    const known = {'field', 'direction'};

    return MetadataSort(
      fields:
          (json['fields'] as List?)?.map((v) => v.toString()).toList() ??
          const [],
      direction: json['direction']?.toString() ?? 'asc',
      extra: Map.fromEntries(
        json.entries.where((entry) => !known.contains(entry.key)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    ...extra,
    if (fields.isNotEmpty) 'fields': fields,
    'direction': direction,
  };

  MetadataSort.empty() : fields = const [], direction = 'asc', extra = const {};
}
