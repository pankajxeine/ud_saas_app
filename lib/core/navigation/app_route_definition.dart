import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

typedef AppRouteBuilder =
    Widget Function(BuildContext context, GoRouterState state);

typedef AppRouteRedirect =
    FutureOr<String?> Function(BuildContext context, GoRouterState state);

typedef DynamicPageBuilder =
    Widget Function(
      BuildContext context,
      GoRouterState state,
      Map<String, dynamic> pageConfig,
    );

class AppRouteDefinition {
  const AppRouteDefinition({
    required this.name,
    required this.path,
    required this.builder,
    this.label,
    this.localizationKey,
    this.parentName,
    this.icon = 0xe836,
    this.selectedIcon = 0xe836,
    this.section,
    this.showInSidebar = false,
    this.showInRail = false,
    this.showInBottomBar = false,
    this.showInBreadcrumb = true,
    this.bottomBarOrder,
    this.redirect,
    this.pageType,
    this.pageConfig = const {},
    this.permission,
    this.requiresAuth = true,
    this.isDynamic = false,
    this.enabled = true,
  });

  final String name;
  final String path;

  final String? label;
  final String? localizationKey;

  /// Parent route name used for navigation hierarchy and breadcrumbs.
  final String? parentName;

  final int icon;
  final int selectedIcon;
  final String? section;

  final bool showInSidebar;
  final bool showInRail;
  final bool showInBottomBar;
  final bool showInBreadcrumb;
  final bool requiresAuth;
  final int? bottomBarOrder;

  final AppRouteBuilder builder;
  final AppRouteRedirect? redirect;

  /// Logical page type, for example:
  /// modules, module, moduleVersion, entityList, entityDetail.
  final String? pageType;

  /// Additional configuration supplied by the database.
  final Map<String, dynamic> pageConfig;

  /// Permission required to access this route.
  final String? permission;

  final bool isDynamic;
  final bool enabled;

  AppRouteDefinition copyWith({
    String? name,
    String? path,
    String? label,
    String? localizationKey,
    String? parentName,
    int? icon,
    int? selectedIcon,
    String? section,
    bool? showInSidebar,
    bool? showInRail,
    bool? showInBottomBar,
    bool? showInBreadcrumb,
    int? bottomBarOrder,
    AppRouteBuilder? builder,
    AppRouteRedirect? redirect,
    String? pageType,
    Map<String, dynamic>? pageConfig,
    String? permission,
    bool? isDynamic,
    bool? enabled,
    bool? requiresAuth,
  }) {
    return AppRouteDefinition(
      name: name ?? this.name,
      path: path ?? this.path,
      label: label ?? this.label,
      localizationKey: localizationKey ?? this.localizationKey,
      parentName: parentName ?? this.parentName,
      icon: icon ?? this.icon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      section: section ?? this.section,
      showInSidebar: showInSidebar ?? this.showInSidebar,
      showInRail: showInRail ?? this.showInRail,
      showInBottomBar: showInBottomBar ?? this.showInBottomBar,
      showInBreadcrumb: showInBreadcrumb ?? this.showInBreadcrumb,
      bottomBarOrder: bottomBarOrder ?? this.bottomBarOrder,
      builder: builder ?? this.builder,
      redirect: redirect ?? this.redirect,
      pageType: pageType ?? this.pageType,
      pageConfig: pageConfig ?? this.pageConfig,
      permission: permission ?? this.permission,
      isDynamic: isDynamic ?? this.isDynamic,
      enabled: enabled ?? this.enabled,
      requiresAuth: requiresAuth ?? this.requiresAuth,
    );
  }
}
