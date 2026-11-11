import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';

import 'package:ud_sass_app/core/widgets/components/ink_well.dart';
import 'package:ud_sass_app/ui/dashcn/components/list_tile.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/avatar/avatar.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/badge/badge.dart';
import 'package:ud_sass_app/ui/dashcn/components/card.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/lucide_icons.dart';
import 'package:ud_sass_app/ui/dashcn/src/theme/theme.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/divider/divider.dart';

import '../../models/metadata_module.dart';

import '../../widgets/components/status_chip.dart';

class ModuleCard extends StatelessWidget {
  const ModuleCard({super.key, required this.module, required this.onTap});

  final MetaModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colors;

    final entity = module.moduleCode.toString();

    final title = module.moduleName.toString().isNotEmpty
        ? module.moduleName.toString()
        : _toTitle(entity);

    final table = module.tableName.toString();

    final latestVersion = module.metaModuleVersions.firstWhereOrNull(
      (v) => v.versionNo == module.currentVersion,
    );

    final draftVersionCount = module.metaModuleVersions
        .where((v) => v.publicationStatus != 'published')
        .length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWellWrapper(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    // densityTokens: DensityTokens.compact,
                    leading: const Avatar(initials: 'IB', size: 40),
                    title: Text(
                      title,
                      style: Theme.of(context).typography.extraBold.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.accentForeground,
                      ),
                    ),
                    subtitle: Text(
                      module.apiBasePath,
                      style: Theme.of(context).typography.extraBold.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.accentForeground,
                      ),
                    ),
                  ),
                ),
                // Badge(
                //   variant: BadgeVariant.destructive,
                //   leading: const Icon(LucideIcons.check, size: 12),
                //   child: Text(latestVersion?.publicationStatus ?? 'draft'),
                // ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Icon(
                  LucideIcons.chartColumnBig,
                  size: 16,
                  color: colorScheme.mutedForeground,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    table,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).typography.semiBold.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.accentForeground,
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

  String _toTitle(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((item) => item.isNotEmpty)
        .map((item) => '${item[0].toUpperCase()}${item.substring(1)}')
        .join(' ');
  }
}
