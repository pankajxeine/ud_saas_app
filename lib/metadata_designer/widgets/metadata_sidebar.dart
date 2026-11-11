import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';

class MetadataSidebar extends material.StatelessWidget {
  final String selectedSection;
  final ValueChanged<String> onSectionSelected;

  const MetadataSidebar({
    super.key,
    required this.selectedSection,
    required this.onSectionSelected,
  });

  static const List<_SidebarItem> _items = [
    _SidebarItem(
      id: 'general',
      title: 'General',
      subtitle: 'Entity information',
      icon: material.Icons.settings_outlined,
    ),
    _SidebarItem(
      id: 'fields',
      title: 'Fields',
      subtitle: 'Manage metadata fields',
      icon: material.Icons.view_list_outlined,
    ),
    _SidebarItem(
      id: 'field-properties',
      title: 'Field Properties',
      subtitle: 'Configure selected field',
      icon: material.Icons.tune_outlined,
    ),
    _SidebarItem(
      id: 'field-validations',
      title: 'Validations',
      subtitle: 'Field validation rules',
      icon: material.Icons.rule_outlined,
    ),
    _SidebarItem(
      id: 'field-permissions',
      title: 'Permissions',
      subtitle: 'Field access control',
      icon: material.Icons.lock_outline,
    ),
    _SidebarItem(
      id: 'reference',
      title: 'References',
      subtitle: 'Lookup configuration',
      icon: material.Icons.link_outlined,
    ),
    _SidebarItem(
      id: 'api',
      title: 'API',
      subtitle: 'Endpoint configuration',
      icon: material.Icons.api_outlined,
    ),
    _SidebarItem(
      id: 'grid',
      title: 'Grid & Search',
      subtitle: 'List and filter settings',
      icon: material.Icons.table_chart_outlined,
    ),
    _SidebarItem(
      id: 'detail',
      title: 'Detail View',
      subtitle: 'Detail page configuration',
      icon: material.Icons.article_outlined,
    ),
    _SidebarItem(
      id: 'preview',
      title: 'Preview',
      subtitle: 'Preview metadata',
      icon: material.Icons.visibility_outlined,
    ),
    _SidebarItem(
      id: 'json',
      title: 'JSON Editor',
      subtitle: 'Edit raw metadata',
      icon: material.Icons.code,
    ),
  ];

  @override
  material.Widget build(material.BuildContext context) {
    return material.Container(
      color: material.Theme.of(context).colorScheme.surface,
      child: material.Column(
        crossAxisAlignment: material.CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const material.Divider(height: 1),
          material.Expanded(
            child: material.ListView.builder(
              padding: const material.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];

                return _buildItem(context, item);
              },
            ),
          ),
          const material.Divider(height: 1),
          _buildFooter(context),
        ],
      ),
    );
  }

  material.Widget _buildHeader(material.BuildContext context) {
    return material.Padding(
      padding: const material.EdgeInsets.all(16),
      child: material.Column(
        crossAxisAlignment: material.CrossAxisAlignment.start,
        children: [
          material.Text(
            'Metadata Designer',
            style: material.Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: material.FontWeight.w700,
            ),
          ),
          const material.SizedBox(height: 4),
          material.Text(
            'Configure your entity',
            style: material.Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: material.Colors.grey),
          ),
        ],
      ),
    );
  }

  material.Widget _buildItem(material.BuildContext context, _SidebarItem item) {
    final bool selected = selectedSection == item.id;

    final colorScheme = material.Theme.of(context).colorScheme;

    return material.Padding(
      padding: const material.EdgeInsets.only(bottom: 4),
      child: material.Material(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.10)
            : material.Colors.transparent,
        borderRadius: material.BorderRadius.circular(8),
        child: material.InkWell(
          borderRadius: material.BorderRadius.circular(8),
          onTap: () => onSectionSelected(item.id),
          child: material.Padding(
            padding: const material.EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: material.Row(
              children: [
                material.Icon(
                  item.icon,
                  size: 19,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const material.SizedBox(width: 10),
                material.Expanded(
                  child: material.Column(
                    crossAxisAlignment: material.CrossAxisAlignment.start,
                    children: [
                      material.Text(
                        item.title,
                        maxLines: 1,
                        overflow: material.TextOverflow.ellipsis,
                        style: material.TextStyle(
                          fontSize: 13,
                          fontWeight: selected
                              ? material.FontWeight.w600
                              : material.FontWeight.w500,
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                      const material.SizedBox(height: 2),
                      material.Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: material.TextOverflow.ellipsis,
                        style: material.TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  material.Icon(
                    material.Icons.chevron_right,
                    size: 18,
                    color: colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  material.Widget _buildFooter(material.BuildContext context) {
    return material.Padding(
      padding: const material.EdgeInsets.all(12),
      child: material.Row(
        children: [
          const material.Icon(
            material.Icons.info_outline,
            size: 16,
            color: material.Colors.grey,
          ),
          const material.SizedBox(width: 8),
          material.Expanded(
            child: material.Text(
              'Metadata configuration',
              style: material.Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: material.Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final String id;
  final String title;
  final String subtitle;
  final material.IconData icon;

  const _SidebarItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
