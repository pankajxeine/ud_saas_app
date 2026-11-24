import 'package:flutter/material.dart';

import '../layout/layout_scope.dart';
import '../../theme/app_theme.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.isMobile,
    this.collapsed = false,
    this.onToggle,

    // Page information
    this.title = 'UD SaaS',
    this.subtitle,
    this.leading,
    this.titleWidget,

    // Actions
    this.showSearch = true,
    this.showNotifications = true,
    this.notificationCount = 0,
    this.showSettings = true,
    this.showProfile = true,

    // Callbacks
    this.onSearch,
    this.onNotifications,
    this.onSettings,
    this.onProfile,
    this.onLogout,

    // Customization
    this.actions = const [],
    this.profileInitials = 'U',
    this.profileName = 'User',
    this.height = 68,
  });

  final bool isMobile;
  final bool collapsed;
  final VoidCallback? onToggle;

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? titleWidget;

  final bool showSearch;
  final bool showNotifications;
  final int notificationCount;
  final bool showSettings;
  final bool showProfile;

  final VoidCallback? onSearch;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final VoidCallback? onProfile;
  final VoidCallback? onLogout;

  final List<Widget> actions;

  final String profileInitials;
  final String profileName;

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 8),
        child: Row(
          children: [
            _buildLeading(context),

            const SizedBox(width: 12),

            Expanded(child: titleWidget ?? _buildTitle(context)),

            if (showSearch && !isMobile) ...[
              _buildSearchButton(context),
              const SizedBox(width: 8),
            ],

            ...actions,

            if (showNotifications) ...[
              _buildNotificationButton(context),
              const SizedBox(width: 4),
            ],

            if (showSettings && !isMobile) ...[
              _buildActionButton(
                context,
                icon: Icons.settings_outlined,
                tooltip: 'Settings',
                onPressed: onSettings,
              ),
              const SizedBox(width: 8),
            ],

            if (showProfile) _buildProfile(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (leading != null) return leading!;

    if (isMobile) {
      return IconButton(
        tooltip: 'Open navigation',
        onPressed: MainLayoutScope.of(context).openDrawer,
        icon: const Icon(Icons.menu_rounded),
      );
    }

    if (onToggle != null) {
      return IconButton(
        tooltip: collapsed ? 'Expand navigation' : 'Collapse navigation',
        onPressed: onToggle,
        icon: Icon(collapsed ? Icons.menu_open_rounded : Icons.menu_rounded),
      );
    }

    return const SizedBox(width: 8);
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
  }) {
    final colors = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: colors.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 21),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return _buildActionButton(
      context,
      icon: Icons.search_rounded,
      tooltip: 'Search',
      onPressed: onSearch,
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: 'Notifications',
      onPressed: onNotifications,
      style: IconButton.styleFrom(
        foregroundColor: colors.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Badge(
        isLabelVisible: notificationCount > 0,
        label: Text(
          notificationCount > 99 ? '99+' : notificationCount.toString(),
        ),
        child: const Icon(Icons.notifications_none_rounded, size: 21),
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return PopupMenuButton<String>(
      tooltip: 'Account menu',
      offset: const Offset(0, 48),
      onSelected: (value) {
        switch (value) {
          case 'profile':
            onProfile?.call();
            break;
          case 'settings':
            onSettings?.call();
            break;
          case 'logout':
            onLogout?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 19),
              SizedBox(width: 12),
              Text('My profile'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 19),
              SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
        ),
        if (onLogout != null) const PopupMenuDivider(),
        if (onLogout != null)
          const PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout_rounded, size: 19),
                SizedBox(width: 12),
                Text('Logout'),
              ],
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: colors.primaryContainer,
              child: Text(
                profileInitials,
                style: TextStyle(
                  color: colors.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 110),
                child: Text(
                  profileName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colors.onSurfaceVariant,
                size: 19,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
