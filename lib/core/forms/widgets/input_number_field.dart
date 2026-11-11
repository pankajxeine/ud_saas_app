import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../models/field_meta.dart';
import 'reactive_field_layout.dart';

class AppNumberField extends StatefulWidget {
  const AppNumberField({super.key, required this.field});

  final FieldMeta<dynamic> field;

  @override
  State<AppNumberField> createState() => _AppNumberFieldState();
}

class _AppNumberFieldState extends State<AppNumberField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<String, String>(
      formControlName: widget.field.name,
      builder: (state) {
        final value = state.value ?? '';

        if (_controller.text != value) {
          _controller.value = TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          );
        }

        final decimalPlaces =
            widget.field.features['decimalPlaces'] as int? ?? 2;

        final prefix = widget.field.type == EntityFieldType.currency
            ? widget.field.features['currencySymbol'] as String? ?? '₹'
            : null;

        return ReactiveFieldLayout(
          field: widget.field,
          control: state.control,
          child: TextField(
            controller: _controller,
            enabled: state.control.enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp('^\\d*\\.?\\d{0,$decimalPlaces}'),
              ),
            ],
            decoration: InputDecoration(
              hintText: widget.field.placeholder,
              prefixText: prefix,
              border: const OutlineInputBorder(),
            ),
            onChanged: state.didChange,
            onSubmitted: (_) => state.control.markAsTouched(),
            onTapOutside: (_) => state.control.markAsTouched(),
          ),
        );
      },
    );
  }
}
