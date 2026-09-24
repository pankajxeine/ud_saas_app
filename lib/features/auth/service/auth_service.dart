import '../repository/auth_repository.dart';
import '../../../core/config/app_logger.dart';
import '../model/auth_user.dart';
import '../model/login_request.dart';
import '../model/login_response.dart';
import '../model/register_request.dart';
import '../../../core/models/api_operation_response.dart'; // <-- common response model

class AuthService {
  final AuthRepository repository;
  final log = AppLogger.getLogger('AuthService');

  AuthService({
    required String baseUrl,
    Map<String, String> headers = const {},
  }) : repository = AuthRepository(baseUrl: baseUrl, headers: headers);

  Future<ApiOperationResponse<LoginResponse>> authRegister(
      LoginRequest request) async {
    try {
      log.info(
        'Service calling repository.authRegister with params: request',
      );

      final response = await repository.authRegister(request);

      log.info('Service received response: $response');
      return response;
    } catch (e, stack) {
      log.error('Error in AuthService.authRegister: $e\n$stack');
      return ApiOperationResponse.error('Exception occurred in service: $e');
    }
  }

  Future<ApiOperationResponse<LoginResponse>> authLogin(
      LoginRequest request) async {
    try {
      log.info(
        'Service calling repository.authLogin with params: request',
      );

      final response = await repository.authLogin(request);

      log.info('Service received response: $response');
      return response;
    } catch (e, stack) {
      log.error('Error in AuthService.authLogin: $e\n$stack');
      return ApiOperationResponse.error('Exception occurred in service: $e');
    }
  }

  Future<ApiOperationResponse<LoginResponse?>> authLogout() async {
    try {
      log.info(
        'Service calling repository.authLogout with params: {}',
      );

      final response = await repository.authLogout();

      log.info('Service received response: $response');
      return response;
    } catch (e, stack) {
      log.error('Error in AuthService.authLogout: $e\n$stack');
      return ApiOperationResponse.error('Exception occurred in service: $e');
    }
  }

  Future<ApiOperationResponse<LoginResponse>> authRefresh() async {
    try {
      log.info(
        'Service calling repository.authRefresh with params: {}',
      );

      final response = await repository.authRefresh();

      log.info('Service received response: $response');
      return response;
    } catch (e, stack) {
      log.error('Error in AuthService.authRefresh: $e\n$stack');
      return ApiOperationResponse.error('Exception occurred in service: $e');
    }
  }
}
