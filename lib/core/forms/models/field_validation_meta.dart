class FieldValidationMeta {
  const FieldValidationMeta({
    this.required = false,
    this.email = false,
    this.minLength,
    this.maxLength,
    this.min,
    this.max,
  });

  final bool required;
  final bool email;

  final int? minLength;
  final int? maxLength;

  final num? min;
  final num? max;

  factory FieldValidationMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const FieldValidationMeta();
    }

    return FieldValidationMeta(
      required: json['required'] == true,
      email: json['email'] == true,
      minLength: json['minLength'] as int?,
      maxLength: json['maxLength'] as int?,
      min: json['min'] as num?,
      max: json['max'] as num?,
    );
  }
}
