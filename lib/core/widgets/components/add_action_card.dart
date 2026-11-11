import 'package:flutter/widgets.dart';

import 'package:ud_sass_app/core/widgets/components/ink_well.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/components/card.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/lucide_icons.dart';
import 'package:ud_sass_app/ui/dashcn/src/theme/theme.dart';

class AddActionCard extends StatelessWidget {
  const AddActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.icon = LucideIcons.plus,
    this.showButton = true,
    this.buttonLabel,
    this.control,
  });

  final String title;
  final String description;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? control;

  /// Show or hide the outlined icon button.
  final bool showButton;

  /// Optional text displayed inside the button.
  final String? buttonLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colors;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWellWrapper(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showButton)
                  Button(
                    variant: ButtonVariant.outline,
                    size: ButtonSize.icon,
                    onPressed: onTap,
                    child: Icon(icon),
                  )
                else
                  Icon(icon, size: 28, color: colorScheme.accentForeground),

                const SizedBox(height: 14),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).typography.extraBold.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.accentForeground,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).typography.small.copyWith(
                    color: colorScheme.mutedForeground,
                  ),
                ),

                if (buttonLabel != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    buttonLabel!,
                    style: Theme.of(context).typography.small.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
