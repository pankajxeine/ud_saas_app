import 'package:flutter/material.dart';

class MetadataSidebar extends StatelessWidget {
  const MetadataSidebar({
    super.key,
    required this.selectedSection,
    required this.onSectionSelected,
    this.compact = false,
  });

  final String selectedSection;
  final ValueChanged<String> onSectionSelected;
  final bool compact;

  static const List<_SidebarItem> _items = [
    _SidebarItem(
      id: 'general',
      title: 'General',
      subtitle: 'Entity information',
      icon: Icons.settings_outlined,
    ),
    _SidebarItem(
      id: 'fields',
      title: 'Fields',
      subtitle: 'Manage metadata fields',
      icon: Icons.view_list_outlined,
    ),
    _SidebarItem(
      id: 'sections',
      title: 'Sections',
      subtitle: 'Manage form sections',
      icon: Icons.tab_outlined,
    ),
    _SidebarItem(
      id: 'api',
      title: 'API',
      subtitle: 'Endpoint configuration',
      icon: Icons.api_outlined,
    ),
    _SidebarItem(
      id: 'grid',
      title: 'Grid & Search',
      subtitle: 'List and filter settings',
      icon: Icons.table_chart_outlined,
    ),
    _SidebarItem(
      id: 'preview',
      title: 'Preview',
      subtitle: 'Preview metadata',
      icon: Icons.visibility_outlined,
    ),
    _SidebarItem(
      id: 'json',
      title: 'JSON Editor',
      subtitle: 'Edit raw metadata',
      icon: Icons.code,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return compact
        ? _buildCompactNavigation(context)
        : _buildDesktopNavigation(context);
  }

  // ------------------------------------------------------------
  // DESKTOP SIDEBAR
  // ------------------------------------------------------------

  Widget _buildDesktopNavigation(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 240,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return _buildDesktopItem(context, _items[index]);
          },
        ),
      ),
    );
  }

  Widget _buildDesktopItem(BuildContext context, _SidebarItem item) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = selectedSection == item.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: selected
            ? scheme.primaryContainer.withValues(alpha: 0.55)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onSectionSelected(item.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: selected ? scheme.primary : scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.chevron_right, size: 18, color: scheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // TABLET / MOBILE COLLAPSED SIDEBAR
  // ------------------------------------------------------------

  Widget _buildCompactNavigation(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 58,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];

            return _buildCompactItem(context, item, selectedSection == item.id);
          },
        ),
      ),
    );
  }

  Widget _buildCompactItem(
    BuildContext context,
    _SidebarItem item,
    bool selected,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Tooltip(
        message: item.title,
        preferBelow: false,
        child: Material(
          color: selected ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: () => onSectionSelected(item.id),
            child: SizedBox(
              width: 46,
              height: 42,
              child: Center(
                child: Icon(
                  item.icon,
                  size: 20,
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarItem {
  const _SidebarItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
