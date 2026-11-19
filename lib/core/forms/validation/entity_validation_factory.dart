import 'package:reactive_forms/reactive_forms.dart';
import 'entity_custom_validator_registry.dart';

class EntityValidationFactory {
  EntityValidationFactory._();

  /// Validators for FormControl.
  ///
  /// Supports:
  /// required, requiredTrue, email, number, min, max,
  /// minLength, maxLength, pattern, creditCard, equals,
  /// contains and oneOf.
  static List<Validator<dynamic>> buildValidators(
    Map<String, dynamic> rules, {
    EntityCustomValidatorRegistry? customValidators,
  }) {
    final validators = <Validator<dynamic>>[];

    rules.forEach((key, value) {
      switch (key) {
        case 'required':
          if (value == true) {
            validators.add(Validators.required);
          }
          break;

        case 'requiredTrue':
          if (value == true) {
            validators.add(Validators.requiredTrue);
          }
          break;

        case 'email':
          if (value == true) {
            validators.add(Validators.email);
          }
          break;

        case 'number':
          if (value == true) {
            validators.add(Validators.number(allowNull: true));
          }
          break;

        case 'min':
          if (value is num) {
            validators.add(Validators.min(value));
          }
          break;

        case 'max':
          if (value is num) {
            validators.add(Validators.max(value));
          }
          break;

        case 'minLength':
          if (value is int) {
            validators.add(Validators.minLength(value));
          }
          break;

        case 'maxLength':
          if (value is int) {
            validators.add(Validators.maxLength(value));
          }
          break;

        case 'pattern':
          if (value is String && value.isNotEmpty) {
            validators.add(Validators.pattern(value));
          }
          break;

        case 'creditCard':
          if (value == true) {
            validators.add(Validators.creditCard);
          }
          break;

        case 'equals':
          if (value != null) {
            validators.add(Validators.equals(value));
          }
          break;

        case 'contains':
          if (value is Iterable) {
            validators.add(Validators.contains<dynamic>(value.toList()));
          }
          break;

        case 'oneOf':
          if (value is Iterable) {
            validators.add(Validators.oneOf(value.toList()));
          }
          break;

        case 'composeOR':
          if (value is Iterable) {
            final alternatives = value
                .whereType<Map>()
                .map((item) => buildValidators(Map<String, dynamic>.from(item), customValidators: customValidators))
                .where((items) => items.isNotEmpty)
                .map((items) => Validators.compose(items))
                .toList();
            if (alternatives.isNotEmpty) {
              validators.add(Validators.composeOR(alternatives));
            }
          }
          break;

        // Group-only rules are intentionally not added here.
        case 'mustMatch':
        case 'compare':
          break;
      }
    });

    final configuredRules = rules['rules'];
    if (customValidators != null && configuredRules is Iterable) {
      for (final item in configuredRules.whereType<Map>()) {
        final rule = Map<String, dynamic>.from(item);
        final name = rule['name']?.toString();
        if (name != null && customValidators.contains(name)) {
          validators.add(customValidators.create(name, rule));
        }
      }
    }

    return validators;
  }

  static List<AsyncValidator<dynamic>> buildAsyncValidators(
    List<Map<String, dynamic>> rules, {
    EntityCustomValidatorRegistry? customValidators,
  }) {
    if (customValidators == null) return const [];
    return rules
        .map((rule) => rule['name']?.toString())
        .whereType<String>()
        .where(customValidators.containsAsync)
        .map((name) => customValidators.createAsync(name, rules.firstWhere((rule) => rule['name'] == name)))
        .toList();
  }

  /// Validators for FormGroup.
  ///
  /// Example:
  /// {
  ///   "mustMatch": {
  ///     "control": "password",
  ///     "matchingControl": "confirmPassword"
  ///   }
  /// }
  static List<Validator<dynamic>> buildGroupValidators(
    Map<String, dynamic> rules,
  ) {
    final validators = <Validator<dynamic>>[];

    final mustMatch = rules['mustMatch'];

    if (mustMatch is Map) {
      final map = Map<String, dynamic>.from(mustMatch);

      final first = map['control']?.toString();
      final second = map['matchingControl']?.toString();

      if (first != null &&
          first.isNotEmpty &&
          second != null &&
          second.isNotEmpty) {
        validators.add(Validators.mustMatch(first, second));
      }
    }

    return validators;
  }

  /// Validators for FormArray.
  ///
  /// Supports:
  /// minLength, maxLength and contains.
  static List<Validator<dynamic>> buildArrayValidators(
    Map<String, dynamic> rules,
  ) {
    final validators = <Validator<dynamic>>[];

    final minLength = rules['minLength'];
    if (minLength is int) {
      validators.add(Validators.minLength(minLength));
    }

    final maxLength = rules['maxLength'];
    if (maxLength is int) {
      validators.add(Validators.maxLength(maxLength));
    }

    final contains = rules['contains'];
    if (contains is Iterable) {
      validators.add(Validators.contains<dynamic>(contains.toList()));
    }

    if (rules['uniqueItems'] == true) {
      validators.add(
        Validators.delegate((control) {
          final values = control.value is Iterable
              ? (control.value as Iterable).map((item) => item.value).toList()
              : const [];
          return values.toSet().length == values.length
              ? null
              : {'uniqueItems': true};
        }),
      );
    }

    return validators;
  }
}

/// Backward-compatible top-level function.
///
/// Existing code using buildValidators(rules) can continue working.
List<Validator<dynamic>> buildValidators(Map<String, dynamic> rules) {
  return EntityValidationFactory.buildValidators(rules);
}
