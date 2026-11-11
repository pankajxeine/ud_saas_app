import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/ui/dashcn/components/checkbox.dart';
import 'package:ud_sass_app/ui/dashcn/components/input.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/select/select.dart';

import '../bloc/metadata_bloc.dart';
import '../bloc/metadata_event.dart';
import '../bloc/metadata_state.dart';

class FieldPropertiesEditor extends StatelessWidget {
  const FieldPropertiesEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataBloc, MetadataState>(
      builder: (context, state) {
        final fieldName = state.selectedField;

        if (fieldName == null) {
          return const Center(
            child: Text('Select a field to edit its properties.'),
          );
        }

        final fields = (state.metadata?.schemaJson.fields as List? ?? [])
            .whereType<Map>()
            .toList();

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

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                field['label']?.toString() ?? fieldName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(fieldName, style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 20),

              _textProperty(
                context,
                fieldName,
                'name',
                'Field key',
                field['name'],
              ),
              _textProperty(
                context,
                fieldName,
                'label',
                'Label',
                field['label'],
              ),
              _textProperty(
                context,
                fieldName,
                'description',
                'Description',
                field['description'],
              ),

              _selectProperty(
                context,
                fieldName,
                'type',
                'Data type',
                field['type']?.toString() ?? 'string',
                const [
                  'string',
                  'integer',
                  'number',
                  'boolean',
                  'date',
                  'datetime',
                  'object',
                  'array',
                ],
              ),

              _selectProperty(
                context,
                fieldName,
                'widget',
                'UI widget',
                field['widget']?.toString() ?? 'text',
                const [
                  'text',
                  'textarea',
                  'number',
                  'email',
                  'url',
                  'date',
                  'datetime',
                  'select',
                  'checkbox',
                  'switch',
                  'lookup',
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                'Visibility',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              _booleanProperty(
                context,
                fieldName,
                field,
                'showInTable',
                'Show in table',
              ),
              _booleanProperty(
                context,
                fieldName,
                field,
                'showInDetail',
                'Show in detail',
              ),
              _booleanProperty(
                context,
                fieldName,
                field,
                'showInCreate',
                'Show in create',
              ),
              _booleanProperty(
                context,
                fieldName,
                field,
                'showInUpdate',
                'Show in update',
              ),

              const SizedBox(height: 20),
              const Text(
                'Field behaviour',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              _booleanProperty(
                context,
                fieldName,
                field,
                'requiredOnCreate',
                'Required on create',
              ),
              _booleanProperty(
                context,
                fieldName,
                field,
                'requiredOnUpdate',
                'Required on update',
              ),
              _booleanProperty(
                context,
                fieldName,
                field,
                'nullable',
                'Nullable',
              ),
              _booleanProperty(
                context,
                fieldName,
                field,
                'readOnly',
                'Read only',
              ),
              _booleanProperty(
                context,
                fieldName,
                field,
                'writeOnly',
                'Write only',
              ),
              _booleanProperty(
                context,
                fieldName,
                field,
                'deprecated',
                'Deprecated',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _textProperty(
    BuildContext context,
    String fieldName,
    String property,
    String label,
    dynamic value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          Input(
            initialValue: value?.toString() ?? '',
            onChanged: (text) {
              context.read<MetadataBloc>().add(
                UpdateFieldProperty(fieldName, property, text),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _selectProperty(
    BuildContext context,
    String fieldName,
    String property,
    String label,
    String value,
    List<String> options,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          Select<String>(
            value: options.contains(value) ? value : options.first,
            itemBuilder: (BuildContext context, String value) => Text(value),
            items: options
                .map((option) => SelectItem(value: option, child: Text(option)))
                .toList(),
            onChanged: (nextValue) {
              if (nextValue == null) return;

              context.read<MetadataBloc>().add(
                UpdateFieldProperty(fieldName, property, nextValue),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _booleanProperty(
    BuildContext context,
    String fieldName,
    Map<String, dynamic> field,
    String property,
    String label,
  ) {
    return Checkbox(
      value: field[property] == true
          ? CheckboxValue.checked
          : CheckboxValue.unchecked,
      onChanged: (checked) {
        context.read<MetadataBloc>().add(
          UpdateFieldProperty(fieldName, property, checked),
        );
      },
      label: Text(label),
    );
  }
}

// Widget _selectProperty(
//   BuildContext context,
//   String fieldName,
//   String property,
//   String label,
//   String value,
//   List<String> options,
// ) {
//   return Padding(
//     padding: const EdgeInsets.only(bottom: 14),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label),
//         const SizedBox(height: 6),
//         Input(
//           initialValue: value,
//           hintText: 'Options: ${options.join(', ')}',
//           onSubmitted: (nextValue) {
//             if (options.contains(nextValue)) {
//               context.read<MetadataBloc>().add(
//                 UpdateFieldProperty(fieldName, property, nextValue),
//               );
//             }
//           },
//         ),
//       ],
//     ),
//   );
// }

// Widget _booleanProperty(
//   BuildContext context,
//   String fieldName,
//   Map<String, dynamic> field,
//   String property,
//   String label,
// ) {
//   final enabled = field[property] == true;

//   return GestureDetector(
//     behavior: HitTestBehavior.opaque,
//     onTap: () {
//       context.read<MetadataBloc>().add(
//         UpdateFieldProperty(fieldName, property, !enabled),
//       );
//     },
//     child: Padding(
//       padding: const EdgeInsets.symmetric(vertical: 7),
//       child: Row(
//         children: [
//           Checkbox(
//             value: enabled ? CheckboxValue.checked : CheckboxValue.unchecked,
//             onChanged: (value) {
//               context.read<MetadataBloc>().add(
//                 UpdateFieldProperty(
//                   fieldName,
//                   property,
//                   value == CheckboxValue.checked,
//                 ),
//               );
//             },
//           ),
//           const SizedBox(width: 8),
//           Text(label),
//         ],
//       ),
//     ),
//   );
// }
