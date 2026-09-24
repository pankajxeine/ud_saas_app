import 'package:flutter/material.dart' hide Theme;
import 'package:ud_sass_app/ui/shadcn/components/control/button/button.dart';
import 'package:ud_sass_app/ui/shadcn/shared/theme/theme.dart';

import '../layout/layout_scope.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.isMobile,
    this.collapsed = false,
    this.onToggle,
  });

  final bool isMobile;
  final VoidCallback? onToggle;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(bottom: BorderSide(color: cs.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            if (isMobile) ...[
              OutlineButton(
                onPressed: MainLayoutScope.of(context).openDrawer,
                child: const Icon(Icons.menu),
              ),
              const SizedBox(width: 12),
            ],
            if (!isMobile && onToggle != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlineButton(
                  onPressed: onToggle,
                  child: Icon(
                    collapsed ? Icons.menu_open : Icons.menu,
                    size: 16,
                  ),
                ),
              ),
            if (constraints.maxWidth >= 320)
              Expanded(
                child: Text(
                  'Workspace overview',
                  style: Theme.of(context).typography.h4,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const Spacer(),
            OutlineButton(
              onPressed: () {},
              child: const Icon(Icons.notifications_none_rounded),
            ),
            const SizedBox(width: 8),
            OutlineButton(
              onPressed: () {},
              child: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
