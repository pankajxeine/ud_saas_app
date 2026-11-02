import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:ud_sass_app/core/widgets/reactive_shadcn_form/entity_meta.dart';
import 'package:ud_sass_app/core/widgets/reactive_shadcn_form/form_widgets/reactive_shadcn_text_field.dart';

class ReactiveShadcnInputField extends StatelessWidget {
  final FieldMeta field;

  const ReactiveShadcnInputField({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case EntityFieldType.text:
      case EntityFieldType.password:
      case EntityFieldType.email:
      case EntityFieldType.phone:
      case EntityFieldType.number:
      case EntityFieldType.currency:
      case EntityFieldType.date:
      case EntityFieldType.dateRange:
      case EntityFieldType.textarea:
        return ReactiveShadcnTextField(field: field);

      case EntityFieldType.boolean:
        return ReactiveFormField<bool, bool>(
          formControlName: field.name,
          builder: (state) => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(field.label),
            value: state.value ?? false,
            onChanged: state.control.enabled ? state.didChange : null,
          ),
        );

      case EntityFieldType.select:
        return ReactiveFormField<String, String>(
          formControlName: field.name,
          builder: (state) => DropdownButtonFormField<String>(
            initialValue: state.value,
            decoration: InputDecoration(labelText: field.label),
            items: field.options
                ?.map(
                  (option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  ),
                )
                .toList(),
            onChanged: state.control.enabled ? state.didChange : null,
          ),
        );

      default:
        return Text('Unsupported field type: ${field.type}');
    }
  }
}
