import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/ui/dashcn/components/checkbox.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';

class FieldPermissionEditor extends StatelessWidget {
  const FieldPermissionEditor({super.key});

  static const permissionKeys = ['read', 'create', 'update'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataBloc, MetadataState>(
      builder: (context, state) {
        final fieldName = state.selectedField;

        if (fieldName == null) {
          return const Center(child: Text('Select a field first.'));
        }

        Map<String, dynamic>? field;

        for (final item in state.metadata?.schemaJson.fields as List? ?? []) {
          if (item is Map && item['name'] == fieldName) {
            field = Map<String, dynamic>.from(item);
            break;
          }
        }

        if (field == null) {
          return const Center(child: Text('Field not found.'));
        }

        final permissions = Map<String, dynamic>.from(
          (field['permissions'] as Map?) ?? {},
        );

        return ListView(
          children: [
            Text(
              'Permissions — ${field['label'] ?? fieldName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure which operations are allowed for this field.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            ...permissionKeys.map((permission) {
              final enabled = permissions[permission] != false;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            permission.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _description(permission),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: enabled
                          ? CheckboxValue.checked
                          : CheckboxValue.unchecked,
                      onChanged: (value) {
                        final updated = Map<String, dynamic>.from(permissions);

                        updated[permission] = value == CheckboxValue.checked;

                        context.read<MetadataBloc>().add(
                          UpdateFieldProperty(
                            fieldName,
                            'permissions',
                            updated,
                          ),
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

  String _description(String permission) {
    switch (permission) {
      case 'read':
        return 'Allow this field to be read or displayed.';
      case 'create':
        return 'Allow this field to be supplied during creation.';
      case 'update':
        return 'Allow this field to be changed during updates.';
      default:
        return '';
    }
  }
}
