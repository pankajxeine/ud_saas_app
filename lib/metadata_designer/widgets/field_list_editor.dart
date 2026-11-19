import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ud_sass_app/core/forms/app_reactive_form.dart';
import 'package:ud_sass_app/core/forms/helper/entity_meta_helper.dart';
import 'package:ud_sass_app/core/forms/models/entity_meta.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../models/metadata_field.dart';
import 'helper/field_json_convertor.dart';

/// Edits one field using the current field metadata contract.
///
/// Nested objects are represented as `group` fields and object arrays use
/// `itemMeta`, which is rendered by the shared reactive form array renderer.
class FieldEditor extends StatefulWidget {
  const FieldEditor({
    super.key,
    required this.fields,
    this.mode = EntityMode.edit,
    this.selectedField,
  });

  final List<MetadataField> fields;
  final EntityMode mode;
  final String? selectedField;

  static final EntityMeta metadata = entityMetaFromJson(_fieldSchema);

  static const Map<String, dynamic> _fieldSchema = {
    'entityName': 'Field Configuration',
    'fields': [
      {
        'name': 'name',
        'label': 'Field name',
        'type': 'text',
        'validationRules': {'required': true},
      },
      {
        'name': 'label',
        'label': 'Label',
        'type': 'text',
        'validationRules': {'required': true},
      },
      {
        'name': 'type',
        'label': 'Data type',
        'type': 'select',
        'options': [
          {'label': 'String', 'value': 'string'},
          {'label': 'UUID', 'value': 'uuid'},
          {'label': 'Integer', 'value': 'integer'},
          {'label': 'Number', 'value': 'number'},
          {'label': 'Boolean', 'value': 'boolean'},
          {'label': 'Date time', 'value': 'datetime'},
          {'label': 'Object', 'value': 'object'},
          {'label': 'Array', 'value': 'array'},
        ],
      },
      {
        'name': 'format',
        'label': 'Format',
        'type': 'text',
        'placeholder': 'string, uuid, date-time...',
      },
      {
        'name': 'widget',
        'label': 'Widget',
        'type': 'select',
        'options': [
          {'label': 'Text', 'value': 'text'},
          {'label': 'Textarea', 'value': 'textarea'},
          {'label': 'Number', 'value': 'number'},
          {'label': 'Switch', 'value': 'switch'},
          {'label': 'Select', 'value': 'select'},
          {'label': 'Reference', 'value': 'reference'},
          {'label': 'Date', 'value': 'date'},
          {'label': 'Array', 'value': 'array'},
          {'label': 'Group', 'value': 'group'},
        ],
      },
      {'name': 'group', 'label': 'UI group', 'type': 'text'},
      {'name': 'title', 'label': 'Title', 'type': 'text'},
      {'name': 'description', 'label': 'Description', 'type': 'textarea'},
      {
        'name': 'ui',
        'label': 'UI configuration',
        'type': 'group',
        'fields': [
          {'name': 'label', 'label': 'UI label', 'type': 'text'},
          {'name': 'placeholder', 'label': 'Placeholder', 'type': 'text'},
          {'name': 'hint', 'label': 'Hint', 'type': 'text'},
          {'name': 'tooltip', 'label': 'Tooltip', 'type': 'text'},
          {'name': 'helperText', 'label': 'Helper text', 'type': 'text'},
          {'name': 'icon', 'label': 'Icon', 'type': 'text'},
          {
            'name': 'hidden',
            'label': 'Hidden',
            'type': 'boolean',
            'initialValue': false,
          },
        ],
      },
      {
        'name': 'permissions',
        'label': 'Permissions',
        'type': 'group',
        'fields': [
          {
            'name': 'read',
            'label': 'Read',
            'type': 'boolean',
            'initialValue': true,
          },
          {
            'name': 'create',
            'label': 'Create',
            'type': 'boolean',
            'initialValue': true,
          },
          {
            'name': 'update',
            'label': 'Update',
            'type': 'boolean',
            'initialValue': true,
          },
        ],
      },
      {
        'name': 'security',
        'label': 'Security',
        'type': 'group',
        'fields': [
          {
            'name': 'permissions',
            'label': 'Security permissions',
            'type': 'group',
            'fields': [
              {'name': 'read', 'label': 'Read permission', 'type': 'text'},
              {'name': 'create', 'label': 'Create permission', 'type': 'text'},
              {'name': 'update', 'label': 'Update permission', 'type': 'text'},
            ],
          },
          {
            'name': 'masking',
            'label': 'Masking',
            'type': 'group',
            'fields': [
              {
                'name': 'enabled',
                'label': 'Enabled',
                'type': 'boolean',
                'initialValue': false,
              },
              {
                'name': 'strategy',
                'label': 'Strategy',
                'type': 'text',
                'initialValue': 'none',
              },
            ],
          },
        ],
      },
      {
        'name': 'visibility',
        'label': 'Visibility',
        'type': 'group',
        'fields': [
          {
            'name': 'show',
            'label': 'Show in',
            'type': 'multiselect',
            'options': [
              {'label': 'Create', 'value': 'create'},
              {'label': 'Edit', 'value': 'edit'},
              {'label': 'Table', 'value': 'table'},
              {'label': 'Detail', 'value': 'detail'},
            ],
          },
          {
            'name': 'required',
            'label': 'Required in',
            'type': 'multiselect',
            'options': [
              {'label': 'Create', 'value': 'create'},
              {'label': 'Edit', 'value': 'edit'},
            ],
          },
          {
            'name': 'readOnly',
            'label': 'Read only in',
            'type': 'multiselect',
            'options': [
              {'label': 'Create', 'value': 'create'},
              {'label': 'Edit', 'value': 'edit'},
            ],
          },
        ],
      },
      {
        'name': 'reference',
        'label': 'Reference',
        'type': 'group',
        'fields': [
          {'name': 'table', 'label': 'Table', 'type': 'text'},
          {'name': 'column', 'label': 'Column', 'type': 'text'},
          {
            'name': 'lookup',
            'label': 'Lookup',
            'type': 'group',
            'fields': [
              {'name': 'endpoint', 'label': 'Endpoint', 'type': 'text'},
              {
                'name': 'strategy',
                'label': 'Strategy',
                'type': 'text',
                'initialValue': 'remote',
              },
              {'name': 'valueField', 'label': 'Value field', 'type': 'text'},
              {
                'name': 'displayField',
                'label': 'Display field',
                'type': 'text',
                'initialValue': 'name',
              },
            ],
          },
        ],
      },
      {
        'name': 'validation',
        'label': 'Validation',
        'type': 'array',
        'itemMeta': {
          'name': 'validationRule',
          'label': 'Validation rule',
          'type': 'group',
          'fields': [
            {
              'name': 'type',
              'label': 'Type',
              'type': 'text',
              'validationRules': {'required': true},
            },
            {'name': 'value', 'label': 'Value', 'type': 'text'},
          ],
        },
      },
      {
        'name': 'rules',
        'label': 'Conditional rules',
        'type': 'array',
        'itemMeta': {
          'name': 'rule',
          'label': 'Rule',
          'type': 'group',
          'fields': [
            {
              'name': 'condition',
              'label': 'Condition',
              'type': 'group',
              'fields': [
                {'name': 'field', 'label': 'Field', 'type': 'text'},
                {
                  'name': 'operator',
                  'label': 'Operator',
                  'type': 'text',
                  'initialValue': '=',
                },
                {'name': 'value', 'label': 'Value', 'type': 'text'},
              ],
            },
            {
              'name': 'actions',
              'label': 'Actions',
              'type': 'array',
              'itemMeta': {
                'name': 'action',
                'label': 'Action',
                'type': 'group',
                'fields': [
                  {'name': 'type', 'label': 'Type', 'type': 'text'},
                  {
                    'name': 'value',
                    'label': 'Value',
                    'type': 'boolean',
                    'initialValue': true,
                  },
                ],
              },
            },
          ],
        },
      },
    ],
  };

  @override
  State<FieldEditor> createState() => _FieldEditorState();
}

class _FieldEditorState extends State<FieldEditor> {
  late List<MetadataField> _currentFields;
  String? _selectedFieldName;

  @override
  void initState() {
    super.initState();
    _currentFields = List<MetadataField>.from(widget.fields);
    _selectedFieldName =
        widget.selectedField ??
        (_currentFields.isNotEmpty ? _currentFields.first.name : null);
  }

  @override
  void didUpdateWidget(covariant FieldEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fields != widget.fields) {
      _currentFields = List<MetadataField>.from(widget.fields);
      if (!_currentFields.any((field) => field.name == _selectedFieldName)) {
        _selectedFieldName = _currentFields.isNotEmpty
            ? _currentFields.first.name
            : null;
      }
    }
  }

  Map<String, dynamic>? _selectedFieldJson() {
    for (final field in _currentFields) {
      if (field.name == _selectedFieldName) return field.toJson();
    }
    return null;
  }

  Future<void> _saveField(Map<String, dynamic> formData) async {
    final original = _selectedFieldJson();
    if (original == null || _selectedFieldName == null) return;

    final updatedJson = fieldFromFormData(formData, original)
      ..['name'] = _selectedFieldName;
    final updatedField = MetadataField.fromJson(updatedJson);

    setState(() {
      _currentFields = _currentFields
          .map(
            (field) => field.name == _selectedFieldName ? updatedField : field,
          )
          .toList();
    });

    if (!mounted) return;
    context.read<MetadataBloc>().add(
      UpdateRootProperty(
        'fields',
        _currentFields.map((field) => field.toJson()).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialData = _selectedFieldJson();
    if (initialData == null || _selectedFieldName == null) {
      return const Center(child: Text('No fields available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 280,
            child: DropdownMenu<String>(
              enableSearch: true,
              enableFilter: true,
              initialSelection: _selectedFieldName,
              label: const Text('Select field'),
              onSelected: (value) {
                if (value != null) {
                  setState(() => _selectedFieldName = value);
                }
              },
              dropdownMenuEntries: _currentFields
                  .map(
                    (field) => DropdownMenuEntry<String>(
                      value: field.name,
                      label: field.ui['label']?.toString() ?? field.label,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AppReactiveForm(
              key: ValueKey(
                'field-$_selectedFieldName-${jsonEncode(initialData)}',
              ),
              meta: FieldEditor.metadata,
              mode: widget.mode,
              initialData: fieldToFormData(initialData),
              onSubmit: _saveField,
            ),
          ),
        ),
      ],
    );
  }
}
