import 'package:flutter/material.dart' hide Theme;
import 'package:ud_sass_app/ui/dashcn/theme.dart';

class AppPageHeading extends StatelessWidget {
  const AppPageHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.icon,
    this.accent,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData? icon;
  final Color? accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (accent ?? colors.primary).withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accent ?? colors.primary),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: TextStyle(
                  color: accent ?? colors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: Theme.of(
                  context,
                ).typography.h3.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: Theme.of(
                  context,
                ).typography.p.copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}
