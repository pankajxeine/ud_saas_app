import 'package:flutter/widgets.dart';
import 'package:ud_sass_app/ui/dashcn/components/checkbox.dart';
import 'package:ud_sass_app/ui/dashcn/components/input.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/button/button.dart';

import '../models/metadata_schema.dart';
import '../models/metadata_field.dart';

enum MetadataViewMode { create, update, detail }

class MetadataView extends StatefulWidget {
  final MetadataSchema metadata;
  final MetadataViewMode mode;
  final Map<String, dynamic> initialValues;
  final ValueChanged<Map<String, dynamic>>? onChanged;
  final ValueChanged<Map<String, dynamic>>? onSubmit;

  const MetadataView({
    super.key,
    required this.metadata,
    required this.mode,
    this.initialValues = const {},
    this.onChanged,
    this.onSubmit,
  });

  @override
  State<MetadataView> createState() => _MetadataViewState();
}

class _MetadataViewState extends State<MetadataView> {
  late Map<String, dynamic> values;
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    values = Map<String, dynamic>.from(widget.initialValues);
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final field in widget.metadata.fields) {
      if (_isBoolean(field)) continue;

      controllers[field.name] = TextEditingController(
        text:
            values[field.name]?.toString() ??
            field.defaultValue?.toString() ??
            '',
      );
    }
  }

  bool _isBoolean(MetadataField field) {
    return field.type == 'boolean' ||
        field.widget == 'checkbox' ||
        field.widget == 'switch';
  }

  bool _isVisible(MetadataField field) {
    if (field.deprecated) return false;

    switch (widget.mode) {
      case MetadataViewMode.create:
        return field.showInCreate && field.permissions['create'] != false;
      case MetadataViewMode.update:
        return field.showInUpdate && field.permissions['update'] != false;
      case MetadataViewMode.detail:
        return field.showInDetail &&
            field.permissions['read'] != false &&
            !field.writeOnly;
    }
  }

  bool _isReadOnly(MetadataField field) {
    return widget.mode == MetadataViewMode.detail ||
        field.readOnly ||
        (widget.mode == MetadataViewMode.update &&
            field.permissions['update'] == false);
  }

  void _updateValue(MetadataField field, dynamic value) {
    setState(() {
      values[field.name] = value;
    });

    widget.onChanged?.call(Map<String, dynamic>.from(values));
  }

  String? _validate(MetadataField field) {
    final value = values[field.name];

    final required = widget.mode == MetadataViewMode.create
        ? field.requiredOnCreate
        : widget.mode == MetadataViewMode.update
        ? field.requiredOnUpdate
        : false;

    if (required && (value == null || value.toString().trim().isEmpty)) {
      return '${field.label} is required.';
    }

    return null;
  }

  Widget _buildField(MetadataField field) {
    final value = values[field.name] ?? field.defaultValue;

    if (_isBoolean(field)) {
      final checked = value == true;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(field.label)),
            Checkbox(
              value: checked ? CheckboxValue.checked : CheckboxValue.unchecked,
              onChanged: _isReadOnly(field)
                  ? null
                  : (next) =>
                        _updateValue(field, next == CheckboxValue.checked),
            ),
          ],
        ),
      );
    }

    if (widget.mode == MetadataViewMode.detail) {
      return _detailValue(field, value);
    }

    final controller = controllers[field.name]!;
    final numeric = field.type == 'integer' || field.type == 'number';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                field.label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (widget.mode == MetadataViewMode.create &&
                      field.requiredOnCreate ||
                  widget.mode == MetadataViewMode.update &&
                      field.requiredOnUpdate)
                const Text(' *', style: TextStyle(color: Color(0xFFDC2626))),
            ],
          ),
          const SizedBox(height: 6),
          Input(
            controller: controller,
            enabled: !_isReadOnly(field),
            placeholder: Text(field.description ?? field.label),
            onChanged: (text) {
              dynamic parsed = text;

              if (numeric && text.isNotEmpty) {
                parsed = field.type == 'integer'
                    ? int.tryParse(text) ?? text
                    : num.tryParse(text) ?? text;
              }

              _updateValue(field, parsed);
            },
          ),
          if (field.description != null) ...[
            const SizedBox(height: 4),
            Text(
              field.description!,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
          if (_validate(field) != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _validate(field)!,
                style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailValue(MetadataField field, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              field.label,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? '-')),
        ],
      ),
    );
  }

  void _submit() {
    final errors = widget.metadata.fields
        .where(_isVisible)
        .map(_validate)
        .whereType<String>()
        .toList();

    if (errors.isNotEmpty) {
      setState(() {});
      return;
    }

    widget.onSubmit?.call(Map<String, dynamic>.from(values));
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.metadata.fields.where(_isVisible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.metadata.title ?? widget.metadata.entity ?? 'Record',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Expanded(child: ListView(children: fields.map(_buildField).toList())),
        if (widget.mode != MetadataViewMode.detail && widget.onSubmit != null)
          Align(
            alignment: Alignment.centerRight,
            child: Button(
              onPressed: _submit,
              child: Text(
                widget.mode == MetadataViewMode.create
                    ? 'Create'
                    : 'Save changes',
              ),
            ),
          ),
      ],
    );
  }
}
