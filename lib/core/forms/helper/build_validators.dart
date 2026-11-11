import 'package:reactive_forms/reactive_forms.dart';

List<Validator<dynamic>> buildValidators(Map<String, dynamic> rules) {
  final validators = <Validator<dynamic>>[];

  rules.forEach((key, value) {
    switch (key) {
      case 'required':
        if (value == true) validators.add(Validators.required);
        break;
      case 'requiredTrue':
        if (value == true) validators.add(Validators.requiredTrue);
        break;
      case 'email':
        if (value == true) validators.add(Validators.email);
        break;
      case 'number':
        if (value == true) {
          validators.add(Validators.number(allowNull: true));
        }
        break;
      case 'min':
        if (value is num) validators.add(Validators.min(value));
        break;
      case 'max':
        if (value is num) validators.add(Validators.max(value));
        break;
      case 'minLength':
        if (value is int) validators.add(Validators.minLength(value));
        break;
      case 'maxLength':
        if (value is int) validators.add(Validators.maxLength(value));
        break;
      case 'pattern':
        if (value is String) validators.add(Validators.pattern(value));
        break;
      case 'creditCard':
        if (value == true) validators.add(Validators.creditCard);
        break;
      case 'equals':
        if (value != null) validators.add(Validators.equals(value));
        break;
      case 'contains':
        if (value != null) validators.add(Validators.contains(value));
        break;
      case 'oneOf':
        if (value is Iterable) {
          validators.add(Validators.oneOf(value.toList()));
        }
        break;
      case 'mustMatch':
        if (value is Map) {
          final map = Map<String, dynamic>.from(value);
          final first = map['control']?.toString();
          final second = map['matchingControl']?.toString();

          if (first != null && second != null) {
            validators.add(Validators.mustMatch(first, second));
          }
        }
        break;
    }
  });

  return validators;
}
