import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'entity_meta.dart';
import 'entity_form_actions.dart';
import 'entity_form_field_factory.dart';

typedef EntityFormSubmitCallback =
    Future<void> Function(Map<String, dynamic> value);

typedef EntityFormValueChangedCallback =
    void Function(Map<String, dynamic> value);

class EntityReactiveForm extends StatefulWidget {
  const EntityReactiveForm({
    super.key,
    required this.meta,
    this.mode = EntityMode.create,
    this.initialData = const {},
    this.form,
    this.onSubmit,
    this.onChanged,
    this.submitLabel = 'Save',
    this.showSubmitButton = true,
    this.showResetButton = false,
    this.resetLabel = 'Reset',
    this.submitBuilder,
    this.fieldBuilder,
    this.spacing = 16,
    this.runValidationOnSubmit = true,
    this.includeDisabledValues = true,
  });

  /// Entity schema.
  final EntityMeta meta;

  /// Form mode.
  final EntityMode mode;

  /// API/entity values for edit/view mode.
  final Map<String, dynamic> initialData;

  /// Optional externally managed form.
  ///
  /// If null, EntityReactiveForm creates and owns the FormGroup.
  final FormGroup? form;

  /// Called after validation succeeds.
  final EntityFormSubmitCallback? onSubmit;

  /// Called when form value changes.
  final EntityFormValueChangedCallback? onChanged;

  final String submitLabel;
  final String resetLabel;

  final bool showSubmitButton;
  final bool showResetButton;

  final double spacing;

  final bool runValidationOnSubmit;

  /// Important for update forms containing disabled/read-only fields.
  final bool includeDisabledValues;

  /// Optional custom submit area.
  final Widget Function(
    BuildContext context,
    FormGroup form,
    VoidCallback submit,
    VoidCallback reset,
  )?
  submitBuilder;

  /// Optional custom field renderer.
  final Widget Function(
    BuildContext context,
    FieldMeta<dynamic> field,
    FormGroup form,
    EntityMode mode,
  )?
  fieldBuilder;

  @override
  State<EntityReactiveForm> createState() => _EntityReactiveFormState();
}

class _EntityReactiveFormState extends State<EntityReactiveForm> {
  late FormGroup _form;

  bool _ownsForm = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void didUpdateWidget(covariant EntityReactiveForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    final formChanged = oldWidget.form != widget.form;
    final metaChanged = oldWidget.meta != widget.meta;
    final modeChanged = oldWidget.mode != widget.mode;

    if (formChanged || metaChanged || modeChanged) {
      if (_ownsForm) {
        _form.dispose();
      }

      _initializeForm();
    }
  }

  void _initializeForm() {
    if (widget.form != null) {
      _form = widget.form!;
      _ownsForm = false;
      return;
    }

    _form = widget.meta.toFormGroup(
      mode: widget.mode,
      initialData: widget.initialData,
    );

    _ownsForm = true;
  }

  @override
  void dispose() {
    if (_ownsForm) {
      _form.dispose();
    }

    super.dispose();
  }

  void _reset() {
    for (final field in widget.meta.fields) {
      if (!_form.contains(field.name)) {
        continue;
      }

      final control = _form.control(field.name);

      final value = widget.initialData.containsKey(field.name)
          ? widget.initialData[field.name]
          : field.initialValue;

      control.reset(value: value);
    }

    _form.markAsPristine();
    _form.markAsUntouched();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    if (widget.runValidationOnSubmit) {
      _form.markAllAsTouched();
    }

    _form.updateValueAndValidity();

    if (!_form.valid) {
      return;
    }

    if (widget.onSubmit == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final value = widget.includeDisabledValues
          ? Map<String, dynamic>.from(_form.rawValue)
          : Map<String, dynamic>.from(_form.value);

      await widget.onSubmit!(value);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

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

  Widget _buildFields(BuildContext context, FormGroup form) {
    final visibleFields = widget.meta.fields
        .where((field) => field.isVisible(form))
        .toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleFields.length,
      itemBuilder: (context, index) {
        final field = visibleFields[index];

        if (widget.fieldBuilder != null) {
          return widget.fieldBuilder!(context, field, form, widget.mode);
        }

        return EntityFormFieldFactory.build(
          context: context,
          field: field,
          form: form,
          mode: widget.mode,
        );
      },
      separatorBuilder: (_, __) => SizedBox(height: widget.spacing),
    );
  }

  Widget _buildActions(BuildContext context, FormGroup form) {
    if (widget.submitBuilder != null) {
      return widget.submitBuilder!(context, form, _submit, _reset);
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
}
