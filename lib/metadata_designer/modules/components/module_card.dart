import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../models/metadata_module.dart';

class ModuleCard extends StatefulWidget {
  const ModuleCard({super.key, required this.module, required this.onTap});

  final MetaModule module;
  final VoidCallback onTap;

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final module = widget.module;
    final code = module.moduleCode.toString();
    final moduleName = module.moduleName.toString();

    final title = moduleName.trim().isNotEmpty
        ? moduleName.trim()
        : _title(code);

    final latest = module.metaModuleVersions.firstWhereOrNull(
      (version) => version.versionNo == module.currentVersion,
    );

    final isCompact = MediaQuery.sizeOf(context).width < 600;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? scheme.primary.withValues(alpha: 0.45)
                : scheme.outlineVariant.withValues(alpha: 0.65),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 12 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          title.isEmpty ? '?' : title[0].toUpperCase(),
                          style: textTheme.titleMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              code,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (latest != null) ...[
                        const SizedBox(width: 8),
                        _PublicationStatus(status: latest.publicationStatus),
                      ],
                    ],
                  ),

                  const SizedBox(height: 14),

                  // API path
                  Row(
                    children: [
                      Icon(
                        Icons.api_outlined,
                        size: 15,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          module.apiBasePath,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Divider(
                    height: 20,
                    thickness: 1,
                    color: scheme.outlineVariant.withValues(alpha: 0.55),
                  ),

                  // Footer
                  Row(
                    children: [
                      Icon(
                        Icons.table_chart_outlined,
                        size: 15,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          module.tableName.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (module.currentVersion > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          'v${module.currentVersion}',
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: _isHovered
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _title(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((item) => item.isNotEmpty)
        .map((item) => '${item[0].toUpperCase()}${item.substring(1)}')
        .join(' ');
  }
}

class _PublicationStatus extends StatelessWidget {
  const _PublicationStatus({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalized = status.trim().toLowerCase();

    final Color background;
    final Color foreground;

    if (normalized == 'published') {
      background = scheme.tertiaryContainer;
      foreground = scheme.onTertiaryContainer;
    } else if (normalized == 'draft') {
      background = scheme.secondaryContainer;
      foreground = scheme.onSecondaryContainer;
    } else {
      background = scheme.surfaceContainerHighest;
      foreground = scheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
