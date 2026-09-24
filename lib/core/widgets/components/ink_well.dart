import 'package:flutter/material.dart';

class InkWellWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final Color? splashColor;
  final Color? highlightColor;

  const InkWellWrapper({
    Key? key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.borderRadius,
    this.splashColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      splashColor: splashColor ??
          theme.colorScheme.primary.withValues(alpha: 0.2), // ✅ new API
      highlightColor: highlightColor ??
          theme.colorScheme.primary.withValues(alpha: 0.1), // ✅ new API
      child: child,
    );
  }
}
