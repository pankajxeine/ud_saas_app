import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../models/field_meta.dart';
import 'reactive_field_layout.dart';

class AppSelectField extends StatelessWidget {
  const AppSelectField({super.key, required this.field});

  final FieldMeta<dynamic> field;

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<dynamic, dynamic>(
      formControlName: field.name,
      builder: (state) => ReactiveFieldLayout(
        field: field,
        control: state.control,
        child: DropdownButtonFormField<dynamic>(
          value: state.value,
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'Select ${field.label}',
          ),
          onChanged: state.control.enabled
              ? (value) {
                  state.didChange(value);
                  state.control.markAsTouched();
                }
              : null,
          items: field.options
              .map((option) => DropdownMenuItem<dynamic>(
                    value: option.value,
                    enabled: !option.disabled,
                    child: Text(option.label),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
