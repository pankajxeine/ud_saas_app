Map<String, dynamic> fieldToFormData(Map<String, dynamic> json) {
  return _deepCopyMap(json);
}

Map<String, dynamic> fieldFromFormData(
  Map<String, dynamic> formData,
  Map<String, dynamic> original,
) {
  return _deepMerge(_deepCopyMap(original), formData);
}

Map<String, dynamic> _deepCopyMap(Map<String, dynamic> source) {
  return source.map((key, value) => MapEntry(key, _deepCopyValue(value)));
}

dynamic _deepCopyValue(dynamic value) {
  if (value is Map) {
    return _deepCopyMap(Map<String, dynamic>.from(value));
  }

  if (value is List) {
    return value.map(_deepCopyValue).toList();
  }

  return value;
}

Map<String, dynamic> _deepMerge(
  Map<String, dynamic> original,
  Map<String, dynamic> updates,
) {
  final result = _deepCopyMap(original);

  for (final entry in updates.entries) {
    final key = entry.key;
    final newValue = entry.value;
    final oldValue = result[key];

    if (newValue is Map && oldValue is Map) {
      result[key] = _deepMerge(
        Map<String, dynamic>.from(oldValue),
        Map<String, dynamic>.from(newValue),
      );
    } else {
      result[key] = _deepCopyValue(newValue);
    }
  }

  return result;
}
