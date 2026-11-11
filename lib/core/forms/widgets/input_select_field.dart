import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:ud_sass_app/ui/dashcn/components/select.dart';
import '../entity_meta.dart';
import 'reactive_field_layout.dart';

class AppSelectField extends StatelessWidget {
  const AppSelectField({super.key, required this.field});

  final FieldMeta<dynamic> field;

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<dynamic, dynamic>(
      formControlName: field.name,
      builder: (state) {
        final value = state.value;

        final selectedOption = field.options
            .where((option) => option.value == value)
            .firstOrNull;

        return ReactiveFieldLayout(
          field: field,
          control: state.control,
          child: Select<dynamic>(
            value: selectedOption?.value,
            onChanged: state.control.enabled
                ? (value) {
                    state.didChange(value);
                    state.control.markAsTouched();
                  }
                : null,
            // onChanged: (dynamic? value) => setState(() => _fruit = value),
            placeholder: Text(field.placeholder ?? 'Select ${field.label}'),
            itemBuilder: (BuildContext context, dynamic value) => Text(value),
            items: field.options
                .map(
                  (option) => SelectItem<dynamic>(
                    value: option.value,
                    enabled: !option.disabled,
                    child: Text(option.label),
                  ),
                )
                .toList(),
          ),
          // child: DropdownButtonFormField<dynamic>(
          //   value: selectedOption?.value,
          //   isExpanded: true,
          //   decoration: InputDecoration(
          //     hintText: field.placeholder ?? 'Select ${field.label}',
          //     border: const OutlineInputBorder(),
          //   ),
          //   items: field.options.map((option) {
          //     return DropdownMenuItem<dynamic>(
          //       value: option.value,
          //       enabled: !option.disabled,
          //       child: Text(option.label),
          //     );
          //   }).toList(),
          //   onChanged: state.control.enabled
          //       ? (value) {
          //           state.didChange(value);
          //           state.control.markAsTouched();
          //         }
          //       : null,
          // ),
        );
      },
    );
  }
}
