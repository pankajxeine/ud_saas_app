import '../models/metadata_schema.dart';

/// Deep copies any JSON-compatible value.
dynamic deepCopyValue(dynamic value) {
  if (value is Map) {
    return value.map(
      (key, item) => MapEntry(key.toString(), deepCopyValue(item)),
    );
  }

  if (value is List) {
    return value.map(deepCopyValue).toList();
  }

  return value;
}

/// Deep copies a JSON map.
///
/// Returns an empty map when [source] is null or not a Map.
Map<String, dynamic> deepCopyMap(dynamic source) {
  if (source is! Map) {
    return <String, dynamic>{};
  }

  final copied = deepCopyValue(source);

  return Map<String, dynamic>.from(copied as Map);
}

/// Deep copies a JSON list.
List<dynamic> deepCopyList(dynamic source) {
  if (source is! List) {
    return <dynamic>[];
  }

  return List<dynamic>.from(source.map(deepCopyValue));
}

/// Deep copies a model from a JSON-compatible source.
T deepCopyModel<T>(dynamic source, T Function(Map<String, dynamic>) fromJson) {
  return fromJson(deepCopyMap(source));
}

/// Deep copies a [MetadataSchema].
MetadataSchema deepCopyMetadataSchema(MetadataSchema source) {
  return MetadataSchema.fromJson(deepCopyMap(source.toJson()));
}

/// Safely extracts a list of JSON maps from [source].
List<Map<String, dynamic>> getJsonMapList(
  Map<String, dynamic>? source,
  String key,
) {
  if (source == null) {
    return <Map<String, dynamic>>[];
  }

  final value = source[key];

  if (value is! List) {
    return <Map<String, dynamic>>[];
  }

  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(deepCopyMap(item)))
      .toList();
}
