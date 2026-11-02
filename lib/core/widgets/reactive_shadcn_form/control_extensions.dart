import 'package:reactive_forms/reactive_forms.dart';

extension ControlErrorText on AbstractControl {
  String get errorText {
    print('call ControlErrorText $touched $valid');
    if (!touched || valid) return '';
    final error = errors.entries.firstOrNull;

    print('firstOrNull $error');
    if (error == null) return '';

    return switch (error.key) {
      'required' => 'This field is required',
      'email' => 'Enter a Valid email address',
      'minLength' =>
        'Minimum ${(error.value as Map)['requiredLength']} characters',
      'maxLength' =>
        'Maximum ${(error.value as Map)['requiredLength']} characters',
      'min' => 'Minimum value is ${(error.value as Map)}',
      'max' => 'Maximum value is ${(error.value as Map)}',
      'mustBetrue' => 'this must be checked',
      'pattern' => 'Invalid format',
      'uniqueEmail' => 'This email is already taken',
      _ => 'Invalid value',
    };
  }

  bool get showError => touched && hasErrors;
}
