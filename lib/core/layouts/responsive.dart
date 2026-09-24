// import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';

import 'layout/layout_scope.dart';

export 'layout/layout_scope.dart'
    show LayoutBreakpoint, kDesktopBreakpoint, kTabletBreakpoint;

enum ScreenSize { mobile, tablet, desktop }

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    this.mobile,
    this.tablet,
    required this.desktop,
  });

  final Widget? mobile;

  final Widget? tablet;

  final Widget desktop;

  static ScreenSize screenSizeOf(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= kDesktopBreakpoint) return ScreenSize.desktop;
    if (w >= kTabletBreakpoint) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  static LayoutBreakpoint of(BuildContext context) {
    final scope = MainLayoutScope.maybeOf(context);

    if (scope != null) return scope.breakpoint;
    final w = MediaQuery.sizeOf(context).width;
    if (w >= kDesktopBreakpoint) return LayoutBreakpoint.desktop;
    if (w >= kTabletBreakpoint) return LayoutBreakpoint.tablet;
    return LayoutBreakpoint.mobile;
  }

  static bool isMobile(BuildContext context) =>
      of(context) == LayoutBreakpoint.mobile;

  static bool isTablet(BuildContext context) =>
      of(context) == LayoutBreakpoint.tablet;

  static bool isDesktop(BuildContext context) =>
      of(context) == LayoutBreakpoint.desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        if (w >= kDesktopBreakpoint) return desktop;
        if (w >= kTabletBreakpoint) return tablet ?? desktop;
        return mobile ?? desktop;
      },
    );
  }
}

class ExpandedBox extends StatelessWidget {
  const ExpandedBox({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SizedBox.expand(child: child);
}
