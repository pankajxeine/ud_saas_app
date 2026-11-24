import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../crud/crud_bloc.dart';
import '../../forms/forms.dart';
import '../../forms/helper/entity_meta_helper.dart';
import '../../forms/models/entity_meta.dart';
import '../data_table/data_table.dart';

/// Complete CRUD surface generated from a JSON schema and its `api` section.
///
/// The schema may contain `fields`, `visibility.show`, `grid`, `search`, and
/// API operations named `list`, `create`, `detail`, `update`, and `delete`.
class GenericCrudWidget extends StatelessWidget {
  const GenericCrudWidget({
    super.key,
    required this.schemaJson,
    required this.baseUrl,
    this.repository,
    this.title,
  });

  final Map<String, dynamic> schemaJson;
  final String baseUrl;
  final CrudRepository? repository;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final primaryKey = schemaJson['primaryKey']?.toString() ?? 'id';
    return BlocProvider(
      create: (_) => CrudBloc(
        repository: repository ??
            RestCrudRepository(baseUrl: baseUrl, schemaJson: schemaJson),
        primaryKey: primaryKey,
      )..add(const CrudLoad()),
      child: _CrudBody(
        schemaJson: schemaJson,
        title: title ?? schemaJson['title']?.toString(),
      ),
    );
  }
}

class _CrudBody extends StatelessWidget {
  const _CrudBody({required this.schemaJson, this.title});

  final Map<String, dynamic> schemaJson;
  final String? title;

  EntityMeta get _meta {
    final json = <String, dynamic>{
      'entityName': schemaJson['entity'] ?? schemaJson['title'] ?? 'Entity',
      'formLayout': schemaJson['formLayout'] ?? schemaJson['layout']?['mode'],
      'stepperOrientation': schemaJson['stepperOrientation'],
      'sections': schemaJson['sections'] ?? const [],
      'fields': schemaJson['fields'] ?? const [],
    };
    return entityMetaFromJson(json);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrudBloc, CrudState>(
      listener: (context, state) {
        final error = state.error;
        if (error != null && error.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        }
      },
      builder: (context, state) {
        switch (state.screen) {
          case CrudScreen.create:
            return _CrudForm(meta: _meta, title: title, mode: EntityMode.create);
          case CrudScreen.edit:
            return _CrudForm(
              meta: _meta,
              title: title,
              mode: EntityMode.edit,
              initialData: state.editing,
            );
          case CrudScreen.details:
            return _CrudDetails(
              schemaJson: schemaJson,
              title: title,
              record: state.selected ?? const {},
            );
          case CrudScreen.list:
            return _CrudList(
              schemaJson: schemaJson,
              title: title,
              records: state.records,
              loading: state.loading,
            );
        }
      },
    );
  }
}

class _CrudForm extends StatelessWidget {
  const _CrudForm({
    required this.meta,
    required this.mode,
    this.initialData,
    this.title,
  });

  final EntityMeta meta;
  final EntityMode mode;
  final Map<String, dynamic>? initialData;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back to list',
                onPressed: () => context.read<CrudBloc>().add(const CrudBackToList()),
                icon: const Icon(Icons.arrow_back),
              ),
              Text(
                mode == EntityMode.create ? 'New ${title ?? 'record'}' : 'Edit ${title ?? 'record'}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: AppReactiveForm(
                meta: meta,
                mode: mode,
                initialData: initialData,
                onSubmit: (data) async =>
                    context.read<CrudBloc>().add(CrudSave(data)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrudDetails extends StatelessWidget {
  const _CrudDetails({required this.schemaJson, required this.record, this.title});

  final Map<String, dynamic> schemaJson;
  final Map<String, dynamic> record;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final fields = (schemaJson['fields'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((field) {
          final show = (field['visibility'] as Map?)?['show'];
          return show is List && show.map((item) => item.toString()).contains('detail');
        })
        .toList();
    final id = record[schemaJson['primaryKey']?.toString() ?? 'id']?.toString() ?? '';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back to list',
                onPressed: () => context.read<CrudBloc>().add(const CrudBackToList()),
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(title ?? 'Details', style: Theme.of(context).textTheme.headlineSmall),
              ),
              FilledButton.icon(
                onPressed: () => context.read<CrudBloc>().add(CrudStartEdit(record)),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, id),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: fields.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final field = fields[index];
                  return ListTile(
                    title: Text(field['label']?.toString() ?? field['name'].toString()),
                    subtitle: Text('${record[field['name']]}'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete record?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<CrudBloc>().add(CrudDelete(id));
    }
  }
}

class _CrudList extends StatefulWidget {
  const _CrudList({required this.schemaJson, required this.records, this.title, required this.loading});

  final Map<String, dynamic> schemaJson;
  final List<Map<String, dynamic>> records;
  final String? title;
  final bool loading;

  @override
  State<_CrudList> createState() => _CrudListState();
}

class _CrudListState extends State<_CrudList> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _fields => (widget.schemaJson['fields'] as List? ?? const [])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .where((field) => ((field['visibility'] as Map?)?['show'] as List? ?? const [])
          .map((item) => item.toString()).contains('table'))
      .toList();

  List<String> get _quickSearch => (widget.schemaJson['search'] as Map?)?['quickSearch'] is List
      ? ((widget.schemaJson['search'] as Map)['quickSearch'] as List).map((item) => item.toString()).toList()
      : const [];

  List<Map<String, dynamic>> get _visibleRecords {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty || _quickSearch.isEmpty) return widget.records;
    return widget.records.where((record) => _quickSearch.any(
      (field) => '${record[field] ?? ''}'.toLowerCase().contains(query),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final fields = _fields;
    final rows = _visibleRecords;
    final columns = fields.map((field) => TrinaColumn(
      title: field['label']?.toString() ?? field['name'].toString(),
      field: field['name'].toString(),
      type: field['type'] == 'number' || field['type'] == 'integer'
          ? TrinaColumnType.number() : TrinaColumnType.text(),
    )).toList();
    final trinaRows = rows.map((record) => TrinaRow(cells: {
      for (final field in fields)
        field['name'].toString(): TrinaCell(value: record[field['name']]),
    })).toList();
    final rawGrid = widget.schemaJson['grid'];
    final pageSize = rawGrid is Map
        ? int.tryParse('${rawGrid['pageSize'] ?? 20}') ?? 20
        : 20;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(child: Text(widget.title ?? 'Records', style: Theme.of(context).textTheme.headlineSmall)),
            FilledButton.icon(
              onPressed: () => context.read<CrudBloc>().add(const CrudStartCreate()),
              icon: const Icon(Icons.add), label: const Text('New'),
            ),
          ]),
          const SizedBox(height: 12),
          SizedBox(width: 320, child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Quick search', prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          )),
          const SizedBox(height: 12),
          Expanded(child: widget.loading
              ? const Center(child: CircularProgressIndicator())
              : AppDataTable(
                  title: '${rows.length} records',
                  columns: columns,
                  rows: trinaRows,
                  pageSize: pageSize,
                  mobilePageSize: 10,
                  mobileRowKey: (row) => row.cells.values.first.value.toString(),
                  onRowTap: (index) => context.read<CrudBloc>().add(
                    CrudOpen(rows[index][widget.schemaJson['primaryKey']?.toString() ?? 'id'].toString()),
                  ),
                  onRowEdit: (index) => context.read<CrudBloc>().add(CrudStartEdit(rows[index])),
                )),
        ],
      ),
    );
  }
}
