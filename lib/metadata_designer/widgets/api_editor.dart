import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ud_sass_app/core/forms/models/entity_meta.dart';
import 'package:ud_sass_app/core/forms/helper/entity_meta_helper.dart';
import 'package:ud_sass_app/core/forms/forms.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../models/metadata_api.dart';

class ApiEditor extends StatefulWidget {
  const ApiEditor({
    super.key,
    this.api,
    this.mode = EntityMode.edit,
    this.selectedOperation = 'list',
  });

  /// API configuration received from the parent.
  final MetadataApi? api;

  final EntityMode mode;

  /// Initial dropdown selection.
  final String selectedOperation;

  static const List<String> operations = [
    'list',
    'create',
    'detail',
    'update',
    'delete',
  ];

  static const List<String> methods = ['get', 'post', 'put', 'delete', 'patch'];

  static const Map<String, dynamic> _schema = {
    "name": "api",
    "label": "API Configuration",
    "type": "array",
    "widget": "array",
    "fields": [
      {
        "name": "path",
        "label": "Path",
        "type": "text",
        "widget": "text",
        "required": true,
      },
      {
        "name": "enabled",
        "label": "Enabled",
        "type": "boolean",
        "widget": "switch",
        "default": true,
      },
      {
        "name": "permission",
        "label": "Permission",
        "type": "text",
        "widget": "text",
      },
    ],
  };

  static final EntityMeta _metadata = entityMetaFromJson(_schema);

  @override
  State<ApiEditor> createState() => _ApiEditorState();
}

class _ApiEditorState extends State<ApiEditor> {
  late String _selectedOperation;

  /// Local copy prevents us from depending on a potentially stale parent
  /// value while successive operations are being edited.
  late MetadataApi _currentApi;

  @override
  void initState() {
    super.initState();

    _currentApi = widget.api ?? const MetadataApi(operations: []);

    _selectedOperation = ApiEditor.operations.contains(widget.selectedOperation)
        ? widget.selectedOperation
        : ApiEditor.operations.first;
  }

  @override
  void didUpdateWidget(covariant ApiEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Synchronize when the parent provides a newer API configuration.
    if (oldWidget.api != widget.api && widget.api != null) {
      _currentApi = widget.api!;
    }

    if (oldWidget.selectedOperation != widget.selectedOperation &&
        ApiEditor.operations.contains(widget.selectedOperation)) {
      _selectedOperation = widget.selectedOperation;
    }
  }

  /// Returns the selected operation.
  ///
  /// If the operation does not exist yet, return a default configuration.
  ApiOperation _getSelectedOperation() {
    return _currentApi.getOperation(_selectedOperation) ??
        ApiOperation.empty(
          operation: _selectedOperation,
          path: '',
          enabled: true,
          permission: '',
        );
  }

  /// Converts the selected operation into the generic form's initial data.
  Map<String, dynamic> _getInitialData() {
    return _getSelectedOperation().toJson();
  }

  /// Saves the selected operation into the API array.
  Future<void> _saveOperation(Map<String, dynamic> formData) async {
    final updatedData = <String, dynamic>{
      ...formData,
      // Keep operation identity controlled by the dropdown.
      'operation': _selectedOperation,
    };

    final updatedOperation = ApiOperation.fromJson(updatedData);

    // Update local state immediately so the next operation edit uses
    // the latest API configuration.
    setState(() {
      _currentApi = _currentApi.updateOperation(updatedOperation);
    });

    // The parent metadata editor owns persistence and the root API value.
    if (!mounted) return;

    context.read<MetadataBloc>().add(
      UpdateRootProperty('api', _currentApi.toJson()),
    );
  }

  Map<String, dynamic> entityToFormData({
    required List<ApiOperation> apiOperations,
  }) {
    return {
      'api': apiOperations.map((operation) {
        final json = operation.toJson();

        return {
          'operation': json['operation']?.toString() ?? 'list',
          'path': json['path']?.toString() ?? '',
          'enabled': json['enabled'] as bool? ?? true,
          'permission': json['permission']?.toString() ?? '',
        };
      }).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final initialData = _getInitialData();
    //final initialData = entityToFormData(apiOperations: _currentApi.operations);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Operation selector.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: 240,
            child: DropdownMenu<String>(
              initialSelection: _selectedOperation,
              label: const Text('Select API operation'),
              onSelected: (String? value) {
                if (value == null || value == _selectedOperation) {
                  return;
                }

                setState(() {
                  _selectedOperation = value;
                });
              },
              dropdownMenuEntries: ApiEditor.operations
                  .map(
                    (operation) => DropdownMenuEntry<String>(
                      value: operation,
                      label: _operationLabel(operation),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),

        const Divider(),

        // Selected operation form.
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AppReactiveForm(
              // Recreate the form when the selected operation or its
              // initial data changes.
              key: ValueKey(
                'api-operation-$_selectedOperation-${jsonEncode(initialData)}',
              ),
              meta: ApiEditor._metadata,
              mode: widget.mode == EntityMode.edit
                  ? EntityMode.edit
                  : EntityMode.create,
              initialData: initialData,
              onSubmit: (data) async {
                print("API EDITOR DATA SAVE: $data");
                // await _saveOperation(data);
              },
            ),
          ),
        ),
      ],
    );
  }

  String _operationLabel(String operation) {
    if (operation.isEmpty) return operation;

    return '${operation[0].toUpperCase()}${operation.substring(1)}';
  }
}
