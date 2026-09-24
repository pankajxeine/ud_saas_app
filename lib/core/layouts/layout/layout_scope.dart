import 'package:flutter/material.dart';

const double kDesktopBreakpoint = 1024.0;
const double kTabletBreakpoint = 640.0;

enum LayoutBreakpoint { mobile, tablet, desktop }

class MainLayoutScope extends InheritedWidget {
  const MainLayoutScope({
    super.key,
    required this.breakpoint,
    required this.openDrawer,
    required super.child,
  });
  final LayoutBreakpoint breakpoint;
  final VoidCallback openDrawer;

  bool get isMobile => breakpoint == LayoutBreakpoint.mobile;
  bool get isTablet => breakpoint == LayoutBreakpoint.tablet;
  bool get isDesktop => breakpoint == LayoutBreakpoint.desktop;

  static MainLayoutScope of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<MainLayoutScope>();
    assert(result != null, 'No MainLayoutScope found in context');
    return result!;
  }

  static MainLayoutScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainLayoutScope>();

  @override
  bool updateShouldNotify(MainLayoutScope old) => breakpoint != old.breakpoint;
}
