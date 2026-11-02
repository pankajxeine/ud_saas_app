import '../../core/api/rest_api.dart';
import '../../core/config/environment.dart';

class CpanelRows {
  const CpanelRows(this.rows, this.total);

  final List<Map<String, dynamic>> rows;
  final int? total;
}

CpanelRows parseCpanelRows(dynamic response) {
  if (response is List) {
    return CpanelRows(
      response
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList(),
      response.length,
    );
  }
  if (response is Map) {
    final payload = response['data'];
    final rows = payload is List
        ? payload
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList()
        : <Map<String, dynamic>>[];
    final pagination = response['pagination'];
    final totalValue =
        pagination is Map ? pagination['total'] : response['total'];
    return CpanelRows(
        rows, _asInt(totalValue) ?? (pagination == null ? rows.length : null));
  }
  return const CpanelRows([], 0);
}

Future<int?> loadCpanelCount(String endpoint) async {
  try {
    final response = await RestApi(baseUrl: ProfileConstants.api).get<dynamic>(
      endpoint,
      queryParams: const {'page': 1, 'limit': 1},
    );
    if (response is List) return response.length;
    if (response is Map) {
      final pagination = response['pagination'];
      final total = pagination is Map ? pagination['total'] : response['total'];
      return _asInt(total);
    }
  } catch (_) {
    return null;
  }
  return null;
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
