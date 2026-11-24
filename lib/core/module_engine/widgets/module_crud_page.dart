import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../forms/helper/entity_meta_helper.dart';
import '../../forms/forms.dart';
import '../bloc/module_crud_bloc.dart';
import '../bloc/module_crud_event.dart';
import '../bloc/module_crud_state.dart';
import '../bloc/module_metadata_bloc.dart';
import '../models/presentation_models.dart';
import '../repository/module_metadata_repository.dart';
import '../repository/module_record_repository.dart';
import '../utils/metadata_presentation_mapper.dart';
import '../../widgets/data_table/data_table.dart';
import '../../widgets/components/app_table_controls.dart';
import '../../forms/models/entity_meta.dart';

/// Entry point for a metadata-driven module CRUD experience.
///
/// A bloc is created for this module route only. The metadata repository may
/// be shared by routes because it owns tenant-scoped caching.
class ModuleCrudPage extends StatelessWidget {
  const ModuleCrudPage({
    super.key,
    required this.moduleId,
    required this.metadataRepository,
    required this.recordRepository,
    this.recordId,
  });

  final String moduleId;
  final String? recordId;
  final ModuleMetadataRepository metadataRepository;
  final ModuleRecordRepository recordRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ModuleMetadataBloc(moduleId: moduleId, repository: metadataRepository)
            ..load(),
      child: _ModuleMetadataGate(
        recordRepository: recordRepository,
        recordId: recordId,
      ),
    );
  }
}

class _ModuleMetadataGate extends StatelessWidget {
  const _ModuleMetadataGate({required this.recordRepository, this.recordId});

  final ModuleRecordRepository recordRepository;
  final String? recordId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModuleMetadataBloc, ModuleMetadataState>(
      builder: (context, state) {
        if (state.status == ModuleMetadataStatus.loading ||
            state.status == ModuleMetadataStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == ModuleMetadataStatus.failure ||
            state.metadata == null) {
          return _ErrorState(
            message: state.error ?? 'Unable to load module metadata.',
            onRetry: () => context.read<ModuleMetadataBloc>().retry(),
          );
        }
        return BlocProvider(
          create: (_) => ModuleCrudBloc(
            metadata: state.metadata!,
            recordRepository: recordRepository,
          )..add(ModuleStarted(recordId: recordId)),
          child: const _ModuleCrudBody(),
        );
      },
    );
  }
}

class _ModuleCrudBody extends StatelessWidget {
  const _ModuleCrudBody();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ModuleCrudBloc, ModuleCrudState, ModuleCrudView>(
      selector: (state) => state.view,
      builder: (context, view) {
        return switch (view) {
          ModuleCrudView.list => const _ModuleListView(),
          ModuleCrudView.detail => const _ModuleDetailView(),
          ModuleCrudView.create => const _ModuleFormView(create: true),
          ModuleCrudView.edit => const _ModuleFormView(create: false),
        };
      },
    );
  }
}

class _ModuleListView extends StatelessWidget {
  const _ModuleListView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: BlocBuilder<ModuleCrudBloc, ModuleCrudState>(
            buildWhen: (previous, current) =>
                previous.recordsStatus != current.recordsStatus &&
                    (current.recordsStatus == ModuleLoadStatus.loading ||
                        current.recordsStatus == ModuleLoadStatus.failure) ||
                previous.operationError != current.operationError,
            builder: (context, state) {
              if (state.recordsStatus == ModuleLoadStatus.failure) {
                return _ErrorState(
                  message: state.operationError ?? 'Unable to load records.',
                  onRetry: () => context.read<ModuleCrudBloc>().add(
                    const ModuleRefreshRequested(),
                  ),
                );
              }
              return const _ModuleTable();
            },
          ),
        ),
      ],
    );
  }
}

class _ModuleTable extends StatelessWidget {
  const _ModuleTable();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ModuleCrudBloc, ModuleCrudState, _TableSelection>(
      selector: (state) =>
          _TableSelection(records: state.records, pageSize: state.pageSize),
      builder: (context, selection) {
        final metadata = context.read<ModuleCrudBloc>().metadata;
        final table = MetadataPresentationMapper.table(
          metadata: metadata,
          records: selection.records,
        );
        if (table.rows.isEmpty) {
          return _EmptyState(
            title: 'No records found',
            action: FilledButton.icon(
              onPressed: () => context.read<ModuleCrudBloc>().add(
                const ModuleCreateRequested(),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Create record'),
            ),
          );
        }

        return AppDataTable(
          title: metadata.title,
          subtitle: '${table.rows.length} records',
          headerActionsBuilder: AppTableControls(
            onSearchSubmitted: (value) =>
                context.read<ModuleCrudBloc>().add(ModuleSearchChanged(value)),
            onSearchChanged: (value) =>
                context.read<ModuleCrudBloc>().add(ModuleSearchChanged(value)),
            showAddButton: true,
            onAdd: () => context.read<ModuleCrudBloc>().add(
              const ModuleCreateRequested(),
            ),
            addLabel: 'New',
          ),
          columns: [
            for (final column in table.columns)
              TrinaColumn(
                title: column.label,
                field: column.field,
                type: column.type == 'number' || column.type == 'integer'
                    ? TrinaColumnType.number()
                    : TrinaColumnType.text(),
              ),
          ],
          rows: [
            for (final record in table.rows)
              TrinaRow(
                cells: {
                  for (final column in table.columns)
                    column.field: TrinaCell(value: record[column.field]),
                },
              ),
          ],
          pageSize: selection.pageSize,
          mobilePageSize: selection.pageSize,
          mobileRowKey: (row) =>
              row.cells[metadata.primaryKey]?.value.toString() ??
              identityHashCode(row).toString(),
          onRowTap: (index) {
            final id = table.rows[index][metadata.primaryKey];
            if (id != null) {
              context.read<ModuleCrudBloc>().add(
                ModuleDetailRequested(id.toString()),
              );
            }
          },
          onRowEdit: (index) {
            final id = table.rows[index][metadata.primaryKey];
            if (id != null) {
              context.read<ModuleCrudBloc>().add(
                ModuleEditRequested(id.toString()),
              );
            }
          },
        );
      },
    );
  }
}

class _ModuleDetailView extends StatelessWidget {
  const _ModuleDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ModuleCrudBloc, ModuleCrudState, _DetailSelection?>(
      selector: (state) => state.selected == null
          ? null
          : _DetailSelection(
              model: MetadataPresentationMapper.view(
                context.read<ModuleCrudBloc>().metadata,
              ),
              record: state.selected!,
              primaryKey: context.read<ModuleCrudBloc>().metadata.primaryKey,
            ),
      builder: (context, selection) {
        if (selection == null)
          return const _EmptyState(title: 'Record not found');
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.read<ModuleCrudBloc>().add(
                      const ModuleBackRequested(),
                    ),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      selection.model.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.read<ModuleCrudBloc>().add(
                      ModuleEditRequested(
                        selection.record[selection.primaryKey]?.toString() ??
                            '',
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: selection.model.fields.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final field = selection.model.fields[index];
                    return ListTile(
                      title: Text(field.label),
                      subtitle: Text('${selection.record[field.field] ?? ''}'),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModuleFormView extends StatelessWidget {
  const _ModuleFormView({required this.create});

  final bool create;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ModuleCrudBloc, ModuleCrudState, _FormSelection>(
      selector: (state) =>
          _FormSelection(data: state.formData, operation: state.operation),
      builder: (context, selection) {
        final metadata = context.read<ModuleCrudBloc>().metadata;
        final model = MetadataPresentationMapper.form(
          metadata,
          edit: !create,
        );
        final meta = entityMetaFromJson(model.json);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.read<ModuleCrudBloc>().add(
                      const ModuleBackRequested(),
                    ),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    '${create ? 'New' : 'Edit'} ${metadata.title}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              if (selection.operation == ModuleOperation.loading)
                const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: AppReactiveForm(
                    meta: meta,
                    mode: create ? EntityMode.create : EntityMode.edit,
                    initialData: selection.data,
                    onSubmit: (data) async => context
                        .read<ModuleCrudBloc>()
                        .add(ModuleFormSubmitted(data)),
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

class _TableSelection {
  const _TableSelection({required this.records, required this.pageSize});

  final List<Map<String, dynamic>> records;
  final int pageSize;
}

class _DetailSelection {
  const _DetailSelection({
    required this.model,
    required this.record,
    required this.primaryKey,
  });

  final MetadataViewModel model;
  final Map<String, dynamic> record;
  final String primaryKey;
}

class _FormSelection {
  const _FormSelection({required this.data, required this.operation});

  final Map<String, dynamic> data;
  final ModuleOperation operation;
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 40),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}
