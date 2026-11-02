import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:ud_sass_app/core/widgets/reactive_shadcn_form/control_extensions.dart';
import 'package:ud_sass_app/core/widgets/reactive_shadcn_form/entity_meta.dart';
import 'package:ud_sass_app/core/widgets/reactive_shadcn_form/reactive_shadcn_error.dart';
import 'package:ud_sass_app/ui/dashcn/components/input.dart';
import 'package:ud_sass_app/ui/dashcn/primitives.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/gap.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';

class ReactiveShadcnTextField extends StatefulWidget {
  final FieldMeta field;

  const ReactiveShadcnTextField({super.key, required this.field});

  @override
  State<ReactiveShadcnTextField> createState() => _State();
}

class _State extends State<ReactiveShadcnTextField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<String, String>(
      formControlName: widget.field.name,
      builder: (state) {
        final incoming = state.value ?? '';
        if (_ctrl.text != incoming) {
          _ctrl.value = _ctrl.value.copyWith(text: incoming);
        }
        print("features ${widget.field.features}");
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.field.label).medium(),
            const Gap(gapSm),
            Input(
              controller: _ctrl,
              placeholder: Text(widget.field.placeholder ?? ''),
              keyboardType: switch (widget.field.type) {
                EntityFieldType.email => TextInputType.emailAddress,
                EntityFieldType.phone => TextInputType.phone,
                EntityFieldType.number || EntityFieldType.currency =>
                  const TextInputType.numberWithOptions(decimal: true),
                _ => TextInputType.text,
              },
              maxLines: widget.field.type == EntityFieldType.textarea ? 4 : 1,
              maxLength: widget.field.maxLength,
              features: [
                if ((widget.field.features?['showClearButton'] as bool?) ??
                    false)
                  const InputClearFeature(),

                if ((widget.field.features?['showCopyButton'] as bool?) ??
                    false)
                  const InputCopyFeature(),

                if (widget.field.type == EntityFieldType.password)
                  const InputPasswordToggleFeature(),

                ...?widget.field.features?['extraFeatures']
                    as List<InputFeature>?,
              ],
              onChanged: state.didChange,
              onSubmitted: (_) => state.control.markAsTouched(),
              onTapOutside: (_) => state.control.markAsTouched(),
            ),
            ReactiveShadcnError(
              control: state.control,
              message: state.control.errorText,
            ),
          ],
        );
      },
    );
  }
}
