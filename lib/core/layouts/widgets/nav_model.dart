import 'package:flutter/material.dart';

class NavItem {
  const NavItem({required this.label, required this.icon, required this.route});

  final String label;
  final String route;
  final IconData icon;

  static const kNavItems = <NavItem>[
    NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/main'),
    NavItem(label: 'Tasks', icon: Icons.task_outlined, route: '/tasks'),
    NavItem(label: 'Apps', icon: Icons.apps_outlined, route: '/apps'),
    NavItem(label: 'Team', icon: Icons.people_outline, route: '/users'),
    NavItem(label: 'Settings', icon: Icons.settings_outlined, route: '/settings'),
  ];
}
