import 'package:flutter/material.dart';

class AppIconTile extends StatelessWidget {
  const AppIconTile({super.key, required this.icon, required this.accent, this.size = 42});

  final IconData icon;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: size * .48, color: accent),
      );
}
