import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/button/button.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/lucide_icons.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';

class FieldListEditor extends StatelessWidget {
  const FieldListEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataBloc, MetadataState>(
      builder: (context, state) {
        final fields = (state.metadata?.schemaJson.fields as List? ?? [])
            .whereType<Map>()
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Fields',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                Button(
                  variant: ButtonVariant.primary,
                  onPressed: () {
                    context.read<MetadataBloc>().add(const AddMetadataField());
                  },
                  child: const Text('+ Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: fields.isEmpty
                  ? const Center(child: Text('No fields configured'))
                  : ListView.separated(
                      itemCount: fields.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final field = fields[index];
                        final name = field['name']?.toString() ?? '';
                        final label = field['label']?.toString() ?? name;
                        final type = field['type']?.toString() ?? 'string';
                        final selected = state.selectedField == name;

                        return GestureDetector(
                          onTap: () {
                            context.read<MetadataBloc>().add(SelectField(name));
                          },
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFEDE9FE)
                                  : const Color(0xFFF8FAFC),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF8B5CF6)
                                    : const Color(0xFFE2E8F0),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(
                                    LucideIcons.gripVertical,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '$name  ·  $type',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.read<MetadataBloc>().add(
                                        DeleteMetadataField(name),
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(LucideIcons.trash2, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
}
