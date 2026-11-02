import 'package:flutter/widgets.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/bootstrap_icons.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';

// import '../../../routes/app_routes_constants.dart';
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
    final cs = Theme.of(context).colors;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: cs.background),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            if (isMobile) ...[
              Button(
                onPressed: MainLayoutScope.of(context).openDrawer,
                size: ButtonSize.icon,
                variant: ButtonVariant.outline,
                child: const Icon(BootstrapIcons.list),
              ),
              const SizedBox(width: 12),
            ],
            if (!isMobile && onToggle != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Button(
                  onPressed: onToggle,
                  size: ButtonSize.icon,
                  variant: ButtonVariant.outline,
                  child: Icon(
                    collapsed ? BootstrapIcons.listNested : BootstrapIcons.list,
                    size: 16,
                  ),
                ),
              ),
            if (constraints.maxWidth >= 320)
              Expanded(
                child: Text(
                  "test app",
                  style: Theme.of(context).typography.h4,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const Spacer(),
            Button(
              onPressed: () {},
              size: ButtonSize.icon,
              variant: ButtonVariant.outline,
              child: const Icon(BootstrapIcons.bell),
            ),
            const SizedBox(width: 8),
            Button(
              onPressed: () {},
              size: ButtonSize.icon,
              variant: ButtonVariant.outline,
              child: const Icon(BootstrapIcons.gear),
            ),
          ],
        ),
      ),
    );
  }
}
