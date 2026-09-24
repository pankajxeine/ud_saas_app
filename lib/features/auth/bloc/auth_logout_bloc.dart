import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/auth_service.dart';
import '../../../core/config/app_logger.dart';
import '../../../core/models/api_operation_response.dart';
import '../model/auth_user.dart';
import '../model/login_request.dart';
import '../model/login_response.dart';
import '../model/register_request.dart';

// Events
abstract class AuthLogoutEvent {}

class LoadAuthLogoutEvent extends AuthLogoutEvent {


  LoadAuthLogoutEvent();
}

// States
abstract class AuthLogoutState {}

class AuthLogoutInitial extends AuthLogoutState {}

class AuthLogoutLoading extends AuthLogoutState {}

class AuthLogoutSuccess<T> extends AuthLogoutState {
  final ApiOperationResponse<T> response;

  AuthLogoutSuccess(this.response);
}

class AuthLogoutError extends AuthLogoutState {
  final String message;

  AuthLogoutError(this.message);
}

// Bloc
class AuthLogoutBloc extends Bloc<AuthLogoutEvent, AuthLogoutState> {
  final AuthService service;
  final log = AppLogger.getLogger('AuthLogoutBloc');

  AuthLogoutBloc(this.service) : super(AuthLogoutInitial()) {
    on<LoadAuthLogoutEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadAuthLogoutEvent event,
    Emitter<AuthLogoutState> emit,
  ) async {
    log.info('Bloc handling AuthLogoutEvent');
    emit(AuthLogoutLoading());

    try {
      final response = await service.authLogout();

      if (response.status) {
        emit(AuthLogoutSuccess(response));
      } else {
        emit(AuthLogoutError(response.message));
      }
    } catch (e, stack) {
      log.error('AuthLogout failed: $e\n$stack');
      emit(AuthLogoutError('Exception occurred: $e'));
    }
  }
}
