import 'package:flutter/material.dart' hide Theme;
import 'package:ud_sass_app/ui/dashcn/theme.dart';

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
    final ThemeColors colors = Theme.of(context).colors;
    Widget header;
    final Widget heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).typography.h2.copyWith(
            color: colors.mutedForeground,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(
              context,
            ).typography.small.copyWith(color: colors.mutedForeground),
          ),
        ],
      ],
    );

    if (compact) {
      header = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (actions != null) ...<Widget>[
            const SizedBox(height: 14),
            Align(alignment: Alignment.centerRight, child: actions),
          ],
        ],
      );
    } else {
      header = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[heading, if (actions != null) actions!],
      );
    }

    return Padding(
      padding: EdgeInsetsGeometry.only(
        bottom: 8,
        top: 8,
        left: compact ? 0 : 8,
        right: compact ? 0 : 8,
      ),
      child: header,
    );
  }
}
