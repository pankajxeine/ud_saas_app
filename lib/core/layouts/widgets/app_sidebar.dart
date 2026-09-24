import 'package:flutter/material.dart' hide Theme, ButtonStyle, NavigationRail;
import 'package:go_router/go_router.dart';
import 'package:ud_sass_app/i10n/i10n.dart';
import 'package:ud_sass_app/routes/app_routes_constants.dart';
import 'package:ud_sass_app/ui/shadcn/components/control/button/_impl/styles/button_style_class.dart';
import 'package:ud_sass_app/ui/shadcn/components/control/button/_impl/extensions/button_style_extension.dart';
import 'package:ud_sass_app/ui/shadcn/components/display/text/text.dart';
import 'package:ud_sass_app/ui/shadcn/components/layout/outlined_container/outlined_container.dart';
import 'package:ud_sass_app/ui/shadcn/components/navigation/navigation_bar/navigation_bar.dart';

import 'package:ud_sass_app/ui/shadcn/shared/theme/theme.dart';

class AppNavDrawer extends StatelessWidget {
  const AppNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    String currentRoute = '';

    try {
      currentRoute = GoRouterState.of(context).matchedLocation;
    } catch (_) {}

    return Drawer(
        backgroundColor: cs.card,
        child: SafeArea(
            child: AppSidebar(
          currentRoute: currentRoute,
          onNavigate: () => Navigator.of(context).pop(),
        )));
  }
}

class AppSidebar extends StatefulWidget {
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

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  static const _sidebarRadius = BorderRadius.all(Radius.circular(8));

  late int _selected = widget.selected;

  NavigationItem _buildButton(String text, IconData icon) {
    return NavigationItem(
      label: Text(text),
      alignment: Alignment.topLeft,
      style: const ButtonStyle.ghost().withBorderRadius(
        borderRadius: _sidebarRadius,
      ),
      selectedStyle: const ButtonStyle.primaryIcon().withBorderRadius(
        borderRadius: _sidebarRadius,
      ),
      child: Icon(icon),
    );
  }

  NavigationLabel _buildLabel(String label) {
    return NavigationLabel(
      alignment: Alignment.topLeft,
      child: Text(label).semiBold().muted(),
    );
  }

  List<NavigationBarItem> _buildNavigationItems(S localization) {
    const groups = ApplicationRoutesConstants.kNavGroups;
    final items = <NavigationBarItem>[];

    for (var index = 0; index < groups.length; index++) {
      final group = groups[index];

      if (group.items.isEmpty) {
        items.add(_buildButton(
          ApplicationRoutesConstants.navigationLabelFor(
            group.localizationKey,
            localization,
          ),
          group.icon ?? Icons.menu,
        ));
      } else {
        items.add(_buildLabel(
          ApplicationRoutesConstants.navigationLabelFor(
            group.localizationKey,
            localization,
          ),
        ));
        for (final item in group.items) {
          if (item.inSidebar) {
            items.add(_buildButton(
              ApplicationRoutesConstants.navigationLabelFor(
                item.localizationKey,
                localization,
              ),
              item.icon,
            ));
          }
        }
      }

      if (index < groups.length - 1) {
        items.add(const NavigationDivider());
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = S.of(context)!;
    final navigationItems = _buildNavigationItems(localization);

    void onSelected(int value) {
      setState(() => _selected = value);
    }

    if (widget.collapsed) {
      return OutlinedContainer(
        borderRadius: _sidebarRadius,
        child: NavigationRail(
          backgroundColor: theme.colorScheme.card,
          labelType: NavigationLabelType.expanded,
          labelPosition: NavigationLabelPosition.end,
          alignment: NavigationRailAlignment.start,
          expanded: false,
          index: _selected,
          onSelected: onSelected,
          children: navigationItems,
        ),
      );
    }

    return OutlinedContainer(
      borderRadius: _sidebarRadius,
      child: NavigationSidebar(
        index: _selected,
        onSelected: onSelected,
        children: navigationItems,
      ),
    );
  }
}
