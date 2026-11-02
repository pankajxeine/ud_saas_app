import 'package:flutter/material.dart' hide Theme;
import 'package:ud_sass_app/ui/dashcn/components/drawer.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/bootstrap_icons.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';

final profile = [
  (title: 'Name', value: 'Alexandru'),
  (title: 'Username', value: 'nank1ro'),
];

class HeaderTrailingSheet extends StatelessWidget {
  const HeaderTrailingSheet({
    super.key,
    required this.body,
    required this.icon,
    this.side = OverlayPosition.right,
    // this.shape = ButtonShape.circle,
  });

  final Widget body;
  final Icon icon;
  final OverlayPosition side;
  // final ButtonShape shape;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    void open(BuildContext context) {
      openSheet(
        position: side,
        context: context,
        builder: (context) {
          // Ensure a fresh subtree for each sheet open so disposed scroll
          // positions/controllers from prior overlays are not reused.
          return Container(
            constraints:
                side == OverlayPosition.left || side == OverlayPosition.right
                ? const BoxConstraints(maxWidth: 512)
                : null,
            // title: const Text('Edit Profile'),
            // description: const Text(
            //     "Make changes to your profile here. Click save when you're done"),
            // actions: const [
            //   ShadButton(child: Text('Save changes')),
            // ],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: profile
                    .map(
                      (p) => Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.title,
                              textAlign: TextAlign.end,
                              style: theme.typography.small,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Expanded(
                          //   flex: 5,
                          //   child: ShadInput(initialValue: p.value),
                          // ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        },
        // Slide in from the end (right on LTR).
      );
    }

    return OutlinedButton(
      onPressed: () => open(context),
      child: const Icon(BootstrapIcons.rocket),
    );
  }
}
