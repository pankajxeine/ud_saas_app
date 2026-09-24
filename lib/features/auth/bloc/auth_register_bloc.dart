import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/auth_service.dart';
import '../../../core/config/app_logger.dart';
import '../../../core/models/api_operation_response.dart';
import '../model/auth_user.dart';
import '../model/login_request.dart';
import '../model/login_response.dart';
import '../model/register_request.dart';

// Events
abstract class AuthRegisterEvent {}

class LoadAuthRegisterEvent extends AuthRegisterEvent {
  final LoginRequest request;

  LoadAuthRegisterEvent({
    required this.request,
  });

}

// States
abstract class AuthRegisterState {}

class AuthRegisterInitial extends AuthRegisterState {}

class AuthRegisterLoading extends AuthRegisterState {}

class AuthRegisterSuccess<T> extends AuthRegisterState {
  final ApiOperationResponse<T> response;

  AuthRegisterSuccess(this.response);
}

class AuthRegisterError extends AuthRegisterState {
  final String message;

  AuthRegisterError(this.message);
}

// Bloc
class AuthRegisterBloc extends Bloc<AuthRegisterEvent, AuthRegisterState> {
  final AuthService service;
  final log = AppLogger.getLogger('AuthRegisterBloc');

  AuthRegisterBloc(this.service) : super(AuthRegisterInitial()) {
    on<LoadAuthRegisterEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadAuthRegisterEvent event,
    Emitter<AuthRegisterState> emit,
  ) async {
    log.info('Bloc handling AuthRegisterEvent');
    emit(AuthRegisterLoading());

    try {
      final response = await service.authRegister(event.request);

      if (response.status) {
        emit(AuthRegisterSuccess(response));
      } else {
        emit(AuthRegisterError(response.message));
      }
    } catch (e, stack) {
      log.error('AuthRegister failed: $e\n$stack');
      emit(AuthRegisterError('Exception occurred: $e'));
    }
  }
}
