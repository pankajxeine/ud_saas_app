import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/ui/dashcn/components/input.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/select/select.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';

class ReferenceLookupEditor extends StatelessWidget {
  const ReferenceLookupEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataBloc, MetadataState>(
      builder: (context, state) {
        final fieldName = state.selectedField;

        if (fieldName == null) {
          return const Center(
            child: Text('Select a field to configure its lookup.'),
          );
        }

        final fields = (state.metadata?.schemaJson.fields as List? ?? [])
            .whereType<Map>();

        Map<String, dynamic>? field;

        for (final item in fields) {
          if (item['name'] == fieldName) {
            field = Map<String, dynamic>.from(item);
            break;
          }
        }

        if (field == null) {
          return const Center(child: Text('Field not found.'));
        }

        final reference = Map<String, dynamic>.from(
          (field['reference'] as Map?) ?? {},
        );

        final lookup = Map<String, dynamic>.from(
          (reference['lookup'] as Map?) ?? {},
        );

        return ListView(
          children: [
            Text(
              'Lookup: ${field['label'] ?? fieldName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Configure the external or relational data source.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            _input(
              label: 'Reference table',
              value: reference['table']?.toString() ?? '',
              onChanged: (value) => _updateReference(
                context,
                fieldName,
                reference,
                lookup,
                'table',
                value,
              ),
            ),
            _input(
              label: 'Reference column',
              value: reference['column']?.toString() ?? '',
              onChanged: (value) => _updateReference(
                context,
                fieldName,
                reference,
                lookup,
                'column',
                value,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Lookup configuration',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _select(
              label: 'Lookup strategy',
              value: lookup['strategy']?.toString() ?? 'remote',
              options: const ['remote', 'local', 'static'],
              onChanged: (value) => _updateLookup(
                context,
                fieldName,
                reference,
                lookup,
                'strategy',
                value,
              ),
            ),
            _input(
              label: 'Endpoint',
              value: lookup['endpoint']?.toString() ?? '',
              onChanged: (value) => _updateLookup(
                context,
                fieldName,
                reference,
                lookup,
                'endpoint',
                value,
              ),
            ),
            _input(
              label: 'Display field',
              value: lookup['displayField']?.toString() ?? '',
              onChanged: (value) => _updateLookup(
                context,
                fieldName,
                reference,
                lookup,
                'displayField',
                value,
              ),
            ),
            _input(
              label: 'Value field',
              value: lookup['valueField']?.toString() ?? '',
              onChanged: (value) => _updateLookup(
                context,
                fieldName,
                reference,
                lookup,
                'valueField',
                value,
              ),
            ),
          ],
        );
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

  void _updateReference(
    BuildContext context,
    String fieldName,
    Map<String, dynamic> reference,
    Map<String, dynamic> lookup,
    String property,
    dynamic value,
  ) {
    final updated = Map<String, dynamic>.from(reference);
    updated[property] = value;

    _save(context, fieldName, updated);
  }

  void _updateLookup(
    BuildContext context,
    String fieldName,
    Map<String, dynamic> reference,
    Map<String, dynamic> lookup,
    String property,
    dynamic value,
  ) {
    final updatedLookup = Map<String, dynamic>.from(lookup);
    updatedLookup[property] = value;

    final updatedReference = Map<String, dynamic>.from(reference);
    updatedReference['lookup'] = updatedLookup;

    _save(context, fieldName, updatedReference);
  }

  void _save(
    BuildContext context,
    String fieldName,
    Map<String, dynamic> reference,
  ) {
    context.read<MetadataBloc>().add(
      UpdateFieldProperty(fieldName, 'reference', reference),
    );
  }
}
