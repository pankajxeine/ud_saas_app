import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/core/widgets/components/loading.dart';
import 'package:ud_sass_app/core/widgets/components/tooltip_button.dart';
import 'package:ud_sass_app/core/theme/app_theme.dart';
import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';
import '../repository/metadata_repository.dart';

import 'widgets/datatable_fields.dart';
import 'components/metadata_sidebar.dart';

import '../widgets/metadata_preview.dart';
import '../widgets/metadata_json_editor.dart';
import '../widgets/general_editor.dart';
import '../widgets/field_list_editor.dart';
import '../widgets/field_validation_editor.dart';
import '../widgets/section_list_editor.dart';
import '../widgets/api_editor.dart';
import '../widgets/grid_search_editor.dart';
import '../widgets/reference_lookup_editor.dart';

class MetadataVersionDesign extends StatelessWidget {
  const MetadataVersionDesign({
    super.key,
    required this.moduleId,
    required this.versionId,
  });

  final String moduleId;
  final String versionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MetadataBloc>(
      create: (_) =>
          MetadataBloc(
            repository: LocalMetadataRepository(
              baseUrl: ProfileConstants.api.toString(),
            ),
          )..add(
            LoadMetadataModuleVersionById(
              moduleId: moduleId,
              versionId: versionId,
            ),
          ),
      child: BlocBuilder<MetadataBloc, MetadataState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;

          if (state.isLoadingModules) {
            return const Loading();
          }

          if (state.metadata == null) {
            return const _EmptyMetadataView();
          }

          return Column(
            children: [
              _buildToolbar(context, state),
              Divider(
                height: 1,
                thickness: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildDesignerBody(context, state),
                ),
              ),
              if (state.errors.isNotEmpty)
                _buildValidationPanel(context, state),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // TOOLBAR
  // ------------------------------------------------------------

  Widget _buildToolbar(BuildContext context, MetadataState state) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final schema = state.metadata?.schemaJson;

    final title = schema?.title?.toString().trim();
    final entity = schema?.entity?.toString().trim();

    final pageTitle = title?.isNotEmpty == true
        ? title!
        : entity?.isNotEmpty == true
        ? entity!
        : 'Metadata Designer';

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the available toolbar width, not the whole screen width.
        final isCompact = constraints.maxWidth < 850;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TooltipButton(
                label: 'Back',
                onPressed: () => context.pop(),
                child: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 12),

              // Title section
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pageTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                          if (entity?.isNotEmpty == true)
                            Text(
                              entity!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (state.isDirty) ...[
                      const SizedBox(width: 8),
                      const _UnsavedChangesIndicator(),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Actions always stay in the same row.
              _buildToolbarActions(context, state, compact: isCompact),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolbarActions(
    BuildContext context,
    MetadataState state, {
    required bool compact,
  }) {
    final bloc = context.read<MetadataBloc>();
    final scheme = Theme.of(context).colorScheme;
    final previewButton = IconButton.filled(
      tooltip: 'Preview',
      style: AppTheme.filledIconButtonStyle(scheme),
      onPressed: () {
        bloc.add(const SelectSection('preview'));
      },
      icon: const Icon(Icons.visibility_outlined),
    );

    final validateButton = compact
        ? IconButton.outlined(
            tooltip: 'Validate',
            style: AppTheme.outlinedIconButtonStyle(scheme),
            onPressed: state.isSaving
                ? null
                : () => bloc.add(const ValidateMetadata()),
            icon: const Icon(Icons.fact_check_outlined),
          )
        : OutlinedButton.icon(
            onPressed: state.isSaving
                ? null
                : () => bloc.add(const ValidateMetadata()),
            icon: const Icon(Icons.fact_check_outlined, size: 17),
            label: const Text('Validate'),
          );

    final saveButton = compact
        ? IconButton.outlined(
            style: AppTheme.outlinedIconButtonStyle(scheme),
            tooltip: 'Save',
            onPressed: state.isSaving
                ? null
                : () => bloc.add(const SaveMetadata()),
            icon: const Icon(Icons.save_outlined),
          )
        : OutlinedButton.icon(
            onPressed: state.isSaving
                ? null
                : () => bloc.add(const SaveMetadata()),
            icon: const Icon(Icons.save_outlined, size: 17),
            label: const Text('Save'),
          );

    final publishButton = compact
        ? IconButton.filled(
            tooltip: 'Publish',
            style: AppTheme.filledIconButtonStyle(scheme),
            onPressed: state.isSaving
                ? null
                : () => bloc.add(const PublishMetadata()),
            icon: const Icon(Icons.publish_outlined),
          )
        : FilledButton.icon(
            onPressed: state.isSaving
                ? null
                : () => bloc.add(const PublishMetadata()),
            icon: const Icon(Icons.publish_outlined, size: 17),
            label: const Text('Publish'),
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        previewButton,
        const SizedBox(width: 4),
        validateButton,
        const SizedBox(width: 4),
        saveButton,
        const SizedBox(width: 4),
        publishButton,
      ],
    );
  }
  // ------------------------------------------------------------
  // MAIN DESIGNER BODY
  // ------------------------------------------------------------

  Widget _buildDesignerBody(BuildContext context, MetadataState state) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MetadataSidebar(
              selectedSection: state.selectedSection,
              onSectionSelected: (section) {
                context.read<MetadataBloc>().add(SelectSection(section));
              },
              compact: isCompact,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildSelectedEditor(context, state),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // SECTION ROUTER
  // ------------------------------------------------------------

  Widget _buildSelectedEditor(BuildContext context, MetadataState state) {
    final moduleVersion = state.metadata;

    switch (state.selectedSection) {
      case 'general':
        return const GeneralEditor();

      case 'fields':
        return FieldEditor(
          fields: moduleVersion?.schemaJson.fields ?? const [],
          sections: moduleVersion?.schemaJson.sections ?? const [],
        );

      case 'field-validations':
        return const FieldValidationEditor();

      case 'sections':
        return SectionsEditor(
          sections: moduleVersion?.schemaJson.sections ?? const [],
        );

      case 'datatable':
        return const DataTableColumnView();

      case 'reference':
        return const ReferenceLookupEditor();

      case 'api':
        return ApiEditor(api: moduleVersion?.schemaJson.api);

      case 'grid':
        return const GridSearchEditor();

      case 'preview':
        return _buildPreviewSection();

      case 'json':
        return const MetadataJsonEditor();

      default:
        return const _UnknownSectionView();
    }
  }

  // ------------------------------------------------------------
  // PREVIEW SECTION
  // ------------------------------------------------------------

  Widget _buildPreviewSection() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metadata Preview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          Expanded(child: MetadataPreview()),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // VALIDATION PANEL
  // ------------------------------------------------------------

  Widget _buildValidationPanel(BuildContext context, MetadataState state) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        border: Border(
          top: BorderSide(color: scheme.error.withValues(alpha: 0.35)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 5),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 17,
                  color: scheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Validation errors',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${state.errors.length})',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              itemCount: state.errors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 5),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 6, color: scheme.onErrorContainer),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.errors[index].toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// UNSAVED CHANGES INDICATOR
// ------------------------------------------------------------

class _UnsavedChangesIndicator extends StatelessWidget {
  const _UnsavedChangesIndicator();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: scheme.onTertiaryContainer),
          const SizedBox(width: 6),
          Text(
            'Unsaved',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onTertiaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// EMPTY METADATA VIEW
// ------------------------------------------------------------

class _EmptyMetadataView extends StatelessWidget {
  const _EmptyMetadataView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              size: 44,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(
              'No metadata loaded',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Select an entity to open its metadata designer.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                context.read<MetadataBloc>().add(const BackToEntitySelection());
              },
              icon: const Icon(Icons.arrow_back, size: 17),
              label: const Text('Back to entities'),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// UNKNOWN SECTION VIEW
// ------------------------------------------------------------

class _UnknownSectionView extends StatelessWidget {
  const _UnknownSectionView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        'Select a section from the sidebar.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
