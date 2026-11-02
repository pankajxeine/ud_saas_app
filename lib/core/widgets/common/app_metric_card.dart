import 'package:flutter/material.dart' hide Theme, Card;
import 'package:ud_sass_app/ui/dashcn/components/card.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';

class AppMetricCard extends StatelessWidget {
  const AppMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return SizedBox(
      width: 220,
      child: Card(
        padding: const EdgeInsets.all(16),
        borderWidth: 1,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).typography.small.copyWith(color: colors.mutedForeground),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: Theme.of(
                      context,
                    ).typography.x2Large.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
