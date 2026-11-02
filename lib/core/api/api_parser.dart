import '../models/paginated_response.dart';

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
    final list = data is Map<String, dynamic> ? data['data'] : data;
    if (list == null) return <T>[];
    return (list as List)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Parses either a bare list or the common `{data, pagination}` envelope.
  static PaginatedResponse<T> parsePaginated<T>(
    dynamic value,
    FromJson<T> fromJson,
  ) {
    if (value == null) return const PaginatedResponse(data: []);
    if (value is List) {
      return PaginatedResponse(data: parseList<T>(value, fromJson));
    }
    if (value is! Map) {
      throw FormatException('Expected a list or paginated response object');
    }

    final json = Map<String, dynamic>.from(value);
    final rawPagination = json['pagination'];
    return PaginatedResponse<T>(
      data: parseList<T>(json['data'], fromJson),
      pagination: rawPagination is Map
          ? PaginationMetadata.fromJson(Map<String, dynamic>.from(rawPagination))
          : null,
    );
  }
}
