import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../models/field_meta.dart';
import '../form_error.dart';

/// Position of the boolean control relative to its label.
enum BooleanControlPosition { leading, trailing }

/// Boolean control presentation.
enum BooleanControlStyle { switchControl, checkbox }

class ReactiveFieldLayout extends StatelessWidget {
  const ReactiveFieldLayout({
    super.key,
    required this.field,
    required this.control,
    required this.child,
    this.booleanPosition = BooleanControlPosition.trailing,
    this.booleanStyle = BooleanControlStyle.switchControl,
    this.showBooleanHelpText = true,
    this.isRowLayout = false,
  });

  final FieldMeta<dynamic> field;
  final AbstractControl<dynamic> control;
  final Widget child;

  /// Controls whether the switch/checkbox appears before or after the label.
  final BooleanControlPosition booleanPosition;

  /// Switch or checkbox presentation.
  final BooleanControlStyle booleanStyle;

  final bool isRowLayout;

  /// Whether help text is displayed for boolean fields.
  final bool showBooleanHelpText;

  @override
  Widget build(BuildContext context) {
    print("field type : $isRowLayout $field.type");
    if (isRowLayout) {
      return _buildRowLayout(context);
    }

    return _buildColumnlLayout(context);
  }

  // ------------------------------------------------------------
  // Normal field layout
  // ------------------------------------------------------------

  Widget _buildColumnlLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(context),

        if (field.helpText != null) ...[
          const SizedBox(height: 4),
          _buildHelpText(context),
        ],

        const SizedBox(height: 8),

        child,

        FormError(control: control),
      ],
    );
  }

  // ------------------------------------------------------------
  // Boolean field layout
  // ------------------------------------------------------------

  Widget _buildRowLayout(BuildContext context) {
    final controlWidget = _buildBooleanControl();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (booleanPosition == BooleanControlPosition.leading)
              controlWidget,

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLabel(context),
                  if (showBooleanHelpText && field.helpText != null) ...[
                    const SizedBox(height: 2),
                    _buildHelpText(context),
                  ],
                ],
              ),
            ),

            if (booleanPosition == BooleanControlPosition.trailing)
              controlWidget,
          ],
        ),

        FormError(control: control),
      ],
    );
  }

  // ------------------------------------------------------------
  // Label
  // ------------------------------------------------------------

  Widget _buildLabel(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            field.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (field.isRequired)
          const Text(
            ' *',
            style: TextStyle(color: Color.fromRGBO(180, 35, 24, 1)),
          ),
      ],
    );
  }

  Widget _buildHelpText(BuildContext context) {
    return Text(
      field.helpText!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  // ------------------------------------------------------------
  // Boolean control
  // ------------------------------------------------------------

  Widget _buildBooleanControl() {
    // The actual reactive switch/checkbox is provided by the field
    // factory through `child`.
    //
    // This keeps ReactiveFieldLayout independent of Dashcn's
    // specific Switch and Checkbox APIs.
    return child;
  }
}
