import 'package:flutter/material.dart';

class StatisticsCard extends StatelessWidget {
  const StatisticsCard({super.key, required this.title, required this.value, required this.icon});
  final String title; final String value; final IconData icon;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
      Container(width: 46, height: 46, decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: scheme.onPrimaryContainer)),
      const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))]))
    ])));
  }
}
