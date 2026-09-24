import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/utils/security_utils.dart';
import '../core/config/allowed_paths.dart';
import '../core/config/app_logger.dart';
import '../core/config/environment.dart';
import '../core/layouts/app_layout.dart';

import '../features/auth/login_page.dart';
// import '../features/dashboard/dashboard_page.dart';
// import '../features/dashboard/error_page.dart';
// import '../features/dashboard/placeholder_page.dart';

import 'package:ud_sass_app/ui/shadcn/components/utility/error_system/error_system.dart';
// import 'package:ud_sass_app/ui/shadcn/shared/theme/color_scheme.dart'

import 'package:ud_sass_app/features/example/dashbaord_page.dart';
import 'package:ud_sass_app/features/example/create_project_page.dart';
import 'package:ud_sass_app/features/example/data_grid_page.dart';
import 'package:ud_sass_app/features/example/dynamic_form_page.dart';
import 'package:ud_sass_app/features/example/onboarding_page.dart';
import 'package:ud_sass_app/features/settings/settings_page.dart';

import 'app_routes_constants.dart';

/// Route inventory mirrors the referenced shadcn_flutter_admin template:
/// login, dashboard and standalone error states. The shell is intentionally
/// absent from login and applied to every workspace destination.
class AppGoRouterConfig {
  static final _log = AppLogger.getLogger("AppGoRouterConfig");
  static const _pageTransitionDuration = Duration(milliseconds: 180);
  static const _pageReverseTransitionDuration = Duration(milliseconds: 120);

  static CustomTransitionPage<void> _buildTransitionPage(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: ScreenErrorScope(child: child),
      transitionDuration: _pageTransitionDuration,
      reverseTransitionDuration: _pageReverseTransitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final fade = Tween<double>(begin: 0, end: 1).animate(curve);
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(curve);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  static final GoRouter testRouter = GoRouter(
    initialLocation: ApplicationRoutesConstants.dashboard,
    routes: [
      GoRoute(
        path: '/',
        name: 'introduction',
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const DynamicFormPage()),
      ),
      GoRoute(
        path: '/installation',
        name: 'installation',
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, DataGridPage()),
      ),
    ],
  );

  static final GoRouter router = GoRouter(
    initialLocation: ApplicationRoutesConstants.login,
    //refreshListenable: ,
    //errorPageBuilder: (_, __) => const  ErrorPage.notFound(),
    routes: [
      GoRoute(
        path: ApplicationRoutesConstants.login,
        builder: (_, __) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppLayout(
          body: child,
        ),
        routes: [
          GoRoute(
            path: '/',
            name: 'introduction',
            pageBuilder: (context, state) =>
                _buildTransitionPage(state, const SettingsPage()),
          ),
          GoRoute(
            path: '/installation',
            name: 'installation',
            pageBuilder: (context, state) =>
                _buildTransitionPage(state, const OnboardingPage()),
          ),
          GoRoute(
            path: '/complete-guide',
            name: 'complete-guide',
            pageBuilder: (context, state) =>
                _buildTransitionPage(state, const CreateProjectPage()),
          ),
          GoRoute(
            path: R.forms,
            name: 'forms',
            pageBuilder: (context, state) =>
                _buildTransitionPage(state, const DynamicFormPage()),
          ),
          GoRoute(
            path: R.components,
            name: 'components',
            pageBuilder: (context, state) =>
                _buildTransitionPage(state, DataGridPage()),
          ),
          GoRoute(
            path: '/login',
            name: 'login',
            pageBuilder: (context, state) =>
                _buildTransitionPage(state, const LoginPage()),
          ),
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) =>
                _buildTransitionPage(state, const DashboardPage()),
          ),
        ],
      ),
    ],
    redirect: (context, state) async {
      _log.debug("BEGIN: redirect");
      _log.debug("redirect - uri: ${state.uri}");
      _log.debug("authPaths: $authPaths");
      // Skip redirect for login page
      if (authPaths.any((p) => state.uri.path.startsWith(p))) {
        _log.debug("END: redirect null - with authPaths");
        return null;
      }

      // check : when redirect the new page then load the account data
      // if (state.uri.toString() == ApplicationRoutesConstants.home) {
      //   var accountBloc = context.read<AccountBloc>();
      //   await Future.delayed(const Duration(microseconds: 500));
      //   accountBloc.add(const AccountFetchEvent());
      //   _log.debug("redirect - load event : accountBloc.add(AccountLoad())");
      // }
      // check : when jwtToken is null then redirect to login page
      _log.debug("isUserLoggedIn: ${SecurityUtils.isUserLoggedIn()}");
      if (!SecurityUtils.isUserLoggedIn() &&
          !SecurityUtils.isAllowedPath(state.uri.toString())) {
        _log.debug("END: isUserLoggedIn is false and isAllowedPath is false");
        if (state.uri.toString() != ApplicationRoutesConstants.login) {
          return ApplicationRoutesConstants.login;
        } else {
          return null;
        }
      }
      // check : when running in production mode and jwtToken is expired then redirect to login page
      if (ProfileConstants.isProduction &&
          SecurityUtils.isTokenExpired() &&
          state.uri.toString() != ApplicationRoutesConstants.login) {
        _log.debug("END: redirect - jwtToken is expired");
        return ApplicationRoutesConstants.login;
      }

      _log.debug("END: redirect return null");
      return null;
    },
    // errorBuilder: (_, __) => const ErrorPage.notFound(),
  );

  // static String _shellTitleFor(String route) {
  //   switch (route) {
  //     case ApplicationRoutesConstants.dashboard:
  //       return 'Workspace overview';
  //     case ApplicationRoutesConstants.tasks:
  //       return 'Tasks';
  //     case ApplicationRoutesConstants.apps:
  //       return 'Apps';
  //     case ApplicationRoutesConstants.users:
  //       return 'Users';
  //     case ApplicationRoutesConstants.settings:
  //       return 'Settings';
  //     default:
  //       return 'Workspace overview';
  //   }
  // }

  // static final _placeholderRoutes = <RouteBase>[
  //   GoRoute(
  //     path: ApplicationRoutesConstants.tasks,
  //     builder: (_, __) => const PlaceholderPage(
  //       title: 'Tasks',
  //       description: 'Plan, assign and track workspace tasks.',
  //     ),
  //   ),
  //   GoRoute(
  //     path: ApplicationRoutesConstants.apps,
  //     builder: (_, __) => const PlaceholderPage(
  //       title: 'Apps',
  //       description: 'Connect your workspace tools and integrations.',
  //     ),
  //   ),
  //   GoRoute(
  //     path: ApplicationRoutesConstants.users,
  //     builder: (_, __) => const PlaceholderPage(
  //       title: 'Users',
  //       description: 'Manage workspace members and permissions.',
  //     ),
  //   ),
  //   GoRoute(
  //     path: ApplicationRoutesConstants.settings,
  //     builder: (_, __) => const SettingsPage(),
  //   ),
  //   GoRoute(
  //     path: ApplicationRoutesConstants.help,
  //     builder: (_, __) => const PlaceholderPage(
  //       title: 'Help center',
  //       description: 'Find guidance for your workspace.',
  //     ),
  //   ),
  // ];
}
