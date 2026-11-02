import 'package:flutter/material.dart' hide IconButton, Theme, Tooltip;
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/components/tooltip.dart';

class TooltipButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonVariant? variant;
  final ButtonSize? size;

  const TooltipButton({
    super.key,
    required this.label,
    this.onPressed,
    required this.child,
    this.variant,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      semanticLabel: label,
      tooltip: (BuildContext context) => Text(label),
      waitDuration: const Duration(milliseconds: 300),
      child: Button(
        variant: variant ?? ButtonVariant.primary,
        size: size ?? ButtonSize.md,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
