import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'factory/entity_form_control_factory.dart';
import 'models/entity_meta.dart';
import 'models/field_meta.dart';
import 'registry/entity_field_widget_registry.dart';
import 'renderer/entity_form_renderer.dart';

import 'validation/entity_custom_validator_registry.dart';
import 'validation/entity_validation_factory.dart';
import 'validation/entity_validation_message_resolver.dart';

class AppReactiveForm extends StatefulWidget {
  const AppReactiveForm({
    super.key,
    required this.meta,
    this.mode = EntityMode.create,
    this.initialData,
    this.registry,
    this.customValidators,
    this.onSubmit,
  });

  final EntityMeta meta;
  final EntityMode mode;
  final Map<String, dynamic>? initialData;

  final EntityFieldWidgetRegistry? registry;

  /// Registry for application-specific custom validators.
  final EntityCustomValidatorRegistry? customValidators;

  final Future<void> Function(Map<String, dynamic> data)? onSubmit;

  @override
  State<AppReactiveForm> createState() => _EntityReactiveFormState();
}

class _EntityReactiveFormState extends State<AppReactiveForm> {
  late FormGroup _form;
  late EntityFieldWidgetRegistry _registry;

  @override
  void initState() {
    super.initState();

    _registry = widget.registry ?? EntityFieldWidgetRegistry();

    _createForm();
  }

  @override
  void didUpdateWidget(covariant AppReactiveForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.registry != widget.registry) {
      _registry = widget.registry ?? EntityFieldWidgetRegistry();
    }

    if (oldWidget.meta != widget.meta ||
        oldWidget.initialData != widget.initialData ||
        oldWidget.mode != widget.mode ||
        oldWidget.customValidators != widget.customValidators) {
      _createForm();
    }
  }

  /// Creates the form and attaches metadata-driven validators.
  void _createForm() {
    _form = EntityFormControlFactory.createFormGroup(
      fields: widget.meta.fields,
      initialData: widget.initialData,
      mode: widget.mode,
      validatorBuilder: _buildValidators,
      asyncValidatorBuilder: _buildAsyncValidators,
    );
  }

  /// Builds predefined and custom validators for a field.
  ///
  /// Group and array validators are attached by
  /// EntityFormControlFactory when it creates those controls.
  List<Validator<dynamic>> _buildValidators(FieldMeta<dynamic> field) {
    final rules = <String, dynamic>{
      ...field.validationRules,
      ...field.groupValidationRules,
      ...field.arrayValidationRules,
    };
    return EntityValidationFactory.buildValidators(
      rules,
      customValidators: widget.customValidators,
    );
  }

  List<AsyncValidator<dynamic>> _buildAsyncValidators(
    FieldMeta<dynamic> field,
  ) {
    return EntityValidationFactory.buildAsyncValidators(
      field.asyncValidationRules,
      customValidators: widget.customValidators,
    );
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.mode == EntityMode.view) return;

    _form.markAllAsTouched();
    _form.updateValueAndValidity();

    if (!_form.valid) {
      setState(() {});
      return;
    }

    final data = Map<String, dynamic>.from(_form.value);

    await widget.onSubmit?.call(data);
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormLayout(),

          // Displays validation errors for fields, groups and arrays.
          EntityValidationSummary(fields: widget.meta.fields, form: _form),

          if (widget.mode != EntityMode.view) ...[
            const SizedBox(height: 20),

            ReactiveFormConsumer(
              builder: (context, form, child) {
                return FilledButton(
                  onPressed: _submit,
                  child: const Text('Save'),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormLayout() {
    final sections = _sections;
    switch (widget.meta.formLayout) {
      case EntityFormLayoutMode.tabs:
        return DefaultTabController(
          length: sections.length,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TabBar(
                tabs: sections
                    .map((section) => Tab(text: section.title))
                    .toList(),
              ),
              SizedBox(
                height: 560,
                child: TabBarView(
                  children: sections.map(_buildSection).toList(),
                ),
              ),
            ],
          ),
        );
      case EntityFormLayoutMode.stepper:
        return _EntityFormStepper(sections: sections, builder: _buildSection);
      case EntityFormLayoutMode.basic:
        return _buildSection(sections.first);
    }
  }

  List<EntityFormSection> get _sections {
    if (widget.meta.sections.isNotEmpty) return widget.meta.sections;
    return [
      EntityFormSection(
        id: 'default',
        title: widget.meta.entityName,
        fields: widget.meta.fields.map((field) => field.name).toList(),
      ),
    ];
  }

  Widget _buildSection(EntityFormSection section) {
    final fields = section.fields.isEmpty
        ? widget.meta.fields
        : widget.meta.fields
              .where((field) => section.fields.contains(field.name))
              .toList();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: EntityFormRenderer(
          fields: fields,
          form: _form,
          mode: widget.mode,
          registry: _registry,
        ),
      ),
    );
  }
}

class _EntityFormStepper extends StatefulWidget {
  const _EntityFormStepper({required this.sections, required this.builder});
  final List<EntityFormSection> sections;
  final Widget Function(EntityFormSection section) builder;

  @override
  State<_EntityFormStepper> createState() => _EntityFormStepperState();
}

class _EntityFormStepperState extends State<_EntityFormStepper> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: currentStep,
      onStepContinue: currentStep < widget.sections.length - 1
          ? () => setState(() => currentStep++)
          : null,
      onStepCancel: currentStep > 0
          ? () => setState(() => currentStep--)
          : null,
      steps: widget.sections
          .map(
            (section) => Step(
              title: Text(section.title),
              content: widget.builder(section),
              isActive: widget.sections.indexOf(section) <= currentStep,
            ),
          )
          .toList(),
    );
  }
}

/// Displays validation messages recursively.
///
/// Handles:
/// - Primitive FormControl errors
/// - FormGroup errors
/// - Nested group fields
/// - FormArray errors
/// - Array item errors
class EntityValidationSummary extends StatelessWidget {
  const EntityValidationSummary({
    super.key,
    required this.fields,
    required this.form,
  });

  final List<FieldMeta<dynamic>> fields;
  final FormGroup form;

  @override
  Widget build(BuildContext context) {
    final messages = <String>[];

    for (final field in fields) {
      final control = form.controls[field.name];

      if (control == null) continue;

      _collectMessages(field: field, control: control, messages: messages);
    }

    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: messages
            .map(
              (message) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(message),
              ),
            )
            .toList(),
      ),
    );
  }

  void _collectMessages({
    required FieldMeta<dynamic> field,
    required AbstractControl<dynamic> control,
    required List<String> messages,
  }) {
    // Resolve errors attached to this control itself.
    messages.addAll(
      EntityValidationMessageResolver.resolveAll(
        field: field,
        control: control,
      ),
    );

    // Recursively resolve nested FormGroup fields.
    if (control is FormGroup) {
      for (final childField in field.fields) {
        final childControl = control.controls[childField.name];

        if (childControl == null) continue;

        _collectMessages(
          field: childField,
          control: childControl,
          messages: messages,
        );
      }
    }

    // Resolve FormArray errors and item-level errors.
    if (control is FormArray && field.itemMeta != null) {
      for (final itemControl in control.controls) {
        _collectMessages(
          field: field.itemMeta!,
          control: itemControl,
          messages: messages,
        );
      }
    }
  }
}
