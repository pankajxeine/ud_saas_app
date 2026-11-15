import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';

import '../models/entity_meta.dart';
import '../models/field_meta.dart';
import '../registry/entity_field_widget_registry.dart';

import 'entity_form_renderer.dart';

class EntityFormGroup extends StatelessWidget {
  const EntityFormGroup({
    super.key,
    required this.field,
    required this.form,
    required this.mode,
    required this.registry,
  });

  final FieldMeta<dynamic> field;
  final FormGroup form;
  final EntityMode mode;
  final EntityFieldWidgetRegistry registry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (field.label.isNotEmpty) ...[
            Text(
              field.label,
              style: t.typography.extraBold.copyWith(
                fontWeight: FontWeight.w700,
                color: t.colors.accentForeground,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // IMPORTANT:
          //
          // `form` is the nested FormGroup for this field.
          //
          // ui group:
          //   form = root.control('ui') as FormGroup
          //
          EntityFormRenderer(
            fields: field.fields,
            form: form,
            mode: mode,
            registry: registry,
          ),
        ],
      ),
    );
  }
}
