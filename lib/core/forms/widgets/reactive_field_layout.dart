// import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:ud_sass_app/ui/dashcn/src/theme/theme.dart';

import '../models/field_meta.dart';
import '../form_error.dart';

class ReactiveFieldLayout extends StatelessWidget {
  const ReactiveFieldLayout({
    super.key,
    required this.field,
    required this.control,
    required this.child,
  });

  final FieldMeta<dynamic> field;
  final AbstractControl<dynamic> control;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                field.label,
                style: Theme.of(context).typography.small.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).colors.mutedForeground,
                ),
              ),
            ),
            if (field.isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Color.fromRGBO(180, 35, 24, 1)),
              ),
          ],
        ),
        if (field.helpText != null) ...[
          const SizedBox(height: 4),
          Text(field.helpText!, style: Theme.of(context).typography.small),
        ],
        const SizedBox(height: 8),
        child,
        FormError(control: control),
      ],
    );
  }
}
