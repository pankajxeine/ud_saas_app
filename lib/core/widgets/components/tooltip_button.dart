import 'package:ud_sass_app/ui/shadcn/components/control/button/button.dart';
import 'package:ud_sass_app/ui/shadcn/components/layout/flex/flex.dart';
import 'package:ud_sass_app/ui/shadcn/components/overlay/tooltip/tooltip.dart';

class TooltipButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback? onPressed;
  final Widget icon;

  const TooltipButton({
    super.key,
    required this.tooltip,
    this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      tooltip: TooltipContainer(
        child: Text(tooltip),
      ),
      waitDuration: const Duration(milliseconds: 300),
      child: IconButton.outline(
        onPressed: onPressed,
        icon: icon,
      ),
    );
  }
}
