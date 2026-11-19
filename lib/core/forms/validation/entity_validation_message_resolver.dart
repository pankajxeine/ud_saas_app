import 'package:reactive_forms/reactive_forms.dart';

import '../models/field_meta.dart';

class EntityValidationMessageResolver {
  EntityValidationMessageResolver._();

  /// Returns the first validation message.
  static String? resolve({
    required FieldMeta<dynamic> field,
    required AbstractControl<dynamic> control,
    bool onlyWhenInteracted = true,
  }) {
    final messages = resolveAll(
      field: field,
      control: control,
      onlyWhenInteracted: onlyWhenInteracted,
    );

    return messages.isEmpty ? null : messages.first;
  }

  /// Returns all validation messages for a control.
  static List<String> resolveAll({
    required FieldMeta<dynamic> field,
    required AbstractControl<dynamic> control,
    bool onlyWhenInteracted = true,
  }) {
    if (control.valid || control.errors.isEmpty) {
      return const [];
    }

    if (onlyWhenInteracted && !control.touched && !control.dirty) {
      return const [];
    }

    final rules = _readRules(field.validationRules);
    final errors = control.errors;
    final messages = <String>[];

    for (final entry in errors.entries) {
      final errorKey = entry.key;
      final errorValue = entry.value;

      final rule = _findRule(rules: rules, errorKey: errorKey);

      final message = rule?['message']?.toString();

      final resolved = message != null && message.trim().isNotEmpty
          ? _interpolate(message, rule: rule!, error: errorValue)
          : _defaultMessage(
              errorKey: errorKey,
              error: errorValue,
              rule: rule,
              field: field,
            );

      if (!messages.contains(resolved)) {
        messages.add(resolved);
      }
    }

    return messages;
  }

  /// Returns whether a control should display its errors.
  static bool shouldShowErrors(
    AbstractControl<dynamic> control, {
    bool onlyWhenInteracted = true,
  }) {
    if (control.valid || control.errors.isEmpty) {
      return false;
    }

    return !onlyWhenInteracted || control.touched || control.dirty;
  }

  /// Reads the current rule format.
  ///
  /// Preferred:
  /// {
  ///   "rules": [
  ///     {"type": "required", "message": "..."}
  ///   ]
  /// }
  ///
  /// Also accepts legacy flat rules:
  /// {
  ///   "required": true,
  ///   "minLength": 3
  /// }
  static List<Map<String, dynamic>> _readRules(Map<String, dynamic> config) {
    final rawRules = config['rules'];

    if (rawRules is List) {
      return rawRules
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    final rules = <Map<String, dynamic>>[];

    for (final entry in config.entries) {
      if (entry.value == null || entry.value == false) {
        continue;
      }

      if (entry.key == 'required' && entry.value == true) {
        rules.add({'type': 'required'});
      } else if (entry.key == 'minLength' ||
          entry.key == 'maxLength' ||
          entry.key == 'min' ||
          entry.key == 'max' ||
          entry.key == 'pattern') {
        rules.add({'type': entry.key, 'value': entry.value});
      }
    }

    return rules;
  }

  static Map<String, dynamic>? _findRule({
    required List<Map<String, dynamic>> rules,
    required String errorKey,
  }) {
    for (final rule in rules) {
      final type = rule['type']?.toString();
      final name = rule['name']?.toString();

      final configuredErrorKey =
          rule['errorKey']?.toString() ?? (type == 'custom' ? name : type);

      if (configuredErrorKey == errorKey) {
        return rule;
      }
    }

    return null;
  }

  static String _defaultMessage({
    required String errorKey,
    required dynamic error,
    required Map<String, dynamic>? rule,
    required FieldMeta<dynamic> field,
  }) {
    final details = error is Map
        ? Map<String, dynamic>.from(error)
        : <String, dynamic>{};

    final configuredValue = rule?['value'];

    switch (errorKey) {
      case 'required':
        return '${field.label} is required';

      case 'requiredTrue':
        return 'You must accept ${field.label}';

      case 'email':
        return 'Enter a valid email address';

      case 'number':
        return 'Enter a valid number';

      case 'min':
        return 'Value must be at least '
            '${details['min'] ?? configuredValue ?? ''}';

      case 'max':
        return 'Value must not exceed '
            '${details['max'] ?? configuredValue ?? ''}';

      case 'minLength':
        return 'Minimum length is '
            '${details['requiredLength'] ?? configuredValue ?? ''}';

      case 'maxLength':
        return 'Maximum length is '
            '${details['requiredLength'] ?? configuredValue ?? ''}';

      case 'pattern':
        return 'Invalid format';

      case 'creditCard':
        return 'Enter a valid credit card number';

      case 'oneOf':
        return 'Select a valid option';

      case 'equals':
        return 'Value does not match the expected value';

      case 'mustMatch':
        return 'Values do not match';

      case 'compare':
        return 'Values do not satisfy the comparison rule';

      case 'uniqueItems':
        return 'Duplicate values are not allowed';

      case 'unique':
        return 'This value already exists';

      default:
        return '${field.label} is invalid';
    }
  }

  /// Replaces placeholders in configured messages.
  ///
  /// Supported examples:
  /// {value}
  /// {min}
  /// {max}
  /// {requiredLength}
  /// {actualLength}
  /// {actualValue}
  static String _interpolate(
    String message, {
    required Map<String, dynamic> rule,
    required dynamic error,
  }) {
    final errorDetails = error is Map
        ? Map<String, dynamic>.from(error)
        : <String, dynamic>{};

    final values = <String, dynamic>{...rule, ...errorDetails};

    return message.replaceAllMapped(RegExp(r'\{([^}]+)\}'), (match) {
      final key = match.group(1)!;
      return values[key]?.toString() ?? match.group(0)!;
    });
  }
}
