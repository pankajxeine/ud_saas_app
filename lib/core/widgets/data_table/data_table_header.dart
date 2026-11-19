import 'package:flutter/material.dart';

class DataTableHeader extends StatelessWidget {
  const DataTableHeader({super.key, required this.title, this.subtitle, this.actions, this.compact = false});
  final String title; final String? subtitle; final Widget? actions; final bool compact;
  @override Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final heading = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w700)), if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant))]]);
    final header = compact ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (actions != null) ...[const SizedBox(height: 14), Align(alignment: Alignment.centerRight, child: actions)]]) : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [heading, if (actions != null) actions!]);
    return Padding(padding: EdgeInsets.only(bottom: 8, top: 8, left: compact ? 0 : 8, right: compact ? 0 : 8), child: header);
  }
}
