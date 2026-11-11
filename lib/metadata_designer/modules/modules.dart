import 'package:flutter/widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ud_sass_app/core/widgets/components/app_grid_card.dart';
import 'package:ud_sass_app/core/widgets/components/tooltip_button.dart';

import 'package:ud_sass_app/ui/dashcn/src/components/scaffold/scaffold.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/lucide_icons.dart';
import 'package:ud_sass_app/core/widgets/components/loading.dart';
import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/routes/app_routes_constants.dart';
import 'package:ud_sass_app/ui/dashcn/src/theme/theme.dart';

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

        print(
          "MetadataDesignerView: state.allMetadata.length: ${state.allMetadata.length}",
        );
        return Scaffold(
          headers: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Meta Designer Tool',
                      style: Theme.of(context).typography.h2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colors.mutedForeground,
                      ),
                    ),
                  ),
                  TooltipButton(
                    label: 'Refresh',
                    onPressed: () {
                      context.read<MetadataBloc>().add(
                        const LoadMetadataModules(),
                      );
                    },
                    child: const Icon(LucideIcons.refreshCw),
                  ),
                ],
              ),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsGeometry.all(10),
                  child: AppSliverGrid<MetaModule>(
                    items: state.allMetadata,
                    showAddCard: true,
                    addCardTitle: 'Add Module',
                    addCardDescription: 'Create new metadata module',
                    onAddTap: () {
                      context.read<MetadataBloc>().add(const CreateNewModule());
                      Navigator.of(context).pushNamed(
                        ApplicationRoutesConstants.metadataModuleNew,
                        arguments: MetaModule.empty(),
                      );
                    },
                    itemBuilder: (context, module, index) {
                      return ModuleCard(
                        module: module,
                        onTap: () {
                          context.read<MetadataBloc>().add(
                            SelectEntityMetadata(module),
                          );
                          Navigator.of(context).pushNamed(
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
          ),
        );
      },
    );
  }
}
