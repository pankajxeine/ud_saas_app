import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/lucide_icons.dart';
import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';

class DetailEditor extends StatelessWidget {
  const DetailEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataBloc, MetadataState>(
      builder: (context, state) {
        final detail = Map<String, dynamic>.from(
          (state.metadata?.schemaJson.detail as Map?) ?? {},
        );

        final detailFields = List<dynamic>.from(
          detail['fields'] as List? ?? [],
        );

        final availableFields =
            (state.metadata?.schemaJson.fields as List? ?? [])
                .whereType<Map>()
                .map((field) => field['name'].toString())
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Detail view',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                Button(
                  variant: ButtonVariant.outline,
                  onPressed: availableFields.isEmpty
                      ? null
                      : () => _addField(
                          context,
                          detail,
                          detailFields,
                          availableFields,
                        ),
                  child: const Text('+ Add field'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure which fields appear on the record detail screen.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: detailFields.isEmpty
                  ? const Center(child: Text('No detail fields configured.'))
                  : ReorderableListView.builder(
                      itemCount: detailFields.length,
                      onReorderItem: (oldIndex, newIndex) {
                        final updated = List<dynamic>.from(detailFields);

                        if (newIndex > oldIndex) newIndex--;

                        final item = updated.removeAt(oldIndex);
                        updated.insert(newIndex, item);

                        _save(context, detail, updated);
                      },
                      itemBuilder: (context, index) {
                        final item = detailFields[index];
                        final fieldName = item is Map
                            ? item['name']?.toString() ??
                                  item['field']?.toString() ??
                                  ''
                            : item.toString();

                        return Container(
                          key: ValueKey('$fieldName-$index'),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.gripVertical, size: 16),
                              const SizedBox(width: 10),
                              Expanded(child: Text(fieldName)),
                              GestureDetector(
                                onTap: () {
                                  final updated = List<dynamic>.from(
                                    detailFields,
                                  );

                                  updated.removeAt(index);
                                  _save(context, detail, updated);
                                },
                                child: const Icon(LucideIcons.trash2, size: 17),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _addField(
    BuildContext context,
    Map<String, dynamic> detail,
    List<dynamic> current,
    List<String> available,
  ) {
    final existing = current.map((item) {
      if (item is Map) {
        return item['name'] ?? item['field'];
      }
      return item;
    }).toSet();

    final next = available
        .where((name) => !existing.contains(name))
        .firstOrNull;

    if (next == null) return;

    final updated = List<dynamic>.from(current)..add(next);
    _save(context, detail, updated);
  }

  void _save(
    BuildContext context,
    Map<String, dynamic> detail,
    List<dynamic> fields,
  ) {
    final updated = Map<String, dynamic>.from(detail);
    updated['fields'] = fields;

    context.read<MetadataBloc>().add(UpdateRootProperty('detail', updated));
  }
}
