import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/app_route_registry.dart';
import '../../navigation/app_route_definition.dart';

enum AppNavigationType { adaptive, rail, bottomBar }

class AppNavigation extends StatelessWidget {
  const AppNavigation({
    super.key,
    required this.currentRoute,
    required this.routesList,
    this.type = AppNavigationType.adaptive,
    this.breakpoint = 700,
    this.extended = false,
    this.labelType = NavigationRailLabelType.selected,
    this.backgroundColor,
    this.onDestinationSelected,
  });

  final String currentRoute;
  final List<AppRouteDefinition> routesList;

  /// adaptive: Rail on wider screens, bottom bar on smaller screens.
  /// rail: Always NavigationRail.
  /// bottomBar: Always NavigationBar.
  final AppNavigationType type;

  /// Width at which navigation switches from bottom bar to rail.
  final double breakpoint;

  final bool extended;
  final NavigationRailLabelType labelType;
  final Color? backgroundColor;

  final ValueChanged<AppRouteDefinition>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final useRail = switch (type) {
      AppNavigationType.rail => true,
      AppNavigationType.bottomBar => false,
      AppNavigationType.adaptive => width >= breakpoint,
    };

    return useRail ? _buildRail(context) : _buildBottomBar(context);
  }

  // ---------------------------------------------------------------------------
  // Navigation Rail
  // ---------------------------------------------------------------------------

  Widget _buildRail(BuildContext context) {
    final routes = AppRouteRegistry.railRoutes(routesList);

    if (routes.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedIndex = _selectedIndex(routes);

    return NavigationRail(
      selectedIndex: selectedIndex,
      extended: extended,
      labelType: extended ? NavigationRailLabelType.none : labelType,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      minWidth: 76,
      onDestinationSelected: (index) {
        _navigate(context, routes[index]);
      },
      destinations: [
        for (final route in routes)
          NavigationRailDestination(
            icon: Icon(IconData(route.icon, fontFamily: 'MaterialIcons')),
            selectedIcon: Icon(
              IconData(route.selectedIcon, fontFamily: 'MaterialIcons'),
            ),
            label: Text(route.label ?? ''),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Navigation Bar
  // ---------------------------------------------------------------------------

  Widget _buildBottomBar(BuildContext context) {
    final routes = AppRouteRegistry.bottomBarRoutes(routesList);

    if (routes.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedIndex = _selectedIndex(routes);

    return NavigationBar(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        _navigate(context, routes[index]);
      },
      destinations: [
        for (final route in routes)
          NavigationDestination(
            icon: Icon(IconData(route.icon, fontFamily: 'MaterialIcons')),
            selectedIcon: Icon(
              IconData(route.selectedIcon, fontFamily: 'MaterialIcons'),
            ),
            label: route.label ?? '',
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared
  // ---------------------------------------------------------------------------

  int _selectedIndex(List<AppRouteDefinition> routes) {
    final index = routes.indexWhere(
      (route) => AppRouteRegistry.isActive(route, currentRoute),
    );

    return index < 0 ? 0 : index;
  }

  void _navigate(BuildContext context, AppRouteDefinition route) {
    onDestinationSelected?.call(route);
    context.go(route.path);
  }
}
