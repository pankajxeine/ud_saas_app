import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../entity_meta.dart';
import 'reactive_field_layout.dart';

class AppDateField extends StatelessWidget {
  const AppDateField({super.key, required this.field});

  final FieldMeta<dynamic> field;

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<String, String>(
      formControlName: field.name,
      builder: (state) {
        final value = state.value;

        return ReactiveFieldLayout(
          field: field,
          control: state.control,
          child: InkWell(
            onTap: state.control.enabled
                ? () async {
                    await _selectDate(context, state);
                  }
                : null,
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: field.placeholder ?? 'Select date',
                border: const OutlineInputBorder(),
              ),
              child: Text(
                value?.isNotEmpty == true
                    ? value!
                    : field.placeholder ?? 'Select date',
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    ReactiveFormFieldState<String, String> state,
  ) async {
    final current = DateTime.tryParse(state.value ?? '');

    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(field.features['firstYear'] as int? ?? 1900),
      lastDate: DateTime(field.features['lastYear'] as int? ?? now.year + 100),
    );

    if (selected == null) {
      return;
    }

    final formatted =
        '${selected.year.toString().padLeft(4, '0')}-'
        '${selected.month.toString().padLeft(2, '0')}-'
        '${selected.day.toString().padLeft(2, '0')}';

    state.didChange(formatted);
    state.control.markAsTouched();
  }
}
