import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart' hide Theme;
import 'package:ud_sass_app/ui/shadcn/shared/theme/theme.dart';
import 'package:ud_sass_app/ui/shadcn/shared/icons/bootstrap_icons.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Box(
        height: 64,
        child: collapsed
            ? Center(
                child:
                    Icon(BootstrapIcons.activity, color: cs.primary, size: 12),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SideBySide(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(BootstrapIcons.activity, color: cs.primary, size: 18),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'App',
                          style: theme.typography.h4
                              .copyWith(color: cs.foreground),
                        ))
                  ],
                )));
  }
}
