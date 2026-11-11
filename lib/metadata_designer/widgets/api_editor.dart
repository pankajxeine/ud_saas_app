import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/ui/dashcn/components/checkbox.dart';
import 'package:ud_sass_app/ui/dashcn/components/input.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';

class ApiEditor extends StatelessWidget {
  const ApiEditor({super.key});

  static const operations = ['list', 'create', 'detail', 'update', 'delete'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataBloc, MetadataState>(
      builder: (context, state) {
        final api = Map<String, dynamic>.from(
          (state.metadata?.schemaJson.api as Map?) ?? {},
        );

        return ListView(
          children: [
            const Text(
              'API configuration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Configure the endpoints and permissions for each operation.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ...operations.map((operation) {
              final config = Map<String, dynamic>.from(
                (api[operation] as Map?) ?? {},
              );

              final enabled = config['enabled'] != false;
              final path = config['path']?.toString() ?? '';
              final permission = config['permission']?.toString() ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            operation.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Checkbox(
                          value: enabled
                              ? CheckboxValue.checked
                              : CheckboxValue.unchecked,
                          label: const Text('Enabled'),
                          onChanged: (value) {
                            _updateOperation(
                              context,
                              api,
                              operation,
                              'enabled',
                              value == CheckboxValue.checked,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _input(
                      label: 'Endpoint path',
                      value: path,
                      hint: '/api/accounts',
                      onChanged: (value) {
                        _updateOperation(
                          context,
                          api,
                          operation,
                          'path',
                          value,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _input(
                      label: 'Permission',
                      value: permission,
                      hint: 'account.read',
                      onChanged: (value) {
                        _updateOperation(
                          context,
                          api,
                          operation,
                          'permission',
                          value,
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _input({
    required String label,
    required String value,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Input(
          initialValue: value,
          placeholder: Text(hint),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _updateOperation(
    BuildContext context,
    Map<String, dynamic> currentApi,
    String operation,
    String property,
    dynamic value,
  ) {
    final updatedApi = Map<String, dynamic>.from(currentApi);
    final operationConfig = Map<String, dynamic>.from(
      (updatedApi[operation] as Map?) ?? {},
    );

    operationConfig[property] = value;
    updatedApi[operation] = operationConfig;

    context.read<MetadataBloc>().add(UpdateRootProperty('api', updatedApi));
  }
}
