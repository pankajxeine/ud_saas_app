import 'package:flutter/material.dart' hide Theme;
import 'package:ud_sass_app/ui/dashcn/theme.dart';

import 'app_breadcrumb.dart';

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    required this.breadcrumbs,
    this.onAdd,
    this.addTooltip = 'Add new',
  });

  final String title;
  final List<AppBreadcrumbItem> breadcrumbs;
  final VoidCallback? onAdd;
  final String addTooltip;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).typography;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: typography.h3),
              const SizedBox(height: 6),
              AppBreadcrumb(items: breadcrumbs, current: title),
            ],
          ),
        ),
        if (onAdd != null) ...[
          const SizedBox(width: 12),
          Tooltip(
            message: addTooltip,
            child: IconButton.filled(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
