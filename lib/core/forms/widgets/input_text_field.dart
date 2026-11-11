import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:ud_sass_app/ui/dashcn/components/input.dart';
import 'package:ud_sass_app/ui/dashcn/primitives.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/gap.dart';

import '../models/field_meta.dart';

import 'reactive_field_layout.dart';

class InputTextField extends StatefulWidget {
  const InputTextField({super.key, required this.field});

  final FieldMeta<dynamic> field;

  @override
  State<InputTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<InputTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncController(String value) {
    if (_controller.text == value) {
      return;
    }

    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<String, String>(
      formControlName: widget.field.name,
      builder: (fieldState) {
        final value = fieldState.value ?? '';

        _syncController(value);

        final isDisabled = fieldState.control.disabled;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReactiveFieldLayout(
              field: widget.field,
              control: fieldState.control,
              child: Input(
                controller: _controller,

                placeholder: widget.field.placeholder == null
                    ? null
                    : Text(widget.field.placeholder!),

                keyboardType: _keyboardType(),

                maxLines: widget.field.type == EntityFieldType.textarea
                    ? _textareaMaxLines()
                    : 1,

                maxLength: widget.field.maxLength,

                enabled: !isDisabled,

                features: _buildFeatures(),
                onChanged: isDisabled ? null : fieldState.didChange,

                onSubmitted: (_) {
                  fieldState.control.markAsTouched();
                },

                onTapOutside: (_) {
                  fieldState.control.markAsTouched();
                },
              ),
            ),

            //_buildLabel(context),
            if (widget.field.helpText != null) ...[
              const Gap(4),
              Text(widget.field.helpText!).muted(),
            ],
          ],
        );
      },
    );
  }

  TextInputType _keyboardType() {
    switch (widget.field.type) {
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

  int _textareaMaxLines() {
    final value = widget.field.features['maxLines'];

    if (value is int && value > 1) {
      return value;
    }

    return 4;
  }

  List<InputFeature> _buildFeatures() {
    final features = <InputFeature>[];

    if (widget.field.features['showClearButton'] == true) {
      features.add(const InputClearFeature());
    }

    if (widget.field.features['showCopyButton'] == true) {
      features.add(const InputCopyFeature());
    }

    if (widget.field.type == EntityFieldType.password) {
      features.add(const InputPasswordToggleFeature());
    }

    final extraFeatures = widget.field.features['extraFeatures'];

    if (extraFeatures is Iterable<InputFeature>) {
      features.addAll(extraFeatures);
    }

    return features;
  }
}
