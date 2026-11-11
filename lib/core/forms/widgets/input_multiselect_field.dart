import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../entity_meta.dart';
import 'reactive_field_layout.dart';

class AppMultiSelectField extends StatelessWidget {
  const AppMultiSelectField({super.key, required this.field});

  final FieldMeta<dynamic> field;

  @override
  Widget build(BuildContext context) {
    final options = field.options;

    return ReactiveFormField<List<String>, List<String>>(
      formControlName: field.name,
      builder: (state) {
        final selected = List<String>.from(state.value ?? const []);

        return ReactiveFieldLayout(
          field: field,
          control: state.control,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selected.contains(option);

              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: state.control.enabled
                    ? (selectedValue) {
                        final updated = List<String>.from(selected);

                        if (selectedValue) {
                          if (!updated.contains(option)) {
                            updated.add(option);
                          }
                        } else {
                          updated.remove(option);
                        }

                        state.didChange(updated);
                        state.control.markAsTouched();
                      }
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
