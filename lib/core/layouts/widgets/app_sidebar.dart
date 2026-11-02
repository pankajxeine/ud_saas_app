import 'package:flutter/material.dart'
    hide Theme, ButtonStyle, NavigationBar, NavigationRail;
import 'package:ud_sass_app/core/navigation/app_navigation.dart';
import 'package:ud_sass_app/core/navigation/app_route_location.dart';
import 'package:ud_sass_app/i10n/i10n.dart';
import 'package:ud_sass_app/routes/app_routes_constants.dart';
import 'package:ud_sass_app/ui/dashcn/components/navigation_bar.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart' as dashcn;

import 'app_logo.dart';

class AppNavDrawer extends StatelessWidget {
  const AppNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final dashcn.ThemeData theme = dashcn.Theme.of(context);
    final String currentRoute = AppRouteLocation.maybeOf(context) ?? '';

    return Drawer(
      backgroundColor: theme.colors.card,
      child: SafeArea(
        child: AppSidebar(
          currentRoute: currentRoute,
          onNavigate: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    this.collapsed = false,
    this.selected = 0,
    this.currentRoute = '',
    this.onNavigate,
    this.onToggle,
  });

  final bool collapsed;
  final int selected;
  final String currentRoute;
  final VoidCallback? onNavigate;
  final VoidCallback? onToggle;

  static final List<String> _paths = <String>[
    for (final group in ApplicationRoutesConstants.kNavGroups)
      if (group.items.isEmpty)
        group.path ?? ApplicationRoutesConstants.dashboard
      else
        for (final item in group.items)
          if (item.inSidebar) item.path,
  ];

  int _indexForRoute(String route) {
    final String normalized = route.split('?').first;
    final String path = normalized.length > 1
        ? normalized.replaceFirst(RegExp(r'/+$'), '')
        : normalized;
    final int exactIndex = _paths.indexOf(path);
    if (exactIndex >= 0) {
      return exactIndex;
    }

    int bestIndex = -1;
    int bestLength = 0;
    for (int index = 0; index < _paths.length; index += 1) {
      final String candidate = _paths[index];
      if (candidate != '/' &&
          path.startsWith('$candidate/') &&
          candidate.length > bestLength) {
        bestIndex = index;
        bestLength = candidate.length;
      }
    }
    return bestIndex >= 0 ? bestIndex : selected;
  }

  List<NavigationBarItem> _buildNavigationItems(S localization) {
    final List<NavigationBarItem> items = <NavigationBarItem>[];
    int routeIndex = 0;
    const List<NavGroup> groups = ApplicationRoutesConstants.kNavGroups;

    for (int groupIndex = 0; groupIndex < groups.length; groupIndex += 1) {
      final NavGroup group = groups[groupIndex];
      if (group.items.isEmpty) {
        items.add(
          NavigationItem(
            index: routeIndex++,
            label: Text(
              ApplicationRoutesConstants.navigationLabelFor(
                group.localizationKey,
                localization,
              ),
            ),
            child: Icon(group.icon ?? Icons.menu),
          ),
        );
      } else {
        items.add(
          NavigationLabel(
            child: Text(
              ApplicationRoutesConstants.navigationLabelFor(
                group.localizationKey,
                localization,
              ),
            ),
          ),
        );
        for (final NavItem item in group.items) {
          if (!item.inSidebar) {
            continue;
          }
          items.add(
            NavigationItem(
              index: routeIndex++,
              label: Text(
                ApplicationRoutesConstants.navigationLabelFor(
                  item.localizationKey,
                  localization,
                ),
              ),
              child: Icon(item.icon),
            ),
          );
        }
      }

      if (groupIndex < groups.length - 1) {
        items.add(const NavigationDivider());
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final dashcn.ThemeData theme = dashcn.Theme.of(context);
    final S localization = S.of(context)!;
    final bool isCollapsed = collapsed;

    return NavigationBar(
      container: NavigationContainerType.sidebar,
      constraints: BoxConstraints.tightFor(
        width: (isCollapsed ? 72 : 256) * theme.scaling,
      ),
      labelType: isCollapsed
          ? NavigationLabelType.tooltip
          : NavigationLabelType.expanded,
      labelPosition: NavigationLabelPosition.end,
      expanded: !isCollapsed,
      index: _indexForRoute(currentRoute),
      onSelected: (int index) {
        if (index < 0 || index >= _paths.length) {
          return;
        }
        onNavigate?.call();
        context.go(_paths[index]);
      },
      header: <Widget>[AppLogo(collapsed: isCollapsed)],
      children: _buildNavigationItems(localization),
    );
  }
}
