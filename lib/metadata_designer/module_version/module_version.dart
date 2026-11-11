// import 'package:flutter/material.dart' hide Scaffold;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/scaffold/scaffold.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/divider/divider.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/lucide_icons.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/src/theme/theme.dart';

import 'package:ud_sass_app/core/widgets/components/loading.dart';
import 'package:ud_sass_app/core/widgets/components/tooltip_button.dart';
import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';
import '../repository/metadata_repository.dart';

import 'components/metadata_sidebar.dart';
import '../widgets/metadata_preview.dart';
import '../widgets/metadata_json_editor.dart';

import '../widgets/general_editor.dart';
import '../widgets/field_list_editor.dart';
import '../widgets/field_properties_editor.dart';
import '../widgets/field_validation_editor.dart';
import '../widgets/field_permission_editor.dart';
import '../widgets/api_editor.dart';
import '../widgets/grid_search_editor.dart';
import '../widgets/detail_editor.dart';
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
      child: Scaffold(
        child: SafeArea(
          child: BlocBuilder<MetadataBloc, MetadataState>(
            builder: (context, state) {
              if (state.isLoadingModules) {
                return const Center(child: Loading());
              }

              if (state.metadata == null) {
                return const _EmptyMetadataView();
              }

              return Column(
                children: [
                  _buildToolbar(context, state),
                  const Divider(),
                  Expanded(child: _buildDesignerBody(context, state)),
                  if (state.errors.isNotEmpty)
                    _buildValidationPanel(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // TOOLBAR
  // ------------------------------------------------------------

  Widget _buildToolbar(BuildContext context, MetadataState state) {
    final c = Theme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          TooltipButton(
            label: 'Back',
            variant: ButtonVariant.outline,
            size: ButtonSize.icon,
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Icon(LucideIcons.arrowBigLeft),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.metadata?.schemaJson.title.toString() ??
                      state.metadata?.schemaJson.entity?.toString() ??
                      'Metadata Designer',
                  style: Theme.of(context).typography.h3.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colors.accentForeground,
                  ),
                ),
                Text(
                  state.metadata?.schemaJson.entity?.toString() ?? '',
                  style: Theme.of(context).typography.h3.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colors.accentForeground,
                  ),
                ),
              ],
            ),
          ),

          if (state.isDirty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                'Unsaved changes',
                style: Theme.of(context).typography.h3.copyWith(
                  fontSize: 12,
                  color: const Color(0xFFB42318),
                ),
                // style: TextStyle(color: Color(0xFFB42318), fontSize: 12),
              ),
            ),

          TooltipButton(
            label: 'Preview',
            onPressed: () {
              context.read<MetadataBloc>().add(const SelectSection('preview'));
            },
            child: const Icon(LucideIcons.eye),
          ),

          const SizedBox(width: 8),

          Button(
            variant: ButtonVariant.outline,
            onPressed: state.isSaving
                ? null
                : () {
                    context.read<MetadataBloc>().add(const ValidateMetadata());
                  },
            leading: const Icon(LucideIcons.check, size: 16),
            child: const Text('Validate'),
          ),

          const SizedBox(width: 8),

          Button(
            variant: ButtonVariant.outline,
            onPressed: state.isSaving
                ? null
                : () {
                    context.read<MetadataBloc>().add(const SaveMetadata());
                  },
            leading: const Icon(LucideIcons.save, size: 16),
            child: const Text('Save'),
          ),

          const SizedBox(width: 8),

          Button(
            variant: ButtonVariant.link,
            onPressed: state.isSaving
                ? null
                : () {
                    context.read<MetadataBloc>().add(const PublishMetadata());
                  },
            leading: const Icon(LucideIcons.send, size: 16),
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MAIN DESIGNER BODY
  // ------------------------------------------------------------

  Widget _buildDesignerBody(BuildContext context, MetadataState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // LEFT SIDEBAR
        MetadataSidebar(
          selectedSection: state.selectedSection,
          onSectionSelected: (section) {
            context.read<MetadataBloc>().add(SelectSection(section));
          },
        ),
        // MAIN EDITOR
        Expanded(
          flex: 3,
          child: Container(
            color: Theme.of(context).colors.background,
            child: _buildSelectedEditor(context, state),
          ),
        ),

        const Divider(axis: Axis.vertical),

        // RIGHT PREVIEW
        if (state.selectedSection != 'json')
          const SizedBox(width: 340, child: MetadataPreview()),
      ],
    );
  }

  // ------------------------------------------------------------
  // SECTION ROUTER
  // ------------------------------------------------------------

  Widget _buildSelectedEditor(BuildContext context, MetadataState state) {
    switch (state.selectedSection) {
      case 'general':
        return const GeneralEditor();

      case 'fields':
        return const FieldListEditor();

      case 'field-properties':
        return const FieldPropertiesEditor();

      case 'field-validations':
        return const FieldValidationEditor();

      case 'field-permissions':
        return const FieldPermissionEditor();

      case 'reference':
        return const ReferenceLookupEditor();

      case 'api':
        return const ApiEditor();

      case 'grid':
        return const GridSearchEditor();

      case 'detail':
        return const DetailEditor();

      case 'preview':
        return _buildPreviewSection(context, state);

      case 'json':
        return const MetadataJsonEditor();

      default:
        return const _UnknownSectionView();
    }
  }

  // ------------------------------------------------------------
  // PREVIEW SECTION
  // ------------------------------------------------------------

  Widget _buildPreviewSection(BuildContext context, MetadataState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metadata Preview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(child: MetadataPreview()),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // VALIDATION PANEL
  // ------------------------------------------------------------

  Widget _buildValidationPanel(BuildContext context, MetadataState state) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF4F2),
        border: Border(top: BorderSide(color: Color(0xFFE5B5AE))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Validation Errors',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFFB42318),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: state.errors.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        LucideIcons.circleAlert,
                        size: 15,
                        color: Color(0xFFB42318),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errors[index].toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB42318),
                          ),
                        ),
                      ),
                    ],
                  ),
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
// EMPTY METADATA VIEW
// ------------------------------------------------------------

class _EmptyMetadataView extends StatelessWidget {
  const _EmptyMetadataView();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.container, size: 48),
          const SizedBox(height: 12),
          Text(
            'No metadata loaded',
            style: t.typography.extraBold.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: t.colors.accentForeground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select an entity to open its metadata designer.',
            style: t.typography.extraBold.copyWith(
              fontWeight: FontWeight.w700,
              color: t.colors.accentForeground,
            ),
          ),
          const SizedBox(height: 20),
          Button(
            onPressed: () {
              context.read<MetadataBloc>().add(const BackToEntitySelection());
            },
            child: const Text('Back to entities'),
          ),
        ],
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
    return const Center(child: Text('Select a section from the sidebar.'));
  }
}
