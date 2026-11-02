import 'package:flutter/widgets.dart';

/// Imperative navigation helpers used by app features.
///
/// `go` replaces the current route stack, while `push` adds a route that can
/// be popped to return to the current page.
extension AppNavigation on BuildContext {
  void go(String location) {
    Navigator.of(
      this,
    ).pushNamedAndRemoveUntil<void>(location, (Route<dynamic> route) => false);
  }

  Future<T?> push<T extends Object?>(String location) {
    return Navigator.of(this).pushNamed<T>(location);
  }
}
