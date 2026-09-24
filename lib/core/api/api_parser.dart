// utils/api_parser.dart
typedef FromJson<T> = T Function(Map<String, dynamic> json);

class ApiParser {
  /// Parse a single object
  static T? parseObject<T>(dynamic data, FromJson<T> fromJson) {
    if (data == null) return null;
    return fromJson(data as Map<String, dynamic>);
  }

  /// Parse a list of objects
  static List<T> parseList<T>(dynamic data, FromJson<T> fromJson) {
    if (data == null) return <T>[];
    return (data as List)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
