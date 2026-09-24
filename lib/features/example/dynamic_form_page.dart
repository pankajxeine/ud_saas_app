import 'package:flutter/material.dart' hide Card;
import 'package:ud_sass_app/core/widgets/dynamic_form/app_dynamic_form.dart';
import 'package:ud_sass_app/ui/shadcn/components/form/form/form.dart';
import 'package:ud_sass_app/ui/shadcn/components/display/text/text.dart';
import 'package:ud_sass_app/ui/shadcn/components/layout/card/card.dart';

class DynamicFormPage extends StatefulWidget {
  const DynamicFormPage({super.key});

  @override
  State<DynamicFormPage> createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  String? _submittedMessage;

  static const _fields = [
    AppDynamicField(
      name: 'firstName',
      label: 'First name',
      placeholder: 'Ada',
      required: true,
      minLength: 2,
      maxLength: 40,
    ),
    AppDynamicField(
      name: 'lastName',
      label: 'Last name',
      placeholder: 'Lovelace',
      required: true,
    ),
    AppDynamicField(
      name: 'email',
      label: 'Email address',
      type: AppDynamicFieldType.email,
      placeholder: 'ada@example.com',
      helperText: 'We will use this for project updates.',
      required: true,
      email: true,
      columnSpan: 2,
    ),
    AppDynamicField(
      name: 'accessCode',
      label: 'Access code',
      type: AppDynamicFieldType.password,
      placeholder: 'Enter your access code',
      required: true,
      minLength: 8,
      validator: LengthValidator(
        min: 8,
        message: 'Use at least 8 characters for the access code.',
      ),
    ),
    AppDynamicField(
      name: 'teamSize',
      label: 'Team size',
      type: AppDynamicFieldType.number,
      placeholder: '10',
    ),
    AppDynamicField(
      name: 'brief',
      label: 'Project brief',
      type: AppDynamicFieldType.multiline,
      placeholder: 'Tell us what you are building...',
      maxLines: 4,
      columnSpan: 2,
    ),
  ];

  Future<void> _submit(Map<String, dynamic> values) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() {
      _submittedMessage = 'Form submitted with ${values.length} values.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dynamic form').semiBold().h2(),
                  const SizedBox(height: 6),
                  const Text(
                    'A schema-driven form with validation, grid layout, and reusable field configuration.',
                  ).muted(),
                  const SizedBox(height: 24),
                  Card(
                    padding: const EdgeInsets.all(24),
                    child: AppDynamicForm(
                      fields: _fields,
                      config: const AppDynamicFormConfig(
                        columns: 2,
                        spacing: 16,
                        runSpacing: 16,
                        submitLabel: 'Save profile',
                      ),
                      onSubmit: _submit,
                    ),
                  ),
                  if (_submittedMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(_submittedMessage!).muted(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
