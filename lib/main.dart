import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ud_sass_app/core/config/app_logger.dart';
import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/core/config/local_storage.dart';
import 'package:ud_sass_app/core/theme/bloc/theme_cubit.dart';
import 'package:ud_sass_app/di/injection.dart';

import 'features/auth/bloc/auth_login_bloc.dart';

import 'app.dart';
import 'core/theme/theme_utils.dart';
import 'web_bridge.dart';

const bool enableWebSemantics = bool.fromEnvironment(
  'ENABLE_WEB_SEMANTICS',
  defaultValue: false,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.configure(isProduction: false);
  final log = AppLogger.getLogger('main_local.dart');

  ProfileConstants.setEnvironment(Environment.dev);

  log.info('Starting App with env: {}', [Environment.dev.name]);

  if (kIsWeb && enableWebSemantics) {
    SemanticsBinding.instance.ensureSemantics();
  }

  // Initialize dependency injection.
  await configureDependencies();

  // Initialize local storage.
  AppLocalStorage().setStorage(StorageType.sharedPreferences);

  const defaultLanguage = 'en';
  await AppLocalStorage().save(StorageKeys.language.name, defaultLanguage);

  // Load persisted theme settings.
  final SharedPreferences prefs = sl<SharedPreferences>();
  final settings = await loadSettings(prefs);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) =>
              ThemeCubit(initialSettings: settings, preferences: prefs),
        ),
        BlocProvider<AuthLoginBloc>(create: (_) => sl<AuthLoginBloc>()),
      ],
      child: const _DeferredFirstFrameApp(child: AppRoot()),
    ),
  );
}

class _DeferredFirstFrameApp extends StatefulWidget {
  const _DeferredFirstFrameApp({required this.child});

  final Widget child;

  @override
  State<_DeferredFirstFrameApp> createState() => _DeferredFirstFrameAppState();
}

class _DeferredFirstFrameAppState extends State<_DeferredFirstFrameApp> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _ready = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ready ? widget.child : const SizedBox.shrink();
  }
}

String getReleaseTagName() => 'Release';
