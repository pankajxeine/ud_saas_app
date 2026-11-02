/// Common envelope for list endpoints that return records and pagination data.
class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMetadata? pagination;

  const PaginatedResponse({required this.data, this.pagination});
}

class PaginationMetadata {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;

  const PaginationMetadata({this.page, this.limit, this.total, this.totalPages});

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) =>
      PaginationMetadata(
        page: _toInt(json['page']),
        limit: _toInt(json['limit']),
        total: _toInt(json['total']),
        totalPages: _toInt(json['totalPages'] ?? json['total_pages']),
      );

  static int? _toInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '');
}
