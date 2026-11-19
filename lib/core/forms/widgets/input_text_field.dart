import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../models/field_meta.dart';
import 'reactive_field_layout.dart';

class InputTextField extends StatelessWidget {
  const InputTextField({super.key, required this.field});

  final FieldMeta<dynamic> field;

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<String, String>(
      formControlName: field.name,
      builder: (state) => ReactiveFieldLayout(
        field: field,
        control: state.control,
        child: TextFormField(
          initialValue: state.value ?? '',
          enabled: state.control.enabled,
          obscureText: field.type == EntityFieldType.password,
          keyboardType: _keyboardType(),
          maxLines: field.type == EntityFieldType.textarea ? 4 : 1,
          maxLength: field.maxLength,
          decoration: InputDecoration(hintText: field.placeholder),
          onChanged: state.didChange,
          onTapOutside: (_) => state.control.markAsTouched(),
          onFieldSubmitted: (_) => state.control.markAsTouched(),
        ),
      ),
    );
  }

  TextInputType _keyboardType() {
    switch (field.type) {
      case EntityFieldType.email:
        return TextInputType.emailAddress;
      case EntityFieldType.phone:
        return TextInputType.phone;
      case EntityFieldType.number:
      case EntityFieldType.currency:
        return const TextInputType.numberWithOptions(decimal: true);
      case EntityFieldType.password:
        return TextInputType.visiblePassword;
      default:
        return TextInputType.text;
    }
  }
}
