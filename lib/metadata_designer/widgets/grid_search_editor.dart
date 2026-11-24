import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ud_sass_app/core/forms/forms.dart';
import 'package:ud_sass_app/core/forms/helper/entity_meta_helper.dart';
import 'package:ud_sass_app/core/forms/models/entity_meta.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';

class GridSearchEditor extends StatelessWidget {
  const GridSearchEditor({super.key});
  static const Map<String, dynamic> _schema = {
    'name': 'grid',
    'label': 'Grid Configuration',
    'type': 'group',
    'fields': [
      {
        'name': 'pageSize',
        'label': 'Page Size',
        'type': 'text',
        'widget': 'text',
        'required': true,
      },
      {
        'name': 'defaultSort',
        'label': 'Default Sort',
        'type': 'group',
        'fields': [
          {
            'name': 'direction',
            'label': 'Direction',
            'type': 'select',
            'options': [
              {'label': 'Descending', 'value': 'desc'},
              {'label': 'Ascending', 'value': 'asc'},
            ],
          },
        ],
      },
    ],
  };

  static final EntityMeta metadata = entityMetaFromJson(_schema);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataBloc, MetadataState>(
      builder: (context, state) {
        final schema = state.metadata?.schemaJson;
        final availableFields =
            schema?.fields.map((field) => field.name).toList() ??
            const <String>[];
        final grid = schema?.grid?.toJson() ?? <String, dynamic>{};
        final search = Map<String, dynamic>.from(schema?.search ?? const {});
        final quickSearch = _stringList(search['quickSearch']);
        final filters = _mapList(search['filters']);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppReactiveForm(
              key: const ValueKey('grid'),
              meta: metadata,
              initialData: grid,
              onSubmit: (data) async {
                context.read<MetadataBloc>().add(
                  UpdateRootProperty('grid', data),
                );
              },
            ),

            const SizedBox(height: 20),
            const Text(
              'Search configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _stringListEditor(
              context: context,
              title: 'Quick search fields',
              values: quickSearch,
              availableFields: availableFields,
              onChanged: (values) =>
                  _updateSearch(context, search, 'quickSearch', values),
            ),
            const SizedBox(height: 18),
            _filterEditor(
              context: context,
              search: search,
              filters: filters,
              availableFields: availableFields,
            ),
          ],
        );
      },
    );
  }

  List<String> _stringList(dynamic value) => value is List
      ? value.map((item) => item.toString()).toList()
      : <String>[];

  List<Map<String, dynamic>> _mapList(dynamic value) => value is List
      ? value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
      : <Map<String, dynamic>>[];

  Map<String, dynamic> _sortMap(Map<String, dynamic> grid) =>
      grid['defaultSort'] is Map
      ? Map<String, dynamic>.from(grid['defaultSort'] as Map)
      : <String, dynamic>{};

  Widget _numberInput({
    required String label,
    required dynamic value,
    required ValueChanged<int> onSubmitted,
  }) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      onFieldSubmitted: (text) {
        final parsed = int.tryParse(text);
        if (parsed != null) onSubmitted(parsed);
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _sortField({
    required BuildContext context,
    required Map<String, dynamic> grid,
    required List<String> availableFields,
  }) {
    final sort = _sortMap(grid);
    final fields = sort['fields'] is List
        ? _stringList(sort['fields'])
        : <String>[];
    final current = fields.isNotEmpty ? fields.first : '';
    final options = <String>[
      '',
      ...availableFields.where((field) => field != ''),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: options.contains(current) ? current : '',
        decoration: const InputDecoration(
          labelText: 'Sort field',
          border: OutlineInputBorder(),
        ),
        items: options
            .map(
              (field) => DropdownMenuItem<String>(
                value: field,
                child: Text(field.isEmpty ? 'None' : field),
              ),
            )
            .toList(),
        onChanged: availableFields.isEmpty
            ? null
            : (value) {
                final updatedSort = Map<String, dynamic>.from(sort);
                if (value == null || value.isEmpty) {
                  updatedSort.remove('fields');
                } else {
                  updatedSort['fields'] = [value];
                }
                _updateGrid(context, grid, 'defaultSort', updatedSort);
              },
      ),
    );
  }

  Widget _select({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: options.contains(value) ? value : options.first,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (next) {
          if (next != null) onChanged(next);
        },
        items: options
            .map(
              (option) =>
                  DropdownMenuItem<String>(value: option, child: Text(option)),
            )
            .toList(),
      ),
    );
  }

  Widget _stringListEditor({
    required BuildContext context,
    required String title,
    required List<String> values,
    required List<String> availableFields,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...values.asMap().entries.map(
          (entry) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(entry.value),
            trailing: IconButton(
              tooltip: 'Remove field',
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                final updated = List<String>.from(values)..removeAt(entry.key);
                onChanged(updated);
              },
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final field = await _chooseField(
              context,
              title: 'Add quick-search field',
              fields: availableFields
                  .where((field) => !values.contains(field))
                  .toList(),
            );
            if (field != null) onChanged([...values, field]);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add field'),
        ),
      ],
    );
  }

  Widget _filterEditor({
    required BuildContext context,
    required Map<String, dynamic> search,
    required List<Map<String, dynamic>> filters,
    required List<String> availableFields,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filters', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...filters.asMap().entries.map(
          (entry) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              entry.value['label']?.toString() ??
                  entry.value['field']?.toString() ??
                  'Filter',
            ),
            trailing: IconButton(
              tooltip: 'Remove filter',
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                final updated = List<Map<String, dynamic>>.from(filters)
                  ..removeAt(entry.key);
                _updateSearch(context, search, 'filters', updated);
              },
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final existing = filters
                .map((filter) => filter['field']?.toString())
                .whereType<String>()
                .toSet();
            final field = await _chooseField(
              context,
              title: 'Add filter field',
              fields: availableFields
                  .where((field) => !existing.contains(field))
                  .toList(),
            );
            if (field == null) return;
            _updateSearch(context, search, 'filters', [
              ...filters,
              {'field': field, 'label': field},
            ]);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add filter'),
        ),
      ],
    );
  }

  Future<String?> _chooseField(
    BuildContext context, {
    required String title,
    required List<String> fields,
  }) {
    if (fields.isEmpty) return Future<String?>.value();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(title),
        children: fields
            .map(
              (field) => SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, field),
                child: Text(field),
              ),
            )
            .toList(),
      ),
    );
  }

  void _updateGrid(
    BuildContext context,
    Map<String, dynamic> grid,
    String property,
    dynamic value,
  ) {
    final updated = Map<String, dynamic>.from(grid)..[property] = value;
    context.read<MetadataBloc>().add(UpdateRootProperty('grid', updated));
  }

  void _updateSort(
    BuildContext context,
    Map<String, dynamic> grid,
    String property,
    dynamic value,
  ) {
    final sort = _sortMap(grid)..[property] = value;
    _updateGrid(context, grid, 'defaultSort', sort);
  }

  void _updateSearch(
    BuildContext context,
    Map<String, dynamic> search,
    String property,
    dynamic value,
  ) {
    final updated = Map<String, dynamic>.from(search)..[property] = value;
    context.read<MetadataBloc>().add(UpdateRootProperty('search', updated));
  }
}
