import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/auth_service.dart';
import '../../../core/config/app_logger.dart';
import '../../../core/models/api_operation_response.dart';
import '../model/auth_user.dart';
import '../model/login_request.dart';
import '../model/login_response.dart';
import '../model/register_request.dart';

// Events
abstract class AuthRefreshEvent {}

class LoadAuthRefreshEvent extends AuthRefreshEvent {


  LoadAuthRefreshEvent();
}

// States
abstract class AuthRefreshState {}

class AuthRefreshInitial extends AuthRefreshState {}

class AuthRefreshLoading extends AuthRefreshState {}

class AuthRefreshSuccess<T> extends AuthRefreshState {
  final ApiOperationResponse<T> response;

  AuthRefreshSuccess(this.response);
}

class AuthRefreshError extends AuthRefreshState {
  final String message;

  AuthRefreshError(this.message);
}

// Bloc
class AuthRefreshBloc extends Bloc<AuthRefreshEvent, AuthRefreshState> {
  final AuthService service;
  final log = AppLogger.getLogger('AuthRefreshBloc');

  AuthRefreshBloc(this.service) : super(AuthRefreshInitial()) {
    on<LoadAuthRefreshEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadAuthRefreshEvent event,
    Emitter<AuthRefreshState> emit,
  ) async {
    log.info('Bloc handling AuthRefreshEvent');
    emit(AuthRefreshLoading());

    try {
      final response = await service.authRefresh();

      if (response.status) {
        emit(AuthRefreshSuccess(response));
      } else {
        emit(AuthRefreshError(response.message));
      }
    } catch (e, stack) {
      log.error('AuthRefresh failed: $e\n$stack');
      emit(AuthRefreshError('Exception occurred: $e'));
    }
  }
}
