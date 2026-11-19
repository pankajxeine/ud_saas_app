import 'package:flutter/material.dart';
import '../../models/metadata_module_version.dart';

class ModuleVersionCard extends StatelessWidget {
  const ModuleVersionCard({super.key, required this.version, this.onTap});
  final MetaModuleVersion version; final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final published = version.publicationStatus.toLowerCase() == 'published';
    return Card(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('v${version.versionNo}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), Chip(label: Text(published ? 'Published' : 'Draft'))]),
      const Divider(), Row(children: [Icon(Icons.schedule, size: 16, color: scheme.primary), const SizedBox(width: 6), Expanded(child: Text(version.publishedAt ?? version.draftAt ?? '', overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)))])
    ]))));
  }
}
