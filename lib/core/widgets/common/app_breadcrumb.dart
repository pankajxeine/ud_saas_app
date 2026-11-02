import 'package:flutter/material.dart' hide Theme;
import 'package:ud_sass_app/core/navigation/app_navigation.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';

class AppBreadcrumbItem {
  const AppBreadcrumbItem({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

class AppBreadcrumb extends StatelessWidget {
  const AppBreadcrumb({
    super.key,
    required this.items,
    this.current,
    this.homeLabel = 'Home',
  });

  final List<AppBreadcrumbItem> items;
  final String? current;
  final String homeLabel;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colors.mutedForeground;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5,
      children: [
        Button(
          variant: ButtonVariant.link,
          onPressed: () => context.go('/'),
          child: Text(homeLabel),
        ),
        for (final item in items) ...[
          Icon(Icons.chevron_right, size: 16, color: muted),
          Button(
            variant: ButtonVariant.link,
            onPressed: item.onPressed,
            child: Text(item.label),
          ),
        ],
        if (current != null) ...[
          Icon(Icons.chevron_right, size: 16, color: muted),
          Text(
            current!,
            style: Theme.of(context).typography.small.copyWith(color: muted),
          ),
        ],
      ],
    );
  }
}
