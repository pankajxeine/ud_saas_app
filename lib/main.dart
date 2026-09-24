import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ud_sass_app/core/config/app_logger.dart';
import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/core/config/local_storage.dart';
import 'package:ud_sass_app/core/theme/theme_cubit.dart';
import 'package:ud_sass_app/core/theme/theme_state.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ud_sass_app/di/injection.dart';

import 'web_bridge.dart';
import 'app.dart';
import 'core/theme/theme_utils.dart';

const bool enableWebSemantics = bool.fromEnvironment(
  'ENABLE_WEB_SEMANTICS',
  defaultValue: false,
);

Future<void> main() async {
  AppLogger.configure(isProduction: false);
  final log = AppLogger.getLogger("main_local.dart");

  ProfileConstants.setEnvironment(Environment.dev);
  final apiBaseUrl = ProfileConstants.api.toString();
  // if (apiBaseUrl != 'mock') {
  //   RestApi.configureGlobal(baseUrl: apiBaseUrl);
  // }

  log.info("Starting App with env: {}", [Environment.dev.name]);
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb && enableWebSemantics) {
    SemanticsBinding.instance.ensureSemantics();
  }
  await configureDependencies();
  const defaultLanguage = "en";
  AppLocalStorage().setStorage(StorageType.sharedPreferences);
  await AppLocalStorage().save(StorageKeys.language.name, defaultLanguage);

  final appConfig = await _loadAppConfig();
  final prefs = await SharedPreferences.getInstance();
  final settings = await loadSettings(prefs);

  // runApp(AppRoot(
  //   appConfig: appConfig,
  //   settings: settings,
  //   prefs: prefs,
  // ));
  runApp(MultiBlocProvider(
      providers: [
        BlocProvider<AppThemeCubit>.value(value: sl<AppThemeCubit>()),
      ],
      child: BlocBuilder<AppThemeCubit, AppThemeState>(
          builder: (context, themeState) {
        return _DeferredFirstFrameApp(
          child:
              AppRoot(appConfig: appConfig, settings: settings, prefs: prefs),
        );
      })));
  _notifyWebAppReady();
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

Future<Map<String, Object?>> _loadAppConfig() async {
  try {
    final raw = await rootBundle.loadString('docs.json');
    return jsonDecode(raw) as Map<String, Object?>;
  } catch (_) {
    return {'flavor': 'local'};
  }
}

void _notifyWebAppReady() {
  if (!kIsWeb) return;
  SchedulerBinding.instance.addPostFrameCallback((_) {
    dispatchWebAppReady();
  });
}

String getReleaseTagName() {
  return 'Release';
}

String? loadPackageVersion(String rawLock) {
  final lock = loadYaml(rawLock);
  if (lock is! YamlMap) {
    return null;
  }
  final packages = lock['packages'];
  if (packages is! YamlMap) {
    return null;
  }
  final dep = packages['shadcn_flutter'];
  if (dep is! YamlMap) {
    return null;
  }
  final version = dep['version'];
  return version is String ? version : null;
}
