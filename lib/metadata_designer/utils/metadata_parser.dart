import 'dart:convert';

class MetadataParser {
  const MetadataParser();

  Map<String, dynamic> parse(String source) {
    final decoded = jsonDecode(source);

    if (decoded is! Map) {
      throw const FormatException('Metadata root must be a JSON object.');
    }

    return Map<String, dynamic>.from(decoded);
  }

  String encode(Map<String, dynamic> metadata, {bool pretty = true}) {
    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(metadata);
    }

    return jsonEncode(metadata);
  }

  Map<String, dynamic> clone(Map<String, dynamic> source) {
    return Map<String, dynamic>.from(_cloneValue(source) as Map);
  }

  dynamic _cloneValue(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), _cloneValue(item)),
      );
    }

    if (value is List) {
      return value.map(_cloneValue).toList();
    }

    return value;
  }

  List<Map<String, dynamic>> fields(Map<String, dynamic> metadata) {
    final value = metadata['fields'];

    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Map<String, dynamic>? findField(
    Map<String, dynamic> metadata,
    String fieldName,
  ) {
    for (final field in fields(metadata)) {
      if (field['name'] == fieldName) return field;
    }

    return null;
  }

  dynamic readPath(Map<String, dynamic> source, String path) {
    dynamic current = source;

    for (final segment in path.split('.')) {
      if (current is! Map || !current.containsKey(segment)) {
        return null;
      }

      current = current[segment];
    }

    return current;
  }

  Map<String, dynamic> writePath(
    Map<String, dynamic> source,
    String path,
    dynamic value,
  ) {
    final result = clone(source);
    final segments = path.split('.');

    Map<String, dynamic> current = result;

    for (var i = 0; i < segments.length - 1; i++) {
      final segment = segments[i];
      final existing = current[segment];

      if (existing is Map) {
        current[segment] = Map<String, dynamic>.from(existing);
      } else {
        current[segment] = <String, dynamic>{};
      }

      current = current[segment] as Map<String, dynamic>;
    }

    current[segments.last] = value;

    return result;
  }
}
