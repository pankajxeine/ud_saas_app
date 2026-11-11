import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'models/entity_meta.dart';
import 'models/field_meta.dart';
import 'models/entity_grid_layout.dart';
import 'models/entity_form_actions.dart';
import 'entity_form_field_factory.dart';

typedef EntityFormSubmitCallback =
    Future<void> Function(Map<String, dynamic> value);

typedef EntityFormValueChangedCallback =
    void Function(Map<String, dynamic> value);

typedef EntityFormErrorCallback =
    void Function(Object error, StackTrace stackTrace);

/// Metadata-driven reactive form using Wrap for responsive field placement.
///
/// Existing form lifecycle, external FormGroup ownership, callbacks,
/// validation, reset, submit actions, conditional visibility and custom
/// field builders are preserved.
///
/// Layout behaviour:
/// - Mobile/tablet/desktop column counts come from [EntityGridLayout].
/// - Each field's optional [FieldMeta.layout] controls its column span.
/// - Fields flow left-to-right and then top-to-bottom.
/// - Fields keep their natural height; minHeight can be configured per field.
///
/// Wrap does not support true rowSpan or explicit row/column coordinates.
class EntityReactiveForm extends StatefulWidget {
  const EntityReactiveForm({
    super.key,
    required this.meta,
    this.mode = EntityMode.create,
    this.initialData = const {},
    this.form,
    this.layout = EntityGridLayout.standard,
    this.onSubmit,
    this.onChanged,
    this.onSubmitError,
    this.submitLabel = 'Save',
    this.showSubmitButton = true,
    this.showResetButton = false,
    this.resetLabel = 'Reset',
    this.submitBuilder,
    this.fieldBuilder,
    this.spacing = 16,
    this.runValidationOnSubmit = true,
    this.includeDisabledValues = true,
    this.enabled = true,
    this.emptyFieldsBuilder,
  });

  /// Entity/module metadata used to build the form controls and fields.
  final EntityMeta meta;

  final EntityMode mode;

  /// Initial values used when the form is internally created.
  final Map<String, dynamic> initialData;

  /// Optional application/BLoC-managed FormGroup.
  ///
  /// When supplied, this widget does not dispose the FormGroup.
  final FormGroup? form;

  /// Responsive Wrap layout configuration.
  final EntityGridLayout layout;

  final EntityFormSubmitCallback? onSubmit;
  final EntityFormValueChangedCallback? onChanged;
  final EntityFormErrorCallback? onSubmitError;

  final String submitLabel;
  final String resetLabel;
  final bool showSubmitButton;
  final bool showResetButton;
  final bool runValidationOnSubmit;

  /// When true, submit uses rawValue and includes disabled controls.
  /// When false, submit uses value and excludes disabled controls.
  final bool includeDisabledValues;

  /// Enables or disables the complete form.
  final bool enabled;

  /// Vertical gap between the fields section and action section.
  ///
  /// Field-to-field spacing is configured through [layout].
  final double spacing;

  /// Optional custom action area.
  ///
  /// Receives the form, submit callback and reset callback.
  final Widget Function(
    BuildContext context,
    FormGroup form,
    VoidCallback submit,
    VoidCallback reset,
  )?
  submitBuilder;

  /// Optional custom field renderer.
  ///
  /// If omitted, EntityFormFieldFactory is used.
  final Widget Function(
    BuildContext context,
    FieldMeta<dynamic> field,
    FormGroup form,
    EntityMode mode,
  )?
  fieldBuilder;

  /// Optional content shown when no fields are visible.
  final WidgetBuilder? emptyFieldsBuilder;

  @override
  State<EntityReactiveForm> createState() => _EntityReactiveFormState();
}

class _EntityReactiveFormState extends State<EntityReactiveForm> {
  late FormGroup _form;

  bool _ownsForm = false;
  bool _isSubmitting = false;

  /// reactive_forms currently exposes a non-null Map<String, Object?>
  /// valueChanges stream for this FormGroup.
  StreamSubscription<Map<String, Object?>?>? _valueSubscription;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _attachFormListeners();
  }

  @override
  void didUpdateWidget(covariant EntityReactiveForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    final externalFormChanged = oldWidget.form != widget.form;
    final metaChanged = oldWidget.meta != widget.meta;
    final modeChanged = oldWidget.mode != widget.mode;

    // A changed FormGroup means the old listener and any internally-owned
    // form must be released before attaching to the new instance.
    if (externalFormChanged) {
      _disposeOwnedForm();
      _cancelListeners();
      _initializeForm();
      _attachFormListeners();
      return;
    }

    // Recreate only internally-owned forms when their schema or mode changes.
    // An externally supplied form remains owned by the caller/BLoC.
    if (_ownsForm && (metaChanged || modeChanged)) {
      _disposeOwnedForm();
      _cancelListeners();
      _initializeForm();
      _attachFormListeners();
      return;
    }

    if (!_mapEquals(oldWidget.initialData, widget.initialData)) {
      _syncInitialData();
    }

    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        _form.markAsEnabled();
      } else {
        _form.markAsDisabled();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // FORM INITIALIZATION AND OWNERSHIP
  // ---------------------------------------------------------------------------

  void _initializeForm() {
    final externalForm = widget.form;

    if (externalForm != null) {
      _form = externalForm;
      _ownsForm = false;
    } else {
      _form = widget.meta.toFormGroup(
        mode: widget.mode,
        initialData: widget.initialData,
      );
      _ownsForm = true;
    }

    if (!widget.enabled) {
      _form.markAsDisabled();
    }
  }

  void _disposeOwnedForm() {
    if (_ownsForm) {
      _form.dispose();
      _ownsForm = false;
    }
  }

  // ---------------------------------------------------------------------------
  // FORM VALUE LISTENER
  // ---------------------------------------------------------------------------

  void _attachFormListeners() {
    _valueSubscription?.cancel();

    _valueSubscription = _form.valueChanges.listen((_) {
      _handleFormValueChanged();
    });
  }

  void _cancelListeners() {
    _valueSubscription?.cancel();
    _valueSubscription = null;
  }

  void _handleFormValueChanged() {
    if (!mounted) return;

    // Rebuild the form so field.isVisible(form) is evaluated again.
    // This supports metadata conditions that depend on form values.
    setState(() {});

    widget.onChanged?.call(Map<String, dynamic>.from(_form.rawValue));
  }

  // ---------------------------------------------------------------------------
  // INITIAL DATA SYNCHRONIZATION
  // ---------------------------------------------------------------------------

  void _syncInitialData() {
    final patchValue = <String, dynamic>{};

    for (final field in widget.meta.fields) {
      if (!_form.contains(field.name)) continue;

      if (widget.initialData.containsKey(field.name)) {
        patchValue[field.name] = widget.initialData[field.name];
      }
    }

    if (patchValue.isEmpty) return;

    _form.patchValue(patchValue, updateParent: true, emitEvent: false);

    _form.markAsPristine();
    _form.markAsUntouched();

    if (mounted) {
      // No valueChanges event is emitted because emitEvent is false.
      // Rebuild explicitly so conditional visibility is refreshed.
      setState(() {});
    }
  }

  // ---------------------------------------------------------------------------
  // RESET
  // ---------------------------------------------------------------------------

  void _reset() {
    final resetValues = <String, dynamic>{};

    for (final field in widget.meta.fields) {
      if (!_form.contains(field.name)) continue;

      resetValues[field.name] = widget.initialData.containsKey(field.name)
          ? widget.initialData[field.name]
          : field.initialValue;
    }

    _form.reset(value: resetValues, updateParent: true, emitEvent: true);

    _form.markAsPristine();
    _form.markAsUntouched();
  }

  // ---------------------------------------------------------------------------
  // SUBMIT
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    if (_isSubmitting || widget.onSubmit == null) return;

    if (widget.runValidationOnSubmit) {
      _form.markAllAsTouched();
    }

    _form.updateValueAndValidity();

    if (!_form.valid) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final value = widget.includeDisabledValues
          ? Map<String, dynamic>.from(_form.rawValue)
          : Map<String, dynamic>.from(_form.value);

      await widget.onSubmit!(value);
    } catch (error, stackTrace) {
      widget.onSubmitError?.call(error, stackTrace);
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _cancelListeners();
    _disposeOwnedForm();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: _form,
      child: ReactiveFormConsumer(
        builder: (BuildContext context, FormGroup form, Widget? child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFields(context, form),
              if (widget.showSubmitButton || widget.showResetButton) ...[
                SizedBox(height: widget.spacing),
                _buildActions(context, form),
              ],
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WRAP-BASED RESPONSIVE FIELD LAYOUT
  // ---------------------------------------------------------------------------

  Widget _buildFields(BuildContext context, FormGroup form) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // A Wrap form needs a finite width to calculate column widths.
        if (!width.isFinite || width <= 0) {
          return const SizedBox.shrink();
        }

        final layout = widget.layout;
        final breakpoint = layout.breakpointFor(width);

        // Protect against invalid configuration and division by zero.
        final columns = layout.columnsFor(width).clamp(1, 100).toInt();

        final visibleFields = _getVisibleFields(form);

        if (visibleFields.isEmpty) {
          return widget.emptyFieldsBuilder?.call(context) ??
              const SizedBox.shrink();
        }

        final horizontalSpacing = layout.horizontalSpacing;

        // Reserve the gaps between columns before calculating each column.
        final availableColumnWidth = (width - horizontalSpacing * (columns - 1))
            .clamp(0.0, double.infinity)
            .toDouble();

        final columnWidth = availableColumnWidth / columns;

        return Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: horizontalSpacing,
          runSpacing: layout.verticalSpacing,
          children: [
            for (final field in visibleFields)
              _buildFieldItem(
                context: context,
                field: field,
                form: form,
                columns: columns,
                breakpoint: breakpoint,
                columnWidth: columnWidth,
                availableWidth: width,
              ),
          ],
        );
      },
    );
  }

  /// Builds a field at its responsive width.
  ///
  /// Example with four columns:
  /// - columnWidth = 200
  /// - horizontalSpacing = 16
  /// - colSpan = 2
  /// - itemWidth = (200 * 2) + 16 = 416
  ///
  /// The extra 16 pixels account for the gap between the two columns.
  Widget _buildFieldItem({
    required BuildContext context,
    required FieldMeta<dynamic> field,
    required FormGroup form,
    required int columns,
    required EntityBreakpoint breakpoint,
    required double columnWidth,
    required double availableWidth,
  }) {
    final fieldLayout = field.layout;

    final columnSpan = widget.layout.resolveColumnSpan(
      fieldLayout: fieldLayout,
      breakpoint: breakpoint,
      columns: columns,
    );

    final itemWidth =
        (columnWidth * columnSpan +
                widget.layout.horizontalSpacing * (columnSpan - 1))
            .clamp(0.0, availableWidth)
            .toDouble();

    final minHeight = widget.layout.resolveMinHeight(fieldLayout);

    return SizedBox(
      key: ValueKey('entity-field-${field.name}'),
      width: itemWidth,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: _buildField(context, field, form),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FIELD VISIBILITY
  // ---------------------------------------------------------------------------

  /// Retains the existing metadata visibility mechanism.
  ///
  /// field.isVisible(form) should evaluate both static visibility and any
  /// configured visibleWhen conditions. The form listener above triggers a
  /// rebuild when field values change.
  List<FieldMeta<dynamic>> _getVisibleFields(FormGroup form) {
    return widget.meta.fields
        .where((field) => _form.contains(field.name) && field.isVisible(form))
        .toList(growable: false);
  }

  // ---------------------------------------------------------------------------
  // FIELD RENDERING
  // ---------------------------------------------------------------------------

  /// Custom fieldBuilder takes priority; otherwise use the standard factory.
  Widget _buildField(
    BuildContext context,
    FieldMeta<dynamic> field,
    FormGroup form,
  ) {
    final customBuilder = widget.fieldBuilder;

    if (customBuilder != null) {
      return customBuilder(context, field, form, widget.mode);
    }

    return EntityFormFieldFactory.build(
      context: context,
      field: field,
      form: form,
      mode: widget.mode,
    );
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  Widget _buildActions(BuildContext context, FormGroup form) {
    final customBuilder = widget.submitBuilder;

    if (customBuilder != null) {
      return customBuilder(context, form, _submit, _reset);
    }

    return EntityFormActions(
      isSubmitting: _isSubmitting,
      mode: widget.mode,
      submitLabel: widget.submitLabel,
      resetLabel: widget.resetLabel,
      showSubmitButton: widget.showSubmitButton,
      showResetButton: widget.showResetButton,
      onSubmit: _submit,
      onReset: _reset,
    );
  }

  // ---------------------------------------------------------------------------
  // MAP COMPARISON
  // ---------------------------------------------------------------------------

  bool _mapEquals(Map<String, dynamic> first, Map<String, dynamic> second) {
    if (identical(first, second)) return true;
    if (first.length != second.length) return false;

    for (final entry in first.entries) {
      if (second[entry.key] != entry.value) return false;
    }

    return true;
  }
}
