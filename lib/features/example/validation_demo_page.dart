// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:ud_sass_app/core/forms/app_reactive_form.dart';
import 'package:ud_sass_app/core/forms/helper/field_meta_helper.dart';
import 'package:ud_sass_app/core/forms/models/entity_meta.dart';
import 'package:ud_sass_app/core/forms/validation/entity_custom_validator_registry.dart';

import 'validation_demo_schema.dart';

class ValidationDemoPage extends StatelessWidget {
  const ValidationDemoPage({super.key});

  static final EntityMeta demoMeta = entityMetaFromJsonSchema(
    validationDemoSchema,
  );

  static final EntityCustomValidatorRegistry validators =
      EntityCustomValidatorRegistry()
        ..register('reservedUsername', (rule) {
          return Validators.delegate((control) {
            const reserved = {'admin', 'root', 'system', 'support'};
            final value = control.value?.toString().toLowerCase();
            return value != null && reserved.contains(value)
                ? {
                    'reservedUsername': {'message': rule['message']},
                  }
                : null;
          });
        })
        ..register('exampleDomain', (rule) {
          return Validators.delegate((control) {
            final values = control is FormArray
                ? control.controls.map((item) => item.value?.toString() ?? '')
                : const <String>[];
            return values.any((value) => value.endsWith('@example.com'))
                ? null
                : {
                    'exampleDomain': {'message': rule['message']},
                  };
          });
        })
        ..registerAsync('uniqueEmail', (rule) => _UniqueEmailValidator());

  static const initialData = <String, dynamic>{
    'username': 'admin',
    'email': 'taken@example.com',
    'age': 16,
    'terms': false,
    'creditCard': '',
    'confirmationCode': '',
    'role': 'guest',
    'website': '',
    'contact': '',
    'credentials': {
      'password': 'Password123',
      'confirmPassword': 'Password456',
    },
    'emails': ['first@example.com', 'first@example.com'],
    'selectedFeatures': ['flutter'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: AppReactiveForm(
              meta: demoMeta,
              initialData: initialData,
              customValidators: validators,
              onSubmit: (data) async => debugPrint('VALID FORM DATA: $data'),
            ),
          ),
        ),
      ),
    );
  }
}

class _UniqueEmailValidator extends AsyncValidator<dynamic> {
  @override
  Future<Map<String, dynamic>?> validate(
    AbstractControl<dynamic> control,
  ) async {
    final email = control.value?.toString().trim().toLowerCase();
    if (email == null || email.isEmpty) return null;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return {'taken@example.com', 'existing@example.com'}.contains(email)
        ? {
            'emailTaken': {'value': email},
          }
        : null;
  }
}
