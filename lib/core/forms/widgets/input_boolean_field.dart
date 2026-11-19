import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../models/field_meta.dart';
import 'reactive_field_layout.dart';

class AppBooleanField extends StatelessWidget {
  const AppBooleanField({super.key, required this.field});

  final FieldMeta<dynamic> field;

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<bool, bool>(
      formControlName: field.name,
      builder: (state) {
        final label = field.features['text'] as String? ?? field.label;
        final isCheckbox = field.features['displayType'] == 'checkbox';
        return ReactiveFieldLayout(
          field: field,
          control: state.control,
          isRowLayout: true,
          child: isCheckbox
              ? CheckboxListTile(
                  value: state.value ?? false,
                  title: Text(label),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: state.control.enabled
                      ? (value) => state.didChange(value ?? false)
                      : null,
                )
              : Switch(
                  value: state.value ?? false,
                  onChanged: state.control.enabled ? state.didChange : null,
                ),
        );
      },
    );
  }
}
