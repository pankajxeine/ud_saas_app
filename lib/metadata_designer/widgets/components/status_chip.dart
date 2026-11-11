import 'package:flutter/widgets.dart';
import 'package:ud_sass_app/ui/dashcn/src/theme/theme.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.isPublished});

  final String label;
  final bool isPublished;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPublished
            ? colorScheme.primaryForeground
            : colorScheme.secondaryForeground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).typography.textSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: isPublished
              ? colorScheme.primaryForeground
              : colorScheme.secondaryForeground,
        ),
      ),
    );
  }
}
