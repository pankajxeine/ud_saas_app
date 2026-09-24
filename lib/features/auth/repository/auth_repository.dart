import '../../../core/config/app_logger.dart';
import '../../../core/api/api.dart';
import '../../../core/models/api_operation_response.dart';
import '../model/login_request.dart';
import '../model/login_response.dart';

class AuthRepository {
  final RestApi api;
  final log = AppLogger.getLogger('AuthRepository');

  AuthRepository({
    required String baseUrl,
    Map<String, String> headers = const {},
  }) : api = RestApi(baseUrl: baseUrl, defaultHeaders: headers);

  Future<ApiOperationResponse<LoginResponse>> authRegister(
      LoginRequest request) async {
    try {
      const endpointPath = '/auth/register';

      log.info(
        'Calling POST $endpointPath with request: request',
      );

      final response = await api.requestWithResponse<dynamic>(
        endpointPath: endpointPath,
        method: 'POST',
        body: request,
      );

      log.info('Response from $endpointPath: ${response.data}');
      final success = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      if (!success) {
        return ApiOperationResponse.error(
            'Request failed with status ${response.statusCode}');
      }

      final body = ApiParser.parseObject<LoginResponse>(
        response.data,
        (json) => LoginResponse.fromJson(json),
      );

      return ApiOperationResponse.success(body, message: 'Success');
    } catch (e, stack) {
      log.error('Error in authRegister: $e\n$stack');
      return ApiOperationResponse.error('Exception occurred: $e');
    }
  }

  Future<ApiOperationResponse<LoginResponse>> authLogin(
      LoginRequest request) async {
    try {
      const endpointPath = '/auth/login';

      log.info(
        'Calling POST $endpointPath with request: request',
      );

      final response = await api.requestWithResponse<dynamic>(
        endpointPath: endpointPath,
        method: 'POST',
        body: request,
      );

      log.info('Response from $endpointPath: ${response.data}');
      final success = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      if (!success) {
        return ApiOperationResponse.error(
            'Request failed with status ${response.statusCode}');
      }

      final body = ApiParser.parseObject<LoginResponse>(
        response.data,
        (json) => LoginResponse.fromJson(json),
      );

      return ApiOperationResponse.success(body, message: 'Success');
    } catch (e, stack) {
      log.error('Error in authLogin: $e\n$stack');
      return ApiOperationResponse.error('Exception occurred: $e');
    }
  }

  Future<ApiOperationResponse<LoginResponse?>> authLogout() async {
    try {
      final endpointPath = '/auth/logout';

      log.info(
        'Calling POST $endpointPath with request: {}',
      );

      final response = await api.requestWithResponse<dynamic>(
        endpointPath: endpointPath,
        method: 'POST',
      );

      log.info('Response from $endpointPath: ${response.data}');
      final success = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      if (!success) {
        return ApiOperationResponse.error(
            'Request failed with status ${response.statusCode}');
      }

      final body = null;

      return ApiOperationResponse.success(body, message: 'Success');
    } catch (e, stack) {
      log.error('Error in authLogout: $e\n$stack');
      return ApiOperationResponse.error('Exception occurred: $e');
    }
  }

  Future<ApiOperationResponse<LoginResponse>> authRefresh() async {
    try {
      final endpointPath = '/auth/refresh';

      log.info(
        'Calling POST $endpointPath with request: {}',
      );

      final response = await api.requestWithResponse<dynamic>(
        endpointPath: endpointPath,
        method: 'POST',
      );

      log.info('Response from $endpointPath: ${response.data}');
      final success = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      if (!success) {
        return ApiOperationResponse.error(
            'Request failed with status ${response.statusCode}');
      }

      final body = ApiParser.parseObject<LoginResponse>(
        response.data,
        (json) => LoginResponse.fromJson(json),
      );

      return ApiOperationResponse.success(body, message: 'Success');
    } catch (e, stack) {
      log.error('Error in authRefresh: $e\n$stack');
      return ApiOperationResponse.error('Exception occurred: $e');
    }
  }
}
