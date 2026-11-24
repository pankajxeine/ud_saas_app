import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ud_sass_app/core/forms/helper/entity_meta_helper.dart';
import 'package:ud_sass_app/core/forms/models/entity_meta.dart';
import 'package:ud_sass_app/core/forms/forms.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../models/metadata_api.dart';
import '../models/api_operation.dart';

class ApiEditor extends StatefulWidget {
  const ApiEditor({
    super.key,
    this.api,
    this.mode = EntityMode.edit,
    this.selectedOperation = 'list',
    this.entity,
  });

  /// API configuration received from parent.
  final MetadataApi? api;

  final EntityMode mode;

  /// Initial dropdown selection.
  final String selectedOperation;

  /// Entity name used for generating default paths and permissions.
  ///
  /// Example: contact
  final String? entity;

  static const Map<String, dynamic> _schema = {
    'name': 'api',
    'label': 'API Configuration',
    'type': 'object',
    'widget': 'group',
    'fields': [
      {
        'name': 'method',
        'label': 'HTTP Method',
        'type': 'select',
        'widget': 'select',
        'required': true,
        'options': [
          {'label': 'GET', 'value': 'GET'},
          {'label': 'POST', 'value': 'POST'},
          {'label': 'PUT', 'value': 'PUT'},
          {'label': 'PATCH', 'value': 'PATCH'},
          {'label': 'DELETE', 'value': 'DELETE'},
        ],
      },
      {
        'name': 'path',
        'label': 'Endpoint Path',
        'type': 'text',
        'widget': 'text',
        'required': true,
      },
      {
        'name': 'enabled',
        'label': 'Enabled',
        'type': 'boolean',
        'widget': 'switch',
        'default': true,
      },
      {
        'name': 'permission',
        'label': 'Permission',
        'type': 'text',
        'widget': 'text',
      },
    ],
  };

  static final EntityMeta _metadata = entityMetaFromJson(_schema);

  @override
  State<ApiEditor> createState() => _ApiEditorState();
}

class _ApiEditorState extends State<ApiEditor> {
  late String _selectedOperation;

  /// Current API configuration.
  late MetadataApi _currentApi;

  /// Current operation being edited.
  late ApiOperationOption _currentOperation;

  @override
  void initState() {
    super.initState();

    _currentApi = widget.api ?? const MetadataApi();

    _selectedOperation = _resolveInitialOperation(widget.selectedOperation);

    _currentOperation = _getSelectedOperation(_selectedOperation);
  }

  @override
  void didUpdateWidget(covariant ApiEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.api != widget.api && widget.api != null) {
      _currentApi = widget.api!;

      _currentOperation = _getSelectedOperation(_selectedOperation);
    }

    if (oldWidget.selectedOperation != widget.selectedOperation) {
      _selectedOperation = _resolveInitialOperation(widget.selectedOperation);

      _currentOperation = _getSelectedOperation(_selectedOperation);
    }
  }

  // ------------------------------------------------------------
  // OPERATION CATALOG
  // ------------------------------------------------------------

  List<ApiOperationOption> get _operationOptions {
    return ApiOperationOptions.all;
  }

  String _resolveInitialOperation(String operation) {
    final exists = _operationOptions.any((item) => item.operation == operation);

    return exists ? operation : ApiOperationOptions.defaults.first.operation!;
  }

  String _operationLabel(ApiOperationOption option) {
    return option.label ?? _capitalize(option.operation ?? '');
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;

    return value
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  // ------------------------------------------------------------
  // OPERATION CONFIGURATION
  // ------------------------------------------------------------

  /// Returns existing operation or creates one from catalog defaults.
  ApiOperationOption _getSelectedOperation(String operation) {
    final existing = _currentApi.getOperation(operation);

    if (existing != null) {
      return existing;
    }

    final catalog = ApiOperationOptions.getByValue(operation);

    if (catalog == null) {
      return ApiOperationOption.empty(
        operation: operation,
        path: '',
        enabled: true,
      );
    }

    final entity = widget.entity;

    return ApiOperationOption.empty(
      operation: operation,
      path: entity != null && entity.isNotEmpty
          ? catalog.buildPath(entity)
          : '',
      method: catalog.method,
      enabled: true,
      permission: entity != null && entity.isNotEmpty
          ? '$entity.operation.$operation'
          : null,
    );
  }

  /// Converts operation into form initial data.
  Map<String, dynamic> _getInitialData() {
    return {
      'method': _currentOperation.effectiveMethod ?? 'GET',
      'path': _currentOperation.path ?? '',
      'enabled': _currentOperation.enabled,
      'permission': _currentOperation.permission ?? '',
    };
  }

  // ------------------------------------------------------------
  // OPERATION SELECTION
  // ------------------------------------------------------------

  void _onOperationSelected(String operation) {
    if (operation == _selectedOperation) return;

    // Keep the current operation before switching.
    // This prevents losing unsaved changes when switching tabs.
    setState(() {
      _selectedOperation = operation;

      _currentOperation = _getSelectedOperation(operation);
    });
  }

  // ------------------------------------------------------------
  // SAVE
  // ------------------------------------------------------------

  Future<void> _saveOperation(Map<String, dynamic> formData) async {
    final updatedOperation = ApiOperationOption(
      operation: _selectedOperation,
      path: formData['path']?.toString(),
      method: formData['method']?.toString().toUpperCase(),
      enabled: formData['enabled'] == true,
      permission: _nullableString(formData['permission']),
      extra: _currentOperation.extra,
    );

    final updatedApi = _currentApi.updateOperation(updatedOperation);

    if (!mounted) return;

    setState(() {
      _currentApi = updatedApi;
      _currentOperation = updatedOperation;
    });

    // Parent metadata editor owns persistence.
    context.read<MetadataBloc>().add(
      UpdateRootProperty('api', updatedApi.toJson()),
    );
  }

  String? _nullableString(dynamic value) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return null;
    }

    return result;
  }

  // ------------------------------------------------------------
  // FORM DATA
  // ------------------------------------------------------------

  /// Converts API operations to generic form data.
  ///
  /// Useful when the complete API array is edited using an
  /// EntityReactiveForm array field.
  Map<String, dynamic> entityToFormData({
    required List<ApiOperationOption> apiOperations,
  }) {
    return {
      'api': apiOperations.map((operation) {
        return {
          'operation': operation.operation,
          'path': operation.path ?? '',
          'method': operation.effectiveMethod ?? '',
          'enabled': operation.enabled,
          'permission': operation.permission ?? '',
        };
      }).toList(),
    };
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final initialData = _getInitialData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOperationToolbar(),

        const Divider(height: 1),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AppReactiveForm(
              key: ValueKey(
                'api-operation-$_selectedOperation-${jsonEncode(initialData)}',
              ),
              meta: ApiEditor._metadata,
              mode: widget.mode == EntityMode.view
                  ? EntityMode.view
                  : EntityMode.edit,
              initialData: initialData,
              onSubmit: (data) async {
                await _saveOperation(data);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // TOOLBAR
  // ------------------------------------------------------------

  Widget _buildOperationToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownMenu<String>(
              key: ValueKey(_selectedOperation),
              expandedInsets: EdgeInsets.zero,
              initialSelection: _selectedOperation,
              label: const Text('Select API operation'),
              onSelected: (String? value) {
                if (value != null) {
                  _onOperationSelected(value);
                }
              },
              dropdownMenuEntries: _operationOptions.map((option) {
                return DropdownMenuEntry<String>(
                  value: option.operation!,
                  label: _operationLabel(option),
                );
              }).toList(),
            ),
          ),

          const SizedBox(width: 12),

          if (_currentOperation.enabled)
            const Chip(
              avatar: Icon(Icons.check_circle_outline, size: 16),
              label: Text('Enabled'),
            )
          else
            const Chip(
              avatar: Icon(Icons.block_outlined, size: 16),
              label: Text('Disabled'),
            ),
        ],
      ),
    );
  }
}
