// lib/services/domain_service.dart
import '../api/api.dart';

class DomainService {
  final api = RestApi.global();

  Future<Map<String, dynamic>> getDomainDetails(String domain) async {
    final response = await api.request<Map<String, dynamic>>(
      endpoint: '/cpanelroutes/$domain',
      method: 'GET',
    );
    return response;
  }
}
