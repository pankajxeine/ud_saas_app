import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/features/auth/service/auth_service.dart';
import 'package:ud_sass_app/routes/route_repository.dart';

import '../core/layouts/bloc/navigation/navigation_cubit.dart';
import '../core/layouts/bloc/layout/layout_cubit.dart';

import '../features/auth/bloc/auth_login_bloc.dart';

// Create a global instance of GetIt
final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final pref = await SharedPreferences.getInstance();

  sl.registerSingleton<SharedPreferences>(pref);

  sl.registerSingleton<NavigationCubit>(NavigationCubit());

  sl.registerLazySingleton<AuthService>(
    () => AuthService(baseUrl: ProfileConstants.api.toString()),
  );

  sl.registerSingleton<AuthLoginBloc>(
    AuthLoginBloc(AuthService(baseUrl: ProfileConstants.api.toString())),
  );
  sl.registerSingleton<LayoutCubit>(LayoutCubit());

  sl.registerSingleton<RouteRepository>(RouteRepository());

  // Auth
  // sl.registerSingleton<LoginBloc>(LoginBloc());
  // Dashboard

  //
}
