import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ud_sass_app/core/forms/models/entity_meta.dart';
import 'package:ud_sass_app/core/forms/helper/entity_meta_helper.dart';
import 'package:ud_sass_app/core/forms/app_reactive_form.dart';
import 'package:ud_sass_app/ui/dashcn/components/select.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/divider/divider.dart';
import 'helper/field_json_convertor.dart';
import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../models/metadata_field.dart';

class FieldEditor extends StatefulWidget {
  const FieldEditor({
    super.key,
    required this.fields,
    this.mode = EntityMode.edit,
    this.selectedField,
  });

  final List<MetadataField> fields;
  final EntityMode mode;

  /// Name of the initially selected field.
  final String? selectedField;

  static const Map<String, dynamic> _schema = {
    'entityName': 'Field Configuration',

    'fields': [
      // ==========================================================
      // BASIC INFORMATION
      // ==========================================================
      {
        'name': 'name',
        'label': 'Field Name',
        'widget': 'text',
        'type': 'text',
        'required': true,
        'validationRules': {'required': true, 'minLength': 3, 'maxLength': 100},
        'layout': {'mobileColSpan': 1, 'tabletColSpan': 1, 'desktopColSpan': 2},
      },
      {
        'name': 'label',
        'label': 'Label',
        'type': 'text',
        'widget': 'text',
        'required': true,
        'layout': {'mobileColSpan': 1, 'tabletColSpan': 1, 'desktopColSpan': 2},
      },
      {
        'name': 'type',
        'label': 'Data Type',
        'type': 'text',
        'widget': 'text',
        'required': true,
        'layout': {'mobileColSpan': 1, 'tabletColSpan': 1, 'desktopColSpan': 2},
      },
      {
        'name': 'widget',
        'label': 'Widget',
        'type': 'text',
        'widget': 'text',
        'required': true,
        'layout': {'mobileColSpan': 1, 'tabletColSpan': 1, 'desktopColSpan': 2},
      },
      {
        'name': 'default',
        'label': 'Default Value',
        'type': 'text',
        'widget': 'text',
        'initialValue': false,
        'layout': {'mobileColSpan': 1, 'tabletColSpan': 1, 'desktopColSpan': 1},
      },

      // ==========================================================
      // UI GROUP
      // ==========================================================
      {
        'name': 'ui',
        'label': 'UI Configuration',
        'type': 'group',
        'widget': 'group',
        'layout': {'mobileColSpan': 1, 'tabletColSpan': 2, 'desktopColSpan': 4},

        'fields': [
          {
            'name': 'label',
            'label': 'UI Label',
            'type': 'text',
            'widget': 'text',
            'layout': {
              'mobileColSpan': 1,
              'tabletColSpan': 1,
              'desktopColSpan': 2,
            },
          },
          {
            'name': 'placeholder',
            'label': 'Placeholder',
            'type': 'text',
            'widget': 'text',
            'layout': {
              'mobileColSpan': 1,
              'tabletColSpan': 1,
              'desktopColSpan': 2,
            },
          },
          {
            'name': 'hint',
            'label': 'Hint',
            'type': 'text',
            'widget': 'text',
            'layout': {
              'mobileColSpan': 1,
              'tabletColSpan': 1,
              'desktopColSpan': 2,
            },
          },
          {
            'name': 'helperText',
            'label': 'Helper Text',
            'type': 'text',
            'widget': 'text',
            'layout': {
              'mobileColSpan': 1,
              'tabletColSpan': 1,
              'desktopColSpan': 2,
            },
          },
          {
            'name': 'tooltip',
            'label': 'Tooltip',
            'type': 'text',
            'widget': 'text',
            'layout': {
              'mobileColSpan': 1,
              'tabletColSpan': 1,
              'desktopColSpan': 2,
            },
          },
          {
            'name': 'icon',
            'label': 'Icon',
            'type': 'text',
            'widget': 'text',
            'layout': {
              'mobileColSpan': 1,
              'tabletColSpan': 1,
              'desktopColSpan': 2,
            },
          },
        ],
      },

      // ==========================================================
      // BEHAVIOR
      // ==========================================================
      {
        'name': 'nullable',
        'label': 'Nullable',
        'type': 'boolean',
        'widget': 'switch',
        'initialValue': false,
      },
      {
        'name': 'readOnly',
        'label': 'Read Only',
        'type': 'boolean',
        'widget': 'switch',
        'initialValue': false,
      },
      {
        'name': 'writeOnly',
        'label': 'Write Only',
        'type': 'boolean',
        'widget': 'switch',
        'initialValue': false,
      },
      {
        'name': 'deprecated',
        'label': 'Deprecated',
        'type': 'boolean',
        'widget': 'switch',
        'initialValue': false,
      },

      // ==========================================================
      // PERMISSIONS GROUP
      // ==========================================================
      {
        'name': 'permissions',
        'label': 'Permissions',
        'type': 'group',
        'widget': 'group',
        'layout': {'mobileColSpan': 1, 'tabletColSpan': 2, 'desktopColSpan': 4},

        'fields': [
          {
            'name': 'read',
            'label': 'Allow Read',
            'type': 'boolean',
            'widget': 'switch',
            'initialValue': true,
          },
          {
            'name': 'create',
            'label': 'Allow Create',
            'type': 'boolean',
            'widget': 'switch',
            'initialValue': true,
          },
          {
            'name': 'update',
            'label': 'Allow Update',
            'type': 'boolean',
            'widget': 'switch',
            'initialValue': true,
          },
        ],
      },

      // ==========================================================
      // VISIBILITY
      // ==========================================================
      {
        'name': 'showInTable',
        'label': 'Show In Table',
        'type': 'boolean',
        'widget': 'switch',
        'initialValue': true,
      },
      {
        'name': 'showInCreate',
        'label': 'Show In Create',
        'type': 'boolean',
        'widget': 'switch',
        'initialValue': true,
      },
      {
        'name': 'showInDetail',
        'label': 'Show In Detail',
        'type': 'boolean',
        'widget': 'switch',
        'initialValue': true,
      },
      {
        'name': 'showInUpdate',
        'label': 'Show In Update',
        'type': 'boolean',
        'widget': 'switch',
        'initialValue': true,
      },

      // ==========================================================
      // REQUIRED
      // ==========================================================
      {
        'name': 'requiredOnCreate',
        'label': 'Required On Create',
        'type': 'boolean',
        'widget': 'switch',
        'initialValue': false,
      },
      {
        'name': 'requiredOnUpdate',
        'label': 'Required On Update',
        'type': 'boolean',
        'widget': 'switch',
        'initialValue': false,
      },

      // ==========================================================
      // ADVANCED GROUPS
      // ==========================================================
      {
        'name': 'validations',
        'label': 'Validations',
        'type': 'group',
        'widget': 'group',
        'fields': [],
      },
      {
        'name': 'reference',
        'label': 'Reference',
        'type': 'group',
        'widget': 'group',
        'fields': [],
      },
      {
        'name': 'extra',
        'label': 'Extra Configuration',
        'type': 'group',
        'widget': 'group',
        'fields': [],
      },
    ],
  };
  static final EntityMeta metadata = entityMetaFromJson(_schema);

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
        (_currentFields.isNotEmpty
            ? _currentFields.first.toJson()['name']?.toString()
            : null);
  }

  @override
  void didUpdateWidget(covariant FieldEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.fields != widget.fields) {
      _currentFields = List<MetadataField>.from(widget.fields);

      // Keep the selected field if it still exists.
      final stillExists = _currentFields.any(
        (field) => field.toJson()['name']?.toString() == _selectedFieldName,
      );

      if (!stillExists) {
        _selectedFieldName = _currentFields.isNotEmpty
            ? _currentFields.first.toJson()['name']?.toString()
            : null;
      }
    }
  }

  Map<String, dynamic>? _selectedFieldJson() {
    if (_selectedFieldName == null) return null;

    for (final field in _currentFields) {
      final json = field.toJson();

      if (json['name']?.toString() == _selectedFieldName) {
        return json;
      }
    }

    return null;
  }

  Map<String, dynamic>? _initialData() {
    final json = _selectedFieldJson();

    if (json == null) return null;

    return fieldToFormData(json);
  }

  Future<void> _saveField(Map<String, dynamic> formData) async {
    final original = _selectedFieldJson();

    if (original == null || _selectedFieldName == null) return;

    final updatedJson = fieldFromFormData(formData, original);

    // Preserve the original field name as the array identity.
    updatedJson['name'] = _selectedFieldName;

    final updatedField = MetadataField.fromJson(updatedJson);

    final updatedFields = _currentFields.map((field) {
      if (field.toJson()['name']?.toString() == _selectedFieldName) {
        return updatedField;
      }

      return field;
    }).toList();

    setState(() {
      _currentFields = updatedFields;
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
    final initialData = _initialData();

    print("******************Inital data **************: $initialData");
    if (_currentFields.isEmpty || _selectedFieldName == null) {
      return const Center(child: Text('No fields available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------------
        // Field selector
        // ------------------------------------------------------
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 280,
            child: Select<String>(
              value: _selectedFieldName,
              placeholder: const Text('Select field'),
              onChanged: (String? value) {
                if (value == null || value == _selectedFieldName) {
                  return;
                }

                setState(() {
                  _selectedFieldName = value;
                });
              },
              itemBuilder: (context, value) {
                return Text(value);
              },
              items: [
                for (final field in _currentFields)
                  SelectItem<String>(
                    value: field.toJson()['name'].toString(),
                    child: Text(
                      field.toJson()['label']?.toString() ??
                          field.toJson()['name'].toString(),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const Divider(),

        // ------------------------------------------------------
        // Selected field form
        // ------------------------------------------------------
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AppReactiveForm(
              key: ValueKey(
                'field-$_selectedFieldName-${jsonEncode(initialData)}',
              ),
              meta: FieldEditor.metadata,
              mode: widget.mode,
              initialData: initialData!,
              onSubmit: (data) async {
                await _saveField(data);
              },
            ),
          ),
        ),
      ],
    );
  }
}
