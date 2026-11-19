import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.isPublished});
  final String label;
  final bool isPublished;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(label),
      avatar: Icon(isPublished ? Icons.check_circle : Icons.edit, size: 16),
      backgroundColor: isPublished ? scheme.primaryContainer : scheme.secondaryContainer,
      labelStyle: TextStyle(color: isPublished ? scheme.onPrimaryContainer : scheme.onSecondaryContainer, fontWeight: FontWeight.w600),
    );
  }
}
