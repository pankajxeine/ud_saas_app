import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/core/theme/app_theme.dart';
import 'package:ud_sass_app/core/widgets/components/app_grid_card.dart';
import 'package:ud_sass_app/core/widgets/components/loading.dart';
import 'package:ud_sass_app/routes/app_routes_constants.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';
import '../repository/metadata_repository.dart';
import '../models/metadata_module.dart';
import '../models/metadata_module_version.dart';

import 'components/module_version_card.dart';

class MetadataModule extends StatelessWidget {
  const MetadataModule({super.key, required this.moduleId});

  final String moduleId;

  static const double _desktopBreakpoint = 1000;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MetadataBloc>(
      create: (_) => MetadataBloc(
        repository: LocalMetadataRepository(
          baseUrl: ProfileConstants.api.toString(),
        ),
      )..add(LoadMetadataModuleById(moduleId: moduleId)),
      child: BlocBuilder<MetadataBloc, MetadataState>(
        builder: (context, state) {
          if (state.isLoadingModules) {
            return const Center(child: Loading());
          }

          final module = state.module;

          if (module == null) {
            return const Center(child: Text('Module is empty'));
          }

          return Container(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: SafeArea(
              child: Column(
                children: [
                  const _Header(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildDesignerBody(context, module),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesignerBody(BuildContext context, MetaModule module) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _desktopBreakpoint;

        return isDesktop
            ? _DesktopModuleLayout(module: module)
            : _MobileModuleLayout(module: module);
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Page Header
// -----------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Configure Module',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(Icons.tune_rounded, color: scheme.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Desktop Layout
// -----------------------------------------------------------------------------

class _DesktopModuleLayout extends StatelessWidget {
  const _DesktopModuleLayout({required this.module});

  final MetaModule module;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 1, child: _ModuleSummaryCard(module: module)),
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(
          flex: 2,
          child: _ModuleVersionsCard(module: module, shrinkWrap: false),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Mobile and Tablet Layout
// -----------------------------------------------------------------------------

class _MobileModuleLayout extends StatelessWidget {
  const _MobileModuleLayout({required this.module});

  final MetaModule module;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ModuleSummaryCard(module: module),
          const SizedBox(height: 10),
          _ModuleVersionsCard(module: module, shrinkWrap: true),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Module Summary Card
// -----------------------------------------------------------------------------

class _ModuleSummaryCard extends StatelessWidget {
  const _ModuleSummaryCard({required this.module});

  final MetaModule module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final description = module.description?.trim();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module identity
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _moduleIcon(module.icon),
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.moduleName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        module.moduleCode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ModuleStatus(isActive: module.isActive),
              ],
            ),

            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),

            // Module properties
            _SummaryValue(
              icon: Icons.storage_outlined,
              label: 'Database schema',
              value: module.schemaName,
            ),
            _SummaryValue(
              icon: Icons.table_chart_outlined,
              label: 'Table',
              value: module.tableName,
            ),
            _SummaryValue(
              icon: Icons.api_outlined,
              label: 'API base path',
              value: module.apiBasePath.isEmpty
                  ? 'Not set'
                  : module.apiBasePath,
            ),
            _SummaryValue(
              icon: Icons.layers_outlined,
              label: 'Current version',
              value: module.currentVersion == 0
                  ? 'Not created'
                  : 'v${module.currentVersion}',
              showBottomPadding: false,
            ),
          ],
        ),
      ),
    );
  }

  IconData _moduleIcon(String? icon) => switch (icon) {
    'users' => Icons.people_outline,
    'settings' => Icons.settings_outlined,
    'file' => Icons.insert_drive_file_outlined,
    _ => Icons.inventory_2_outlined,
  };
}

// -----------------------------------------------------------------------------
// Module Status
// -----------------------------------------------------------------------------

class _ModuleStatus extends StatelessWidget {
  const _ModuleStatus({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final background = isActive
        ? scheme.tertiaryContainer
        : scheme.surfaceContainerHighest;

    final foreground = isActive
        ? scheme.onTertiaryContainer
        : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.pause_circle_outline,
            size: 13,
            color: foreground,
          ),
          const SizedBox(width: 5),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Module Versions Card
// -----------------------------------------------------------------------------

class _ModuleVersionsCard extends StatelessWidget {
  const _ModuleVersionsCard({required this.module, required this.shrinkWrap});

  final MetaModule module;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schema Versions',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${module.metaModuleVersions.length} versions available',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.layers_outlined,
                  color: scheme.onSurfaceVariant,
                  size: 19,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            if (shrinkWrap)
              AppSliverGrid<MetaModuleVersion>(
                items: module.metaModuleVersions,
                showAddCard: true,
                addCardTitle: 'Add Version',
                addCardDescription: 'Create schema version',
                addCardIcon: Icons.add_rounded,
                onAddTap: () {
                  context.push(
                    ApplicationRoutesConstants.metadataVersionNew(
                      module.moduleId,
                    ),
                  );
                },
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                minCardWidth: 230,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mobileChildAspectRatio: 3.0,
                childAspectRatio: 2.5,
                itemBuilder: (context, version, index) {
                  return _versionCard(context, module, version);
                },
              )
            else
              Expanded(
                child: AppSliverGrid<MetaModuleVersion>(
                  items: module.metaModuleVersions,
                  showAddCard: true,
                  addCardTitle: 'Add Version',
                  addCardDescription: 'Create schema version',
                  addCardIcon: Icons.add_rounded,
                  onAddTap: () {
                    context.push(
                      ApplicationRoutesConstants.metadataVersionNew(
                        module.moduleId,
                      ),
                    );
                  },
                  minCardWidth: 230,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.5,
                  mobileChildAspectRatio: 3.0,
                  itemBuilder: (context, version, index) {
                    return _versionCard(context, module, version);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _versionCard(
    BuildContext context,
    MetaModule module,
    MetaModuleVersion version,
  ) {
    return ModuleVersionCard(
      version: version,
      onTap: () {
        context.read<MetadataBloc>().add(
          SelectModuleVersionMetadata(module: module, version: version),
        );

        final uri = ApplicationRoutesConstants.metadataVersion(
          version.moduleId!,
          version.moduleVersionId!,
        );

        context.go(uri);
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Summary Value
// -----------------------------------------------------------------------------

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.icon,
    required this.label,
    required this.value,
    this.showBottomPadding = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showBottomPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: showBottomPadding ? 10 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
