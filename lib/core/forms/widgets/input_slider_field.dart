import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../entity_meta.dart';
import 'reactive_field_layout.dart';

class AppSliderField extends StatelessWidget {
  const AppSliderField({super.key, required this.field});

  final FieldMeta<dynamic> field;

  @override
  Widget build(BuildContext context) {
    final min = (field.features['min'] as num?)?.toDouble() ?? 0;

    final max = (field.features['max'] as num?)?.toDouble() ?? 100;

    final divisions = field.features['divisions'] as int?;

    return ReactiveFormField<double, double>(
      formControlName: field.name,
      builder: (state) {
        var value = state.value ?? min;

        value = value.clamp(min, max);

        return ReactiveFieldLayout(
          field: field,
          control: state.control,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value.toStringAsFixed(
                        field.features['decimalPlaces'] as int? ?? 0,
                      ),
                    ),
                  ),
                ],
              ),

              Slider(
                min: min,
                max: max,
                divisions: divisions,
                value: value,
                onChanged: state.control.enabled
                    ? (newValue) {
                        state.didChange(newValue);
                      }
                    : null,
                onChangeEnd: (_) {
                  state.control.markAsTouched();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
