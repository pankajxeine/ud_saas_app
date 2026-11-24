import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';
import '../models/metadata_field.dart';

class FieldValidationEditor extends StatelessWidget {
  const FieldValidationEditor({super.key});

  static const _operators = [
    '=',
    '!=',
    '>',
    '>=',
    '<',
    '<=',
    'contains',
    'isEmpty',
    'isNotEmpty',
  ];

  static const _actions = [
    'show',
    'hide',
    'enable',
    'disable',
    'setValue',
    'setRequired',
    'clear',
  ];

  static const _validationTypes = [
    ('required', 'Required', 'bool'),
    ('requiredTrue', 'Required true', 'bool'),
    ('email', 'Email', 'bool'),
    ('number', 'Number', 'bool'),
    ('min', 'Minimum value', 'number'),
    ('max', 'Maximum value', 'number'),
    ('minLength', 'Minimum length', 'int'),
    ('maxLength', 'Maximum length', 'int'),
    ('pattern', 'Pattern', 'text'),
    ('creditCard', 'Credit card', 'bool'),
    ('equals', 'Equals', 'json'),
    ('contains', 'Contains', 'list'),
    ('oneOf', 'One of', 'list'),
    ('composeOR', 'Compose OR', 'json'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataBloc, MetadataState>(
      builder: (context, state) {
        final fields = state.metadata?.schemaJson.fields ?? const [];
        if (fields.isEmpty) {
          return const Center(child: Text('No fields available.'));
        }

        final selectedName = state.selectedField != null &&
                fields.any((field) => field.name == state.selectedField)
            ? state.selectedField!
            : fields.first.name;
        final field = fields.firstWhere((item) => item.name == selectedName);
        final validations = _validationMap(field);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedName,
              decoration: const InputDecoration(
                labelText: 'Field',
                border: OutlineInputBorder(),
              ),
              items: fields
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item.name,
                      child: Text(item.label.isEmpty ? item.name : item.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<MetadataBloc>().add(SelectField(value));
                }
              },
            ),
            const SizedBox(height: 20),
            _sectionTitle('Reactive form validations'),
            const SizedBox(height: 8),
            if (validations.isEmpty)
              const Text('No validations configured.')
            else
              ...validations.entries.map(
                (entry) => _validationTile(context, field, validations, entry),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _addValidation(context, field, validations),
              icon: const Icon(Icons.add),
              label: const Text('Add validation'),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Conditional rules'),
            const SizedBox(height: 8),
            if (field.rules.isEmpty)
              const Text('No conditional rules configured.')
            else
              ...field.rules.asMap().entries.map(
                (entry) => _ruleTile(
                  context,
                  field,
                  entry.key,
                  entry.value,
                  fields.map((item) => item.name).toList(),
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _editRule(
                context,
                field,
                availableFields: fields.map((item) => item.name).toList(),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add rule'),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  );

  Map<String, dynamic> _validationMap(MetadataField field) {
    if (field.validations.isNotEmpty) return Map.from(field.validations);
    return {
      for (final item in field.validation.whereType<Map>())
        if (item['type'] != null) item['type'].toString(): item['value'],
    };
  }

  Widget _validationTile(
    BuildContext context,
    MetadataField field,
    Map<String, dynamic> validations,
    MapEntry<String, dynamic> entry,
  ) {
    final label = _validationTypes
        .where((item) => item.$1 == entry.key)
        .map((item) => item.$2)
        .firstOrNull ?? entry.key;

    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(_displayValue(entry.value)),
        trailing: Wrap(
          children: [
            IconButton(
              tooltip: 'Edit validation',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editValidation(
                context,
                field,
                validations,
                entry.key,
                entry.value,
              ),
            ),
            IconButton(
              tooltip: 'Remove validation',
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                final updated = Map<String, dynamic>.from(validations)
                  ..remove(entry.key);
                _saveValidations(context, field.name, updated);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addValidation(
    BuildContext context,
    MetadataField field,
    Map<String, dynamic> validations,
  ) async {
    final result = await _validationDialog(context);
    if (result == null) return;
    final updated = Map<String, dynamic>.from(validations)
      ..[result.key] = result.value;
    _saveValidations(context, field.name, updated);
  }

  Future<void> _editValidation(
    BuildContext context,
    MetadataField field,
    Map<String, dynamic> validations,
    String name,
    dynamic value,
  ) async {
    final result = await _validationDialog(
      context,
      initialName: name,
      initialValue: value,
      lockedName: true,
    );
    if (result == null) return;
    final updated = Map<String, dynamic>.from(validations)
      ..[result.key] = result.value;
    _saveValidations(context, field.name, updated);
  }

  Future<MapEntry<String, dynamic>?> _validationDialog(
    BuildContext context, {
    String? initialName,
    dynamic initialValue,
    bool lockedName = false,
  }) async {
    var selected = initialName ?? _validationTypes.first.$1;
    final controller = TextEditingController(
      text: _valueForEditor(initialValue, _kindFor(selected)),
    );
    var boolValue = initialValue == true;

    final result = await showDialog<MapEntry<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final kind = _kindFor(selected);
          return AlertDialog(
            title: Text(lockedName ? 'Edit validation' : 'Add validation'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selected,
                    decoration: const InputDecoration(labelText: 'Validator'),
                    items: _validationTypes
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.$1,
                            child: Text(item.$2),
                          ),
                        )
                        .toList(),
                    onChanged: lockedName
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              selected = value;
                              controller.text =
                                  _valueForEditor(null, _kindFor(value));
                              boolValue = false;
                            });
                          },
                  ),
                  const SizedBox(height: 12),
                  if (kind == 'bool')
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enabled'),
                      value: boolValue,
                      onChanged: (value) =>
                          setState(() => boolValue = value ?? false),
                    )
                  else
                    TextField(
                      controller: controller,
                      maxLines: kind == 'json' || kind == 'list' ? 4 : 1,
                      decoration: InputDecoration(
                        labelText: kind == 'list'
                            ? 'Values (comma-separated or JSON array)'
                            : 'Value',
                        hintText: kind == 'json' ? 'JSON value' : null,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final value = kind == 'bool'
                      ? boolValue
                      : _parseValue(controller.text, kind);
                  Navigator.pop(
                    dialogContext,
                    MapEntry<String, dynamic>(selected, value),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    controller.dispose();
    return result;
  }

  String _kindFor(String name) => _validationTypes
      .where((item) => item.$1 == name)
      .map((item) => item.$3)
      .firstOrNull ?? 'text';

  String _valueForEditor(dynamic value, String kind) {
    if (value == null) return '';
    if (kind == 'json' || kind == 'list') return jsonEncode(value);
    return value.toString();
  }

  dynamic _parseValue(String value, String kind) {
    final text = value.trim();
    if (kind == 'number') return num.tryParse(text) ?? 0;
    if (kind == 'int') return int.tryParse(text) ?? 0;
    if (kind == 'json') {
      try {
        return jsonDecode(text);
      } catch (_) {
        return text;
      }
    }
    if (kind == 'list') {
      try {
        final decoded = jsonDecode(text);
        if (decoded is List) return decoded;
      } catch (_) {}
      return text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return text;
  }

  String _displayValue(dynamic value) {
    if (value is bool) return value ? 'Enabled' : 'Disabled';
    if (value is Iterable || value is Map) return jsonEncode(value);
    return value?.toString() ?? '';
  }

  void _saveValidations(
    BuildContext context,
    String fieldName,
    Map<String, dynamic> validations,
  ) {
    context.read<MetadataBloc>().add(
      UpdateFieldValidations(fieldName: fieldName, validations: validations),
    );
  }

  Widget _ruleTile(
    BuildContext context,
    MetadataField field,
    int index,
    Map<String, dynamic> rule,
    List<String> availableFields,
  ) {
    final condition = rule['condition'] is Map
        ? Map<String, dynamic>.from(rule['condition'] as Map)
        : <String, dynamic>{};
    final actions = rule['actions'] is List ? rule['actions'] as List : const [];
    final conditionText =
        '${condition['field'] ?? '?'} ${condition['operator'] ?? '='} '
        '${condition['value'] ?? ''}';
    final actionText = actions.isEmpty
        ? 'No action'
        : (actions.first is Map
              ? actions.first['type']?.toString() ?? 'Action'
              : actions.first.toString());

    return Card(
      child: ListTile(
        title: Text(conditionText),
        subtitle: Text('Action: $actionText'),
        trailing: Wrap(
          children: [
            IconButton(
              tooltip: 'Edit rule',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editRule(
                context,
                field,
                index: index,
                rule: rule,
                availableFields: availableFields,
              ),
            ),
            IconButton(
              tooltip: 'Remove rule',
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                final updated = List<Map<String, dynamic>>.from(field.rules)
                  ..removeAt(index);
                _saveRules(context, field.name, updated);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editRule(
    BuildContext context,
    MetadataField field, {
    required List<String> availableFields,
    int? index,
    Map<String, dynamic>? rule,
  }) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => _RuleDialog(
        availableFields: availableFields,
        operators: _operators,
        actions: _actions,
        rule: rule,
      ),
    );
    if (result == null) return;

    final updated = List<Map<String, dynamic>>.from(field.rules);
    if (index == null) {
      updated.add(result);
    } else {
      updated[index] = result;
    }
    _saveRules(context, field.name, updated);
  }

  void _saveRules(
    BuildContext context,
    String fieldName,
    List<Map<String, dynamic>> rules,
  ) {
    context.read<MetadataBloc>().add(
      UpdateMetadataField(fieldName: fieldName, updates: {'rules': rules}),
    );
  }
}

class _RuleDialog extends StatefulWidget {
  const _RuleDialog({
    required this.availableFields,
    required this.operators,
    required this.actions,
    this.rule,
  });

  final List<String> availableFields;
  final List<String> operators;
  final List<String> actions;
  final Map<String, dynamic>? rule;

  @override
  State<_RuleDialog> createState() => _RuleDialogState();
}

class _RuleDialogState extends State<_RuleDialog> {
  late String _field;
  late String _operator;
  late String _action;
  late final TextEditingController _conditionController;
  late final TextEditingController _actionController;

  @override
  void initState() {
    super.initState();
    final condition = widget.rule?['condition'] is Map
        ? Map<String, dynamic>.from(widget.rule!['condition'] as Map)
        : <String, dynamic>{};
    final existingActions = widget.rule?['actions'] is List
        ? widget.rule!['actions'] as List
        : const [];
    final firstAction = existingActions.isNotEmpty && existingActions.first is Map
        ? Map<String, dynamic>.from(existingActions.first as Map)
        : <String, dynamic>{};
    _field = widget.availableFields.contains(condition['field'])
        ? condition['field'].toString()
        : widget.availableFields.first;
    _operator = widget.operators.contains(condition['operator'])
        ? condition['operator'].toString()
        : widget.operators.first;
    _action = widget.actions.contains(firstAction['type'])
        ? firstAction['type'].toString()
        : widget.actions.first;
    _conditionController = TextEditingController(
      text: condition['value']?.toString() ?? '',
    );
    _actionController = TextEditingController(
      text: firstAction['value']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _conditionController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.rule == null ? 'Add rule' : 'Edit rule'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _field,
                decoration: const InputDecoration(labelText: 'When field'),
                items: widget.availableFields
                    .map(
                      (field) => DropdownMenuItem(
                        value: field,
                        child: Text(field),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _field = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _operator,
                decoration: const InputDecoration(labelText: 'Operator'),
                items: widget.operators
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _operator = value!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _conditionController,
                decoration: const InputDecoration(
                  labelText: 'Condition value',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _action,
                decoration: const InputDecoration(labelText: 'Action'),
                items: widget.actions
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _action = value!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _actionController,
                decoration: const InputDecoration(
                  labelText: 'Action value (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'condition': {
                'field': _field,
                'operator': _operator,
                'value': _conditionController.text,
              },
              'actions': [
                {
                  'type': _action,
                  if (_actionController.text.trim().isNotEmpty)
                    'value': _actionController.text.trim(),
                },
              ],
            });
          },
          child: const Text('Save rule'),
        ),
      ],
    );
  }
}
