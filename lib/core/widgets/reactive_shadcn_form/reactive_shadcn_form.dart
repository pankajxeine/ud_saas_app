import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:ud_sass_app/core/widgets/reactive_shadcn_form/entity_meta.dart';
import 'package:ud_sass_app/core/widgets/reactive_shadcn_form/reactive_shadcn_input_fields.dart';

class ReactiveShadcnForm extends StatelessWidget {
  final EntityMeta meta;
  final FormGroup form;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;

  const ReactiveShadcnForm({
    super.key,
    required this.meta,
    required this.form,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 4,
    this.spacing = 16,
  });

  int _getColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return mobileColumns;
    if (width < 1024) return tabletColumns;
    return desktopColumns;
  }

  @override
  Widget build(BuildContext context) {
    final columns = _getColumns(context);

    return ReactiveForm(
      formGroup: form,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 4,
        children: meta.fields.map((field) {
          return Padding(
            padding: EdgeInsets.all(spacing / 3),
            child: ReactiveShadcnInputField(field: field),
          );
        }).toList(),
      ),
    );
  }
}
