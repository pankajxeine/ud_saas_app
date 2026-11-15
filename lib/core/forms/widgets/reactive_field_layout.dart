import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:ud_sass_app/ui/dashcn/src/theme/theme.dart';

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
  });

  final FieldMeta<dynamic> field;
  final AbstractControl<dynamic> control;
  final Widget child;

  /// Controls whether the switch/checkbox appears before or after the label.
  final BooleanControlPosition booleanPosition;

  /// Switch or checkbox presentation.
  final BooleanControlStyle booleanStyle;

  /// Whether help text is displayed for boolean fields.
  final bool showBooleanHelpText;

  bool get _isBoolean => field.type == EntityFieldType.boolean;

  @override
  Widget build(BuildContext context) {
    print("field type : $_isBoolean $field.type");
    if (_isBoolean) {
      return _buildBooleanLayout(context);
    }

    return _buildNormalLayout(context);
  }

  // ------------------------------------------------------------
  // Normal field layout
  // ------------------------------------------------------------

  Widget _buildNormalLayout(BuildContext context) {
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

  Widget _buildBooleanLayout(BuildContext context) {
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
    );
  }

  Widget _buildHelpText(BuildContext context) {
    return Text(
      field.helpText!,
      style: Theme.of(context).typography.small.copyWith(
        fontSize: 12,
        color: Theme.of(context).colors.mutedForeground,
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
