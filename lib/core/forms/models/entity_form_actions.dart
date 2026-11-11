import 'package:flutter/widgets.dart';

import '../../../../ui/dashcn/components/button.dart';
import 'entity_meta.dart';

class EntityFormActions extends StatelessWidget {
  const EntityFormActions({
    super.key,
    required this.mode,
    required this.isSubmitting,
    required this.submitLabel,
    required this.resetLabel,
    required this.showSubmitButton,
    required this.showResetButton,
    required this.onSubmit,
    required this.onReset,
  });

  final EntityMode mode;
  final bool isSubmitting;

  final String submitLabel;
  final String resetLabel;

  final bool showSubmitButton;
  final bool showResetButton;

  final VoidCallback onSubmit;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    if (mode == EntityMode.view) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showResetButton)
          Button(
            variant: ButtonVariant.outline,
            onPressed: isSubmitting ? null : onReset,
            child: Text(resetLabel),
          ),

        if (showResetButton && showSubmitButton) const SizedBox(width: 12),

        if (showSubmitButton)
          Button(
            variant: ButtonVariant.primary,
            onPressed: isSubmitting ? null : onSubmit,
            child: Text(isSubmitting ? 'Saving...' : submitLabel),
          ),
      ],
    );
  }
}
