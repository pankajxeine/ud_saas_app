import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../models/field_meta.dart';
import 'reactive_field_layout.dart';

class AppDateRangeField extends StatelessWidget {
  const AppDateRangeField({super.key, required this.field});

  final FieldMeta<dynamic> field;

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<Map<String, String>, Map<String, String>>(
      formControlName: field.name,
      builder: (state) {
        final value = state.value ?? const <String, String>{};

        return ReactiveFieldLayout(
          field: field,
          control: state.control,
          child: InkWell(
            onTap: state.control.enabled
                ? () async {
                    await _selectRange(context, state);
                  }
                : null,
            child: InputDecorator(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              child: Text(_displayValue(value)),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectRange(
    BuildContext context,
    ReactiveFormFieldState<Map<String, String>, Map<String, String>> state,
  ) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 36500)),
    );

    if (range == null) {
      return;
    }

    String format(DateTime date) {
      return '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }

    state.didChange({'start': format(range.start), 'end': format(range.end)});

    state.control.markAsTouched();
  }

  String _displayValue(Map<String, String> value) {
    final start = value['start'];
    final end = value['end'];

    if (start == null || end == null) {
      return field.placeholder ?? 'Select date range';
    }

    return '$start → $end';
  }
}
