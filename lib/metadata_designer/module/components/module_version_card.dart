import 'package:flutter/widgets.dart';
import 'package:ud_sass_app/core/widgets/components/ink_well.dart';
import 'package:ud_sass_app/ui/dashcn/components/card.dart';
import 'package:ud_sass_app/ui/dashcn/components/chip.dart';
import 'package:ud_sass_app/ui/dashcn/components/divider.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/lucide_icons.dart';
import '../../models/metadata_module_version.dart';

class ModuleVersionCard extends StatelessWidget {
  const ModuleVersionCard({super.key, required this.version, this.onTap});

  final MetaModuleVersion version;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colors;

    final status = version.publicationStatus;
    final isPublished = status.toLowerCase() == 'published';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWellWrapper(
        onTap: onTap,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'v${version.versionNo}',
                  style: Theme.of(context).typography.large.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.mutedForeground,
                  ),
                ),
                Chip(
                  child: Text(
                    'Draft',
                    style: Theme.of(context).typography.small.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(LucideIcons.clock3, size: 15, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    version.publishedAt ?? version.draftAt ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).typography.small.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
