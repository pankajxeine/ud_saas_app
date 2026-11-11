import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:ud_sass_app/ui/dashcn/components/input.dart';
import 'package:ud_sass_app/ui/dashcn/primitives.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/gap.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';

import '../entity_meta.dart';
import '../form_error.dart';

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
            _buildLabel(context),

            const Gap(gapSm),

            Input(
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

            FormError(control: fieldState.control),

            if (widget.field.helpText != null) ...[
              const Gap(4),
              Text(widget.field.helpText!).muted(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLabel(BuildContext context) {
    final required = widget.field.isRequired;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.field.label).medium(),

        if (required)
          Text(
            ' *',
            style: TextStyle(color: Theme.of(context).colors.destructive),
          ),
      ],
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
