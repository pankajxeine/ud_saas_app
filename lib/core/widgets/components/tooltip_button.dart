import 'package:flutter/material.dart';

class TooltipButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  /// Retained as untyped compatibility parameters for older call sites.
  /// Material styling is controlled through [style].
  final Object? variant;
  final Object? size;

  const TooltipButton({
    super.key,
    required this.label,
    this.onPressed,
    required this.child,
    this.style,
    this.variant,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 300),
      child: FilledButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    );
  }
}
