import 'package:flutter/material.dart';
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
        return ReactiveShadcnTextField(field: field);

      // case EntityFieldType.number:
      //   return ReactiveTextField<int>(
      //     formControlName: field.name,
      //     decoration: InputDecoration(labelText: field.label),
      //     keyboardType: TextInputType.number,
      //   );

      // case EntityFieldType.boolean:
      //   return Row(
      //     children: [
      //       ReactiveCheckbox(formControlName: field.name),
      //       const SizedBox(width: 8),
      //       Text(field.label),
      //     ],
      //   );

      // case EntityFieldType.date:
      //   return ReactiveDatePicker(
      //     formControlName: field.name,
      //     firstDate: DateTime(2000),
      //     lastDate: DateTime(2100),
      //     decoration: InputDecoration(labelText: field.label),
      //   );

      // case EntityFieldType.select:
      //   return ReactiveDropdownField<String>(
      //     formControlName: field.name,
      //     decoration: InputDecoration(labelText: field.label),
      //     items: field.options!
      //         .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
      //         .toList(),
      //   );

      // case EntityFieldType.slider:
      //   return ReactiveSlider(
      //     formControlName: field.name,
      //     min: 0,
      //     max: 100,
      //     divisions: 10,
      //     labelBuilder: (value) => value.toString(),
      //   );

      default:
        return Text('Unsupported field type: ${field.type}');
    }
  }
}
