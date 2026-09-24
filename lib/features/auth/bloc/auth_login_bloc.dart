import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/auth_service.dart';
import '../../../core/config/app_logger.dart';
import '../../../core/config/local_storage.dart';
import '../../../core/models/api_operation_response.dart';
import '../model/auth_user.dart';
import '../model/login_request.dart';
import '../model/login_response.dart';
import '../model/register_request.dart';

// Events
abstract class AuthLoginEvent {}

class LoadAuthLoginEvent extends AuthLoginEvent {
  final LoginRequest request;

  LoadAuthLoginEvent({
    required this.request,
  });
}

// States
abstract class AuthLoginState {}

class AuthLoginInitial extends AuthLoginState {}

class AuthLoginLoading extends AuthLoginState {}

class AuthLoginSuccess extends AuthLoginState {
  final ApiOperationResponse<LoginResponse> response;

  AuthLoginSuccess(this.response);
}

class AuthLoginError extends AuthLoginState {
  final String message;

  AuthLoginError(this.message);
}

// Bloc
class AuthLoginBloc extends Bloc<AuthLoginEvent, AuthLoginState> {
  final AuthService service;
  final log = AppLogger.getLogger('AuthLoginBloc');

  AuthLoginBloc(this.service) : super(AuthLoginInitial()) {
    on<LoadAuthLoginEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadAuthLoginEvent event,
    Emitter<AuthLoginState> emit,
  ) async {
    log.info('Bloc handling AuthLoginEvent');
    emit(AuthLoginLoading());

    try {
      final response = await service.authLogin(event.request);

      final loginResponse = response.body;
      if (response.status && loginResponse != null) {
        final storage = AppLocalStorage();
        final saved = await Future.wait([
          storage.save(StorageKeys.accessToken.name, loginResponse.accessToken),
          storage.save(
            StorageKeys.loggedUser.name,
            jsonEncode(loginResponse.user.toJson()),
          ),
          storage.save(StorageKeys.username.name, loginResponse.user.username),
          storage.save(StorageKeys.roles.name, [loginResponse.user.role]),
        ]);

        if (saved.any((wasSaved) => !wasSaved)) {
          emit(AuthLoginError('Could not save the login session.'));
          return;
        }

        emit(AuthLoginSuccess(response));
      } else {
        emit(AuthLoginError(response.message));
      }
    } catch (e, stack) {
      log.error('AuthLogin failed: $e\n$stack');
      emit(AuthLoginError('Exception occurred: $e'));
    }
  }
}
