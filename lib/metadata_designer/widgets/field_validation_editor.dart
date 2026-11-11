import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/ui/dashcn/components/input.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/button/button.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';

class FieldValidationEditor extends StatefulWidget {
  const FieldValidationEditor({super.key});

  @override
  State<FieldValidationEditor> createState() => _FieldValidationEditorState();
}

class _FieldValidationEditorState extends State<FieldValidationEditor> {
  late final TextEditingController _controller;
  String? _error;
  String? _loadedField;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void _load(Map<String, dynamic> field) {
    final name = field['name']?.toString();

    if (_loadedField == name) return;

    _loadedField = name;
    _controller.text = const JsonEncoder.withIndent('  ').convert(
      field['validations'] is Map ? field['validations'] : <String, dynamic>{},
    );
    _error = null;
  }

  void _apply(BuildContext context, String fieldName) {
    try {
      final decoded = jsonDecode(_controller.text);

      if (decoded is! Map) {
        setState(() => _error = 'Validations must be a JSON object.');
        return;
      }

      context.read<MetadataBloc>().add(
        UpdateFieldProperty(
          fieldName,
          'validations',
          Map<String, dynamic>.from(decoded),
        ),
      );

      setState(() => _error = null);
    } on FormatException catch (error) {
      setState(() => _error = error.message);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataBloc, MetadataState>(
      builder: (context, state) {
        final fieldName = state.selectedField;

        if (fieldName == null) {
          return const Center(child: Text('Select a field first.'));
        }

        final field = (state.metadata?.schemaJson.fields as List? ?? [])
            .whereType<Map>()
            .cast<Map>()
            .where((item) => item['name'] == fieldName)
            .firstOrNull;

        if (field == null) {
          return const Center(child: Text('Field not found.'));
        }

        final selectedField = Map<String, dynamic>.from(field);
        _load(selectedField);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Validation rules — ${selectedField['label'] ?? fieldName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Edit the validation object. Existing and custom rules are preserved.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFB91C1C)),
                ),
              ),
            Expanded(
              child: Input(
                controller: _controller,
                expands: true,
                minLines: null,
                maxLines: null,
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Button(
                variant: ButtonVariant.primary,
                onPressed: () => _apply(context, fieldName),
                child: const Text('Apply validations'),
              ),
            ),
          ],
        );
      },
    );
  }
}
