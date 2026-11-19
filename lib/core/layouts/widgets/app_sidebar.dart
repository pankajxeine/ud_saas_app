import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/app_route_registry.dart';
import '../../navigation/app_route_definition.dart';
import '../../theme/app_theme.dart';

class AppNavDrawer extends StatelessWidget {
  const AppNavDrawer({super.key, this.routes = const []});

  final List<AppRouteDefinition> routes;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: AppSidebar(
          routesList: routes,
          currentRoute: GoRouterState.of(context).uri.path,
          onNavigate: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    this.routesList = const [],
    this.collapsed = false,
    this.currentRoute = '/',
    this.onNavigate,
    this.onToggle,
  });

  final bool collapsed;
  final String currentRoute;
  final VoidCallback? onNavigate;
  final VoidCallback? onToggle;
  final List<AppRouteDefinition> routesList;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routes = AppRouteRegistry.sidebarRoutes(routesList);
    print("route list : $routes");
    final groupedRoutes = _groupRoutes(routes);

    return Material(
      color: theme.colorScheme.surface,
      child: Container(
        width: collapsed ? 72 : 256,
        // decoration: BoxDecoration(
        //   gradient: Theme.of(
        //     context,
        //   ).extension<AppThemeExtension>()!.appBarGradient,
        // ),
        child: Column(
          children: [
            // _buildHeader(context),
            // const Divider(height: 1),
            Expanded(
              child: routes.isEmpty
                  ? _buildEmptyState(context)
                  : ListView(
                      children: [
                        for (final entry in groupedRoutes.entries)
                          _buildSection(context, entry.key, entry.value),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Group routes by section
  // ---------------------------------------------------------------------------

  LinkedHashMap<String?, List<AppRouteDefinition>> _groupRoutes(
    List<AppRouteDefinition> routes,
  ) {
    final grouped = LinkedHashMap<String?, List<AppRouteDefinition>>();

    for (final route in routes) {
      final section = route.section;

      grouped.putIfAbsent(section, () => []);
      grouped[section]!.add(route);
    }

    return grouped;
  }

  // ---------------------------------------------------------------------------
  // Section
  // ---------------------------------------------------------------------------

  Widget _buildSection(
    BuildContext context,
    String? section,
    List<AppRouteDefinition> routes,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!collapsed && section != null && section.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              section,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        for (final route in routes)
          _NavigationTile(
            collapsed: collapsed,
            selected: AppRouteRegistry.isActive(route, currentRoute),
            icon: IconData(route.icon, fontFamily: 'MaterialIcons'),
            //icon: route.icon ?? Icons.circle_outlined,
            selectedIcon: IconData(
              route.selectedIcon,
              fontFamily: 'MaterialIcons',
            ),
            label: route.label ?? '',
            onTap: () => _navigate(context, route),
          ),
      ],
    );
  }
  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context) {
    if (collapsed) return const SizedBox.shrink();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No navigation items available',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _navigate(BuildContext context, AppRouteDefinition route) {
    onNavigate?.call();
    context.go(route.path);
  }
}

// =============================================================================
// Navigation Tile
// =============================================================================

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.collapsed,
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final bool collapsed;
  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final activeIcon = selected ? selectedIcon : icon;
    print("activeIcon : $activeIcon, selected : $selected");

    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Tooltip(
          message: label,
          child: Material(
            color: selected ? colors.secondaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: SizedBox(
                height: 48,
                width: 56,
                child: Center(
                  child: Semantics(
                    label: label,
                    selected: selected,
                    button: true,
                    child: Icon(
                      activeIcon,
                      color: selected
                          ? colors.onSecondaryContainer
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ListTile(
      selected: selected,
      selectedTileColor: colors.secondaryContainer,
      selectedColor: colors.onSecondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(activeIcon),
      title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
      onTap: onTap,
    );
  }
}
