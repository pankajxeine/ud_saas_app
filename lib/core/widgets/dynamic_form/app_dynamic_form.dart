import 'dart:async';

import 'package:flutter/material.dart' hide Form, FormField, TextField;
import 'package:ud_sass_app/ui/shadcn/components/control/button/button.dart';
import 'package:ud_sass_app/ui/shadcn/components/form/form/form.dart';
import 'package:ud_sass_app/ui/shadcn/components/form/text_field/text_field.dart';

enum AppDynamicFieldType {
  text,
  email,
  password,
  number,
  multiline,
  custom,
}

typedef AppDynamicSubmit = FutureOr<void> Function(
  Map<String, dynamic> values,
);

typedef AppDynamicFieldBuilder = Widget Function(
  BuildContext context,
  AppDynamicField field,
  FormKey<dynamic> formKey,
);

class AppDynamicFormConfig {
  const AppDynamicFormConfig({
    this.columns = 1,
    this.spacing = 18,
    this.runSpacing = 18,
    this.padding = EdgeInsets.zero,
    this.submitLabel = 'Submit',
    this.showSubmitButton = true,
    this.submitAlignment = MainAxisAlignment.end,
    this.validateOnChange = true,
    this.showErrors = const {
      FormValidationMode.changed,
      FormValidationMode.submitted,
    },
    this.submitBuilder,
    this.errorBuilder,
  })  : assert(columns > 0),
        assert(spacing >= 0),
        assert(runSpacing >= 0);

  final int columns;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry padding;
  final String submitLabel;
  final bool showSubmitButton;
  final MainAxisAlignment submitAlignment;
  final bool validateOnChange;
  final Set<FormValidationMode> showErrors;
  final Widget Function(
      BuildContext context, bool loading, VoidCallback submit)? submitBuilder;
  final Widget Function(BuildContext context, String message)? errorBuilder;
}

class AppDynamicField {
  const AppDynamicField({
    required this.name,
    required this.label,
    this.type = AppDynamicFieldType.text,
    this.initialValue,
    this.placeholder,
    this.helperText,
    this.required = false,
    this.minLength,
    this.maxLength,
    this.email = false,
    this.pattern,
    this.patternMessage,
    this.validator,
    this.builder,
    this.enabled = true,
    this.obscureText,
    this.maxLines,
    this.columnSpan = 1,
  }) : assert(columnSpan > 0);

  final String name;
  final String label;
  final AppDynamicFieldType type;
  final String? initialValue;
  final String? placeholder;
  final String? helperText;
  final bool required;
  final int? minLength;
  final int? maxLength;
  final bool email;
  final String? pattern;
  final String? patternMessage;
  final Validator<String>? validator;
  final AppDynamicFieldBuilder? builder;
  final bool enabled;
  final bool? obscureText;
  final int? maxLines;
  final int columnSpan;
}

class AppDynamicForm extends StatefulWidget {
  const AppDynamicForm({
    super.key,
    required this.fields,
    this.config = const AppDynamicFormConfig(),
    this.initialValues = const {},
    this.onSubmit,
    this.onError,
    this.errorMessage,
    this.loading = false,
  });

  final List<AppDynamicField> fields;
  final AppDynamicFormConfig config;
  final Map<String, dynamic> initialValues;
  final AppDynamicSubmit? onSubmit;
  final ValueChanged<Object>? onError;
  final String? errorMessage;
  final bool loading;

  @override
  State<AppDynamicForm> createState() => _AppDynamicFormState();
}

class _GridEntry {
  const _GridEntry(this.child, this.span);

  final Widget child;
  final int span;
}

class _AppDynamicFormState extends State<AppDynamicForm> {
  late final Map<String, FormKey<String>> _keys = {
    for (final field in widget.fields) field.name: FormKey<String>(field.name),
  };
  bool _submitting = false;

  bool get _loading => widget.loading || _submitting;

  Set<FormValidationMode> get _visibleValidationStates =>
      widget.config.validateOnChange
          ? widget.config.showErrors
          : const {FormValidationMode.submitted};

  Validator<String>? _validatorFor(AppDynamicField field) {
    final validators = <Validator<String>>[];
    if (field.required) validators.add(const NotEmptyValidator());
    if (field.minLength != null || field.maxLength != null) {
      validators.add(
        LengthValidator(min: field.minLength, max: field.maxLength),
      );
    }
    if (field.email || field.type == AppDynamicFieldType.email) {
      validators.add(const EmailValidator());
    }
    if (field.pattern != null) {
      validators.add(
        RegexValidator(RegExp(field.pattern!), message: field.patternMessage),
      );
    }
    if (field.validator != null) validators.add(field.validator!);

    if (validators.isEmpty) return null;
    return validators.reduce((current, next) => current & next);
  }

  String? _initialValue(AppDynamicField field) {
    final value = widget.initialValues[field.name] ?? field.initialValue;
    return value?.toString();
  }

  Widget _buildField(BuildContext context, AppDynamicField field) {
    final key = _keys[field.name]!;
    if (field.type == AppDynamicFieldType.custom) {
      return field.builder?.call(context, field, key) ??
          const SizedBox.shrink();
    }

    final isMultiline = field.type == AppDynamicFieldType.multiline;
    final isPassword = field.type == AppDynamicFieldType.password;
    final isNumber = field.type == AppDynamicFieldType.number;
    final keyboardType = field.type == AppDynamicFieldType.email
        ? TextInputType.emailAddress
        : isNumber
            ? TextInputType.number
            : isMultiline
                ? TextInputType.multiline
                : TextInputType.text;

    return FormField<String>(
      key: key,
      label: Text(field.label),
      hint: field.helperText == null ? null : Text(field.helperText!),
      validator: _validatorFor(field),
      showErrors: _visibleValidationStates,
      child: TextField(
        initialValue: _initialValue(field),
        placeholder:
            field.placeholder == null ? null : Text(field.placeholder!),
        enabled: field.enabled && !_loading,
        obscureText: field.obscureText ?? isPassword,
        keyboardType: keyboardType,
        maxLines: isMultiline ? (field.maxLines ?? 4) : 1,
        features: isPassword ? const [InputFeature.passwordToggle()] : const [],
      ),
    );
  }

  List<Widget> _buildGrid(BuildContext context) {
    final fields = widget.fields;
    final rows = <Widget>[];
    var rowChildren = <_GridEntry>[];
    var usedColumns = 0;

    void flushRow() {
      if (rowChildren.isEmpty) return;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < rowChildren.length; index++) ...[
              if (index > 0) SizedBox(width: widget.config.spacing),
              Expanded(
                flex: rowChildren[index].span,
                child: rowChildren[index].child,
              ),
            ],
          ],
        ),
      );
      rowChildren = [];
      usedColumns = 0;
    }

    for (final field in fields) {
      final span = field.columnSpan.clamp(1, widget.config.columns);
      if (usedColumns + span > widget.config.columns) flushRow();
      rowChildren.add(_GridEntry(_buildField(context, field), span));
      usedColumns += span;
      if (usedColumns >= widget.config.columns) flushRow();
    }
    flushRow();
    return rows;
  }

  Future<void> _submit(FormMapValues values) async {
    print("call submit button");
    if (widget.onSubmit == null || _loading) return;
    final normalized = <String, dynamic>{
      for (final field in widget.fields)
        field.name: values.getValue(_keys[field.name]!),
    };
    setState(() => _submitting = true);
    try {
      await widget.onSubmit!(normalized);
    } catch (error) {
      widget.onError?.call(error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      onSubmit: (context, values) => unawaited(_submit(values)),
      child: Padding(
        padding: widget.config.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._buildGrid(context).expand(
              (row) => [row, SizedBox(height: widget.config.runSpacing)],
            ),
            if (widget.errorMessage != null)
              widget.config.errorBuilder?.call(
                    context,
                    widget.errorMessage!,
                  ) ??
                  Text(
                    widget.errorMessage!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
            if (widget.config.showSubmitButton && widget.onSubmit != null)
              FormErrorBuilder(
                builder: (context, errors, child) {
                  void submit() => context.submitForm();
                  final button = widget.config.submitBuilder?.call(
                        context,
                        _loading,
                        submit,
                      ) ??
                      PrimaryButton(
                        onPressed: errors.isEmpty && !_loading ? submit : null,
                        child: Text(
                          _loading
                              ? 'Submitting...'
                              : widget.config.submitLabel,
                        ),
                      );
                  return Row(
                    mainAxisAlignment: widget.config.submitAlignment,
                    children: [button],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
