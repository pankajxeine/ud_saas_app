import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/core/widgets/components/tooltip_button.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/lucide_icons.dart';
import 'package:ud_sass_app/ui/dashcn/components/avatar.dart';
import 'package:ud_sass_app/ui/dashcn/components/chip.dart';
import 'package:ud_sass_app/ui/dashcn/components/scaffold.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/divider/divider.dart';
import 'package:ud_sass_app/ui/dashcn/src/theme/theme.dart';
import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/core/widgets/components/app_grid_card.dart';
import 'package:ud_sass_app/core/widgets/components/loading.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';

import '../repository/metadata_repository.dart';

import '../../routes/app_routes_constants.dart';
import '../models/metadata_module.dart';
import '../models/metadata_schema.dart';
import '../models/metadata_module_version.dart';
import 'components/module_version_card.dart';

// class MetadataModuleRouteArgs {
//   const MetadataModuleRouteArgs({required this.module, this.version});

//   final MetaModule module;
//   final MetaModuleVersion? version;
// }

class MetadataModule extends StatelessWidget {
  const MetadataModule({super.key, required this.moduleId});
  final String moduleId;

  @override
  Widget build(BuildContext context) {
    print("enter to MetadataModule with moduleId $moduleId");
    return BlocProvider<MetadataBloc>(
      create: (_) => MetadataBloc(
        repository: LocalMetadataRepository(
          baseUrl: ProfileConstants.api.toString(),
        ),
      )..add(LoadMetadataModuleById(moduleId: moduleId)),
      child: Scaffold(
        child: SafeArea(
          child: BlocBuilder<MetadataBloc, MetadataState>(
            builder: (context, state) {
              print("module id : ${moduleId}");
              if (state.isLoadingModules) {
                return const Center(child: Loading());
              }
              if (state.module == null) {
                print("Sate module is empty");
                return const Text("module is empty");
                //return const _EmptyMetadataView();
              }

              return Column(
                children: [
                  const _Header(),
                  const Divider(),
                  Expanded(child: _buildDesignerBody(context, state.module!)),
                  // _buildDesignerBody(context),

                  // if (state.errors.isNotEmpty)
                  //   _buildValidationPanel(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDirty;
  const _Header({this.isDirty = false});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          TooltipButton(
            label: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Icon(LucideIcons.arrowBigLeft),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              'Configure Module',
              style: Theme.of(context).typography.extraBold.copyWith(
                fontWeight: FontWeight.w700,
                color: c.accentForeground,
              ),
            ),
          ),

          if (isDirty)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Text('Unsaved changes', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// MAIN DESIGNER BODY
// ------------------------------------------------------------

Widget _buildDesignerBody(BuildContext context, MetaModule module) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // MAIN EDITOR
      Expanded(child: _ModuleSummary(module: module)),
      const Divider(axis: Axis.vertical),

      Expanded(
        flex: 2,
        child: Padding(
          padding: const EdgeInsetsGeometry.all(16),
          child: AppSliverGrid<MetaModuleVersion>(
            items: module.metaModuleVersions,
            showAddCard: true,
            addCardTitle: 'Add Module',
            addCardDescription: 'Create new schema version',
            onAddTap: () {
              context.read<MetadataBloc>().add(const CreateNewModule());
              Navigator.of(context).pushNamed(
                ApplicationRoutesConstants.metadataModuleNew,
                arguments: MetaModuleVersion.empty,
              );
            },
            itemBuilder: (context, moduleVersion, index) {
              return ModuleVersionCard(
                version: moduleVersion,
                onTap: () {
                  context.read<MetadataBloc>().add(
                    SelectModuleVersionMetadata(
                      module: module,
                      version: moduleVersion,
                    ),
                  );
                  Navigator.of(context).pushNamed(
                    ApplicationRoutesConstants.metadataVersion(
                      moduleVersion.moduleId!,
                      moduleVersion.moduleVersionId!,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    ],
  );
}

class _ModuleSummary extends StatelessWidget {
  const _ModuleSummary({required this.module});

  final MetaModule module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = module.description?.trim();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(initials: "", badge: Icon(_moduleIcon(module.icon))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.moduleName,
                      style: theme.typography.h3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colors.accentForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.moduleCode,
                      style: theme.typography.medium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                leading: Icon(
                  module.isActive ? LucideIcons.check : LucideIcons.pause,
                  size: 16,
                ),
                child: Text(module.isActive ? 'Active' : 'Inactive'),
              ),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: theme.typography.medium.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
          const SizedBox(height: 24),

          _SummaryValue(label: 'Database schema', value: module.schemaName),
          _SummaryValue(label: 'Table', value: module.tableName),
          _SummaryValue(
            label: 'API base path',
            value: module.apiBasePath.isEmpty ? 'Not set' : module.apiBasePath,
          ),
          _SummaryValue(
            label: 'Current version',
            value: module.currentVersion == 0
                ? 'Not created'
                : 'v${module.currentVersion}',
          ),
          // _SummaryValue(
          //   label: 'Current schema',
          //   value:
          //       version?.schemaJson.title ??
          //       version?.schemaJson.entity ??
          //       'No published schema',
          // ),
        ],
      ),
    );
  }

  IconData _moduleIcon(String? icon) {
    switch (icon) {
      case 'users':
        return LucideIcons.users;
      case 'settings':
        return LucideIcons.settings;
      case 'file':
        return LucideIcons.disc;
      case 'box':
      default:
        return LucideIcons.store;
    }
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.typography.medium.copyWith(
              color: theme.colors.accentForeground,
            ),
          ),
          Text(
            value,
            style: theme.typography.medium.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colors.accentForeground,
            ),
          ),
        ],
      ),
    );
  }
}
