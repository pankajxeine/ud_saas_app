import 'package:flutter/material.dart' hide Theme;
import 'package:ud_sass_app/ui/dashcn/theme.dart' as dashcn;

class DataTableHeader extends StatelessWidget {
  const DataTableHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final Widget? actions;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dashcn.ThemeColors colors = dashcn.Theme.of(context).colors;
    final Widget heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: dashcn.Theme.of(
            context,
          ).typography.h2.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: dashcn.Theme.of(
              context,
            ).typography.small.copyWith(color: colors.mutedForeground),
          ),
        ],
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          heading,
          if (actions != null) ...<Widget>[
            const SizedBox(height: 14),
            Align(alignment: Alignment.centerRight, child: actions),
          ],
        ],
      );
    }

    return Row(
      children: <Widget>[
        Expanded(child: heading),
        if (actions != null) actions!,
      ],
    );
  }
}
