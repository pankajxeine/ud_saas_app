import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/app_route_registry.dart';
import '../../navigation/app_route_definition.dart';

class AppBreadcrumb extends StatelessWidget {
  const AppBreadcrumb({
    super.key,
    required this.currentRoute,
    required this.routes,
    this.compact = false,
  });

  final String currentRoute;
  final bool compact;
  final List<AppRouteDefinition> routes;

  @override
  Widget build(BuildContext context) {
    final items = AppRouteRegistry.breadcrumbs(routes, currentRoute);

    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (compact) {
      return Text(
        items.last.label ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 17,
                  color: colors.onSurfaceVariant,
                ),
              ),
            if (index == items.length - 1)
              Text(
                items[index].label ?? '',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              )
            else
              InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () {
                  context.go(items[index].path);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    items[index].label ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
