import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:ud_sass_app/ui/dashcn/components/checkbox.dart';
import 'package:ud_sass_app/ui/dashcn/components/switch.dart';

import '../entity_meta.dart';
import 'reactive_field_layout.dart';

class AppBooleanField extends StatelessWidget {
  const AppBooleanField({super.key, required this.field});

  final FieldMeta<dynamic> field;

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<bool, bool>(
      formControlName: field.name,
      builder: (state) {
        final value = state.value;
        final checkboxValue = value != null
            ? CheckboxValue.checked
            : CheckboxValue.unchecked;

        final displayType =
            field.features['displayType'] as String? ?? 'switch';

        return ReactiveFieldLayout(
          field: field,
          control: state.control,
          child: displayType == 'checkbox'
              ? Checkbox(
                  value: checkboxValue,
                  padding: EdgeInsets.zero,
                  enabled: state.control.enabled,
                  label: Text(field.features['text'] as String? ?? field.label),
                  onChanged: state.control.enabled
                      ? (value) {
                          state.didChange(
                            value == CheckboxValue.checked ? true : false,
                          );
                          state.control.markAsTouched();
                        }
                      : null,
                )
              : Switch(
                  value: value ?? false,
                  enabled: state.control.enabled,
                  label: Text(field.features['text'] as String? ?? field.label),
                  onChanged: state.control.enabled
                      ? (value) {
                          state.didChange(value);
                          state.control.markAsTouched();
                        }
                      : null,
                ),
        );
      },
    );
  }
}
