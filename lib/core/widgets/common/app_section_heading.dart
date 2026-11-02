import 'package:flutter/material.dart' hide Theme;
import 'package:ud_sass_app/ui/dashcn/theme.dart';

class AppSectionHeading extends StatelessWidget {
  const AppSectionHeading({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).typography.large.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: Theme.of(
              context,
            ).typography.small.copyWith(color: colors.mutedForeground),
          ),
      ],
    );
  }
}
