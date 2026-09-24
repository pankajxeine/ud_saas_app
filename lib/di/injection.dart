import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/theme_cubit.dart';
import '../core/layouts/bloc/navigation/navigation_cubit.dart';
import '../core/layouts/bloc/layout/layout_cubit.dart';

// import '../features/auth/bloc/login.dart';

// Create a global instance of GetIt
final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final pref = await SharedPreferences.getInstance();

  sl.registerSingleton<SharedPreferences>(pref);

  // Theme (singleton- persists across navigation)
  sl.registerSingleton<AppThemeCubit>(AppThemeCubit(sl()));
  sl.registerSingleton<NavigationCubit>(NavigationCubit());
  sl.registerSingleton<LayoutCubit>(LayoutCubit());

  // Auth
  // sl.registerSingleton<LoginBloc>(LoginBloc());
  // Dashboard

  //
}
