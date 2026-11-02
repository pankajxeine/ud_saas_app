import 'package:flutter/widgets.dart';

/// Provides the current app route to descendants such as the sidebar.
class AppRouteLocation extends InheritedWidget {
  const AppRouteLocation({
    super.key,
    required this.location,
    required super.child,
  });

  final String location;

  static String? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppRouteLocation>()?.location;

  @override
  bool updateShouldNotify(AppRouteLocation oldWidget) =>
      oldWidget.location != location;
}
