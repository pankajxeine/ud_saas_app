import 'package:flutter/material.dart';

import '../i10n/i10n.dart';

/// Routes for the application
///
/// This class contains all the routes used in the application.
class ApplicationRoutesConstants {
  static const home = '/main';
  static const dashboard = home;
  static const emails = '/emails';

  // Auth routes
  static const login = '/login';
  static const tasks = '/tasks';
  static const apps = '/apps';
  static const users = '/users';
  static const help = '/help';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const changePassword = '/change-password';
  static const loginOtp = '/login-otp';
  static const loginOtpVerify = '/login-otp-verify';

  // Account routes
  static const account = '/account';

  // User routes
  static const userList = '/user';
  static const userView = '/user/:id/view';
  static const userEdit = '/user/:id/edit';
  static const userNew = '/user/new';

  // Settings routes
  static const settings = '/settings';

  // Error routes
  static const notFound = '/not-found';
  static const error = '/error';
  static const error500 = '/error/500';
  static const unauthorized = '/errors/401';
  static const forbidden = '/errors/403';
  static const notFoundError = '/errors/404';
  static const serviceUnavailable = '/errors/503';

  static String shellTitleFor(String route, S l) {
    switch (route) {
      case ApplicationRoutesConstants.dashboard:
        return l.workspace_overview;
      case ApplicationRoutesConstants.tasks:
        return l.tasks;
      case ApplicationRoutesConstants.apps:
        return l.apps;
      case ApplicationRoutesConstants.users:
        return l.users;
      case ApplicationRoutesConstants.settings:
        return l.settings;
      default:
        return l.workspace_overview;
    }
  }

  static String navigationLabelFor(String key, S l) {
    switch (key) {
      case 'nav_overview':
        return l.nav_overview;
      case 'nav_manage':
        return l.nav_manage;
      case 'nav_apps':
        return l.nav_apps;
      case 'nav_build':
        return l.nav_build;
      case 'nav_orders':
        return l.nav_orders;
      case 'nav_customers':
        return l.nav_customers;
      case 'nav_products':
        return l.nav_products;
      case 'nav_inbox':
        return l.nav_inbox;
      case 'nav_board':
        return l.nav_board;
      case 'nav_calendar':
        return l.nav_calendar;
      case 'nav_chat':
        return l.nav_chat;
      case 'nav_components':
        return l.nav_components;
      case 'nav_forms':
        return l.nav_forms;
      case 'nav_wizard':
        return l.nav_wizard;
      case 'nav_profile':
        return l.nav_profile;
      case 'settings':
        return l.settings;
      default:
        return key;
    }
  }

  static const kNavGroups = <NavGroup>[
    NavGroup(
      'Overview',
      'nav_overview',
      [],
      R.dashboard,
      Icons.dashboard_outlined,
    ),
    NavGroup(
        'Manage',
        'nav_manage',
        [
          NavItem(
              'Orders', 'nav_orders', R.orders, Icons.receipt_long_outlined),
          NavItem(
              'Customers', 'nav_customers', R.customers, Icons.people_outline),
          NavItem('Products', 'nav_products', R.products,
              Icons.inventory_2_outlined),
        ],
        null,
        null),
    NavGroup(
        'Apps',
        'nav_apps',
        [
          NavItem('Inbox', 'nav_inbox', R.inbox, Icons.mail_outline),
          NavItem('Board', 'nav_board', R.kanban, Icons.view_kanban_outlined),
          NavItem('Calendar', 'nav_calendar', R.calendar,
              Icons.calendar_today_outlined),
          NavItem('Chat', 'nav_chat', R.chat, Icons.chat_bubble_outline),
        ],
        null,
        null),
    NavGroup(
        'Build',
        'nav_build',
        [
          NavItem('Components', 'nav_components', R.components,
              Icons.widgets_outlined),
          NavItem('Forms', 'nav_forms', R.forms, Icons.edit_note_outlined),
          NavItem(
              'Wizard', 'nav_wizard', R.wizard, Icons.linear_scale_outlined),
          NavItem('Settings', 'settings', R.settings, Icons.settings_outlined),
          NavItem('Profile', 'nav_profile', R.profile, Icons.person_outline,
              inSidebar: false),
        ],
        null,
        null)
  ];
}

class NavGroup {
  const NavGroup(
      this.label, this.localizationKey, this.items, this.path, this.icon);
  final String label;
  final String localizationKey;
  final List<NavItem> items;
  final String? path;
  final IconData? icon;
}

class NavItem {
  const NavItem(
    this.label,
    this.localizationKey,
    this.path,
    this.icon, {
    this.inSidebar = true,
  });

  /// English label. Also the fallback if a translation is missing.
  final String label;
  final String localizationKey;
  final String path;
  final IconData icon;

  /// Whether the sidebar lists this item.
  ///
  /// Profile is reachable from the account menu, where people look for it, and
  /// listing it again under "Build" both mis-grouped it and pushed the last
  /// real nav row under the promo card. It stays here so the command palette
  /// and the page-title lookup still resolve it.
  final bool inSidebar;
}

abstract final class R {
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const forgot = '/forgot-password';
  static const otp = '/verify';
  static const lock = '/lock';

  static const dashboard = '/';
  static const projects = '/projects';
  static const serverError = '/500';
  static const orders = '/orders';
  static const customers = '/customers';
  static const products = '/products';
  static const inbox = '/inbox';
  static const kanban = '/board';
  static const calendar = '/calendar';
  static const chat = '/chat';
  static const components = '/components';
  static const forms = '/forms';
  static const wizard = '/wizard';
  static const settings = '/settings';
  static const profile = '/profile';

  static bool isAuthRoute(String location) =>
      location.startsWith(signIn) ||
      location.startsWith(signUp) ||
      location.startsWith(forgot) ||
      location.startsWith(otp) ||
      location.startsWith(lock);
}
