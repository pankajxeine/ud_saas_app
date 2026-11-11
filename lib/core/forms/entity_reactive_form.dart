import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'entity_meta.dart';
import 'entity_form_grid.dart';

typedef EntityFieldBuilder =
    Widget Function(
      BuildContext context,
      FieldMeta<dynamic> field,
      FormGroup form,
      EntityMode mode,
    );

class EntityReactiveForm extends StatefulWidget {
  const EntityReactiveForm({
    super.key,
    required this.meta,
    required this.form,
    required this.fieldBuilder,
    this.mode = EntityMode.create,
    this.columnSpacing = 16,
    this.rowSpacing = 16,
    this.padding = EdgeInsets.zero,
  });

  final EntityMeta meta;
  final FormGroup form;
  final EntityFieldBuilder fieldBuilder;
  final EntityMode mode;

  final double columnSpacing;
  final double rowSpacing;
  final EdgeInsetsGeometry padding;

  @override
  State<EntityReactiveForm> createState() => _EntityReactiveFormState();
}

class _EntityReactiveFormState extends State<EntityReactiveForm> {
  StreamSubscription<dynamic>? _valueSubscription;

  @override
  void initState() {
    super.initState();
    _attachFormListener();
    _syncEnabledStates();
  }

  @override
  void didUpdateWidget(covariant EntityReactiveForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.form != widget.form) {
      _valueSubscription?.cancel();
      _attachFormListener();
    }

    if (oldWidget.form != widget.form ||
        oldWidget.meta != widget.meta ||
        oldWidget.mode != widget.mode) {
      _syncEnabledStates();
    }
  }

  void _attachFormListener() {
    _valueSubscription = widget.form.valueChanges.listen((_) {
      _syncEnabledStates();
    });
  }

  void _syncEnabledStates() {
    for (final field in widget.meta.fields) {
      if (!widget.form.controls.containsKey(field.name)) {
        continue;
      }

      final control = widget.form.control(field.name);

      final shouldEnable =
          widget.mode != EntityMode.view &&
          field.editable &&
          field.isEnabled(widget.form);

      if (shouldEnable && control.disabled) {
        control.markAsEnabled(emitEvent: false);
      } else if (!shouldEnable && control.enabled) {
        control.markAsDisabled(emitEvent: false);
      }
    }
  }

  @override
  void dispose() {
    _valueSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: widget.form,
      child: ReactiveFormConsumer(
        builder: (context, form, child) {
          final visibleFields = widget.meta.fields.where((field) {
            return field.isVisible(form) &&
                form.controls.containsKey(field.name);
          }).toList();

          final gridItems = visibleFields.map((field) {
            return EntityFormGridItem(
              field: field,
              child: widget.fieldBuilder(context, field, form, widget.mode),
            );
          }).toList();

          return Padding(
            padding: widget.padding,
            child: EntityFormGrid(
              items: gridItems,
              columnSpacing: widget.columnSpacing,
              rowSpacing: widget.rowSpacing,
            ),
          );
        },
      ),
    );
  }
}
