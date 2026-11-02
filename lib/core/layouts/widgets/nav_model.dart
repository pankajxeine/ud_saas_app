import 'package:flutter/material.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/bootstrap_icons.dart';

class NavItem {
  const NavItem({required this.label, required this.icon, required this.route});

  final String label;
  final String route;
  final IconData icon;

  static const kNavItems = <NavItem>[
    NavItem(label: 'Dashboard', icon: BootstrapIcons.dash, route: '/main'),
    NavItem(label: 'Tasks', icon: BootstrapIcons.list, route: '/tasks'),
    NavItem(label: 'Apps', icon: BootstrapIcons.blockquoteLeft, route: '/apps'),
    NavItem(label: 'Team', icon: BootstrapIcons.person, route: '/users'),
    NavItem(label: 'Settings', icon: BootstrapIcons.tools, route: '/settings'),
  ];
}
