import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/ui/dashcn/components/alert_dialog.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/components/dialog.dart';
import 'package:ud_sass_app/ui/dashcn/components/input.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/select/select.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/lucide_icons.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';

class GridSearchEditor extends StatelessWidget {
  const GridSearchEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataBloc, MetadataState>(
      builder: (context, state) {
        final grid = Map<String, dynamic>.from(
          (state.metadata?.schemaJson.grid as Map?) ?? {},
        );

        final search = Map<String, dynamic>.from(
          (state.metadata?.schemaJson.search as Map?) ?? {},
        );

        final quickSearch = List<dynamic>.from(
          search['quickSearch'] as List? ?? [],
        );

        final filters = List<dynamic>.from(search['filters'] as List? ?? []);

        return ListView(
          children: [
            const Text(
              'Grid configuration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _numberInput(
              label: 'Page size',
              value: grid['pageSize'] ?? 20,
              onChanged: (value) {
                _updateGrid(context, grid, 'pageSize', value);
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Default sorting',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _input(
              label: 'Sort field',
              value: (grid['defaultSort'] is Map)
                  ? grid['defaultSort']['field']?.toString() ?? ''
                  : '',
              onChanged: (value) {
                _updateSort(context, grid, 'field', value);
              },
            ),
            _select(
              label: 'Sort direction',
              value: (grid['defaultSort'] is Map)
                  ? grid['defaultSort']['direction']?.toString() ?? 'asc'
                  : 'asc',
              options: const ['asc', 'desc'],
              onChanged: (value) {
                _updateSort(context, grid, 'direction', value);
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
              onChanged: (values) {
                _updateSearch(context, search, 'quickSearch', values);
              },
            ),
            const SizedBox(height: 18),
            _filterEditor(context, state, search, filters),
          ],
        );
      },
    );
  }

  Widget _numberInput({
    required String label,
    required dynamic value,
    required ValueChanged<int> onChanged,
  }) {
    return _input(
      label: label,
      value: value.toString(),
      onChanged: (text) {
        final parsed = int.tryParse(text);
        if (parsed != null && parsed > 0) onChanged(parsed);
      },
    );
  }

  Widget _input({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          Input(initialValue: value, onChanged: onChanged),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          Select<String>(
            value: options.contains(value) ? value : options.first,
            onChanged: (next) {
              if (next != null) onChanged(next);
            },
            items: <Widget>[
              for (final String option in options)
                SelectItem<String>(value: option, child: Text(option)),
            ],
            itemBuilder: (context, item) => Text(item),
          ),
        ],
      ),
    );
  }

  Widget _stringListEditor({
    required BuildContext context,
    required String title,
    required List<dynamic> values,
    required ValueChanged<List<dynamic>> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...values.asMap().entries.map((entry) {
          return Row(
            children: [
              Expanded(child: Text(entry.value.toString())),
              GestureDetector(
                onTap: () {
                  final updated = List<dynamic>.from(values)
                    ..removeAt(entry.key);
                  onChanged(updated);
                },
                child: const Icon(LucideIcons.trash2, size: 16),
              ),
            ],
          );
        }),
        Button(
          variant: ButtonVariant.outline,
          onPressed: () async {
            final controller = TextEditingController();
            final value = await showDialog<String>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Add search field'),
                description: Input(
                  controller: controller,
                  placeholder: const Text('Field name'),
                ),
                actions: [
                  Button(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  Button(
                    variant: ButtonVariant.primary,
                    onPressed: () {
                      Navigator.pop(dialogContext, controller.text.trim());
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            );

            if (value != null && value.isNotEmpty) {
              onChanged([...values, value]);
            }
          },
          child: const Text('+ Add field'),
        ),
      ],
    );
  }

  Widget _filterEditor(
    BuildContext context,
    MetadataState state,
    Map<String, dynamic> search,
    List<dynamic> filters,
  ) {
    final available = (state.metadata?.schemaJson.fields as List? ?? [])
        .whereType<Map>()
        .map((field) => field['name'].toString())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filters', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...filters.asMap().entries.map((entry) {
          final item = entry.value;

          final label = item is Map
              ? item['label'] ?? item['field'] ?? item['name'] ?? 'Filter'
              : item.toString();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(child: Text(label.toString())),
                GestureDetector(
                  onTap: () {
                    final updated = List<dynamic>.from(filters)
                      ..removeAt(entry.key);
                    _updateSearch(context, search, 'filters', updated);
                  },
                  child: const Icon(LucideIcons.trash2, size: 16),
                ),
              ],
            ),
          );
        }),
        Button(
          variant: ButtonVariant.outline,
          onPressed: available.isEmpty
              ? null
              : () {
                  final existing = filters.map((item) {
                    if (item is Map) {
                      return item['field'] ?? item['name'];
                    }
                    return item;
                  }).toSet();

                  String? next;

                  for (final name in available) {
                    if (!existing.contains(name)) {
                      next = name;
                      break;
                    }
                  }

                  if (next == null) return;

                  final updated = [
                    ...filters,
                    {'field': next, 'label': next},
                  ];

                  _updateSearch(context, search, 'filters', updated);
                },
          child: const Text('+ Add filter'),
        ),
      ],
    );
  }

  void _updateGrid(
    BuildContext context,
    Map<String, dynamic> grid,
    String property,
    dynamic value,
  ) {
    final updated = Map<String, dynamic>.from(grid);
    updated[property] = value;

    context.read<MetadataBloc>().add(UpdateRootProperty('grid', updated));
  }

  void _updateSort(
    BuildContext context,
    Map<String, dynamic> grid,
    String property,
    dynamic value,
  ) {
    final sort = Map<String, dynamic>.from((grid['defaultSort'] as Map?) ?? {});

    sort[property] = value;

    final updated = Map<String, dynamic>.from(grid);
    updated['defaultSort'] = sort;

    context.read<MetadataBloc>().add(UpdateRootProperty('grid', updated));
  }

  void _updateSearch(
    BuildContext context,
    Map<String, dynamic> search,
    String property,
    dynamic value,
  ) {
    final updated = Map<String, dynamic>.from(search);
    updated[property] = value;

    context.read<MetadataBloc>().add(UpdateRootProperty('search', updated));
  }
}
