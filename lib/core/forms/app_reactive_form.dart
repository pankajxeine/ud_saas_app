import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';

import 'factories/entity_form_control_factory.dart';
import 'models/entity_meta.dart';
// import 'models/field_meta.dart';
import 'registry/entity_field_widget_registry.dart';
import 'renderer/entity_form_renderer.dart';

class AppReactiveForm extends StatefulWidget {
  const AppReactiveForm({
    super.key,
    required this.meta,
    this.mode = EntityMode.create,
    this.initialData,
    this.registry,
    this.onSubmit,
  });

  final EntityMeta meta;
  final EntityMode mode;
  final Map<String, dynamic>? initialData;

  final EntityFieldWidgetRegistry? registry;

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

    if (oldWidget.meta != widget.meta ||
        oldWidget.initialData != widget.initialData ||
        oldWidget.mode != widget.mode) {
      _createForm();
    }
  }

  void _createForm() {
    _form = EntityFormControlFactory.createFormGroup(
      fields: widget.meta.fields,
      initialData: widget.initialData,
      mode: widget.mode,
    );
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _form.markAllAsTouched();

    if (!_form.valid) {
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
          EntityFormRenderer(
            fields: widget.meta.fields,
            form: _form,
            mode: widget.mode,
            registry: _registry,
          ),

          if (widget.mode != EntityMode.view) ...[
            const SizedBox(height: 20),

            ReactiveFormConsumer(
              builder: (context, form, child) {
                return Button(
                  onPressed: form.valid ? _submit : _submit,
                  child: const Text('Save'),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
