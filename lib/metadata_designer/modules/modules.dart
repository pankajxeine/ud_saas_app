import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/core/widgets/components/app_grid_card.dart';
import 'package:ud_sass_app/core/widgets/components/loading.dart';
import 'package:ud_sass_app/routes/app_routes_constants.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';
import '../repository/metadata_repository.dart';
import '../models/metadata_module.dart';
import 'components/module_card.dart';

class MetadataModules extends StatelessWidget {
  const MetadataModules({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MetadataBloc>(
      create: (_) => MetadataBloc(
        repository: LocalMetadataRepository(
          baseUrl: ProfileConstants.api.toString(),
        ),
      )..add(const LoadMetadataModules()),
      child: const _MetadataDesignerContent(),
    );
  }
}

class _MetadataDesignerContent extends StatelessWidget {
  const _MetadataDesignerContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataBloc, MetadataState>(
      builder: (context, state) {
        if (state.isLoadingModules) {
          return const Center(child: Loading());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page header (not an AppBar or Scaffold).
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meta Designer Tool',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage and configure your metadata modules.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () {
                      context.read<MetadataBloc>().add(
                        const LoadMetadataModules(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),

            // Module grid.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppSliverGrid<MetaModule>(
                  items: state.allMetadata,
                  showAddCard: true,
                  addCardTitle: 'Add Module',
                  addCardDescription: 'Create new metadata module',
                  onAddTap: () {
                    context.push(
                      ApplicationRoutesConstants.metadataModuleNew,
                      extra: MetaModule.empty(),
                    );
                  },
                  itemBuilder: (context, module, index) {
                    return ModuleCard(
                      module: module,
                      onTap: () {
                        context.read<MetadataBloc>().add(
                          SelectEntityMetadata(module),
                        );

                        context.go(
                          ApplicationRoutesConstants.metadataModule(
                            module.moduleId,
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
      },
    );
  }
}
