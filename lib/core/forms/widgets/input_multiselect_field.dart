import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../models/field_meta.dart';
import 'reactive_field_layout.dart';

class AppMultiSelectField extends StatelessWidget {
  const AppMultiSelectField({super.key, required this.field});

  final FieldMeta<dynamic> field;

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<List<String>, List<String>>(
      formControlName: field.name,
      builder: (state) {
        final selected = List<String>.from(state.value ?? const <String>[]);
        return ReactiveFieldLayout(
          field: field,
          control: state.control,
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: field.options.map((option) {
              final value = option.value.toString();
              return FilterChip(
                label: Text(option.label),
                selected: selected.contains(value),
                onSelected: state.control.enabled
                    ? (checked) {
                        final updated = List<String>.from(selected);
                        if (checked) {
                          updated.add(value);
                        } else {
                          updated.remove(value);
                        }
                        state.didChange(updated.toSet().toList());
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
