import 'package:reactive_forms/reactive_forms.dart';

// final customValidators = EntityCustomValidatorRegistry()
//   ..register('uniqueItems', (rule) {
//     return Validators.delegate((control) {
//       final value = control.value;

//       if (value is! List) return null;

//       final uniqueValues = value.toSet();

//       return uniqueValues.length == value.length ? null : {'uniqueItems': true};
//     });
//   });
typedef EntityCustomValidatorBuilder =
    Validator<dynamic> Function(Map<String, dynamic> rule);
typedef EntityCustomAsyncValidatorBuilder =
    AsyncValidator<dynamic> Function(Map<String, dynamic> rule);

class EntityCustomValidatorRegistry {
  EntityCustomValidatorRegistry();

  final Map<String, EntityCustomValidatorBuilder> _builders = {};
  final Map<String, EntityCustomAsyncValidatorBuilder> _asyncBuilders = {};

  void register(String name, EntityCustomValidatorBuilder builder) {
    _builders[name] = builder;
  }

  void registerAsync(String name, EntityCustomAsyncValidatorBuilder builder) {
    _asyncBuilders[name] = builder;
  }

  bool contains(String name) => _builders.containsKey(name);

  Validator<dynamic> create(String name, Map<String, dynamic> rule) {
    final builder = _builders[name];

    if (builder == null) {
      throw ArgumentError('Unknown custom validator: $name');
    }

    return builder(rule);
  }

  bool containsAsync(String name) => _asyncBuilders.containsKey(name);

  AsyncValidator<dynamic> createAsync(
    String name,
    Map<String, dynamic> rule,
  ) {
    final builder = _asyncBuilders[name];
    if (builder == null) {
      throw ArgumentError('Unknown custom async validator: $name');
    }
    return builder(rule);
  }
}
