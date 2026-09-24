import 'package:flutter_test/flutter_test.dart';
import 'package:ud_sass_app/core/widgets/dynamic_form/app_dynamic_form.dart';

void main() {
  test('dynamic field exposes configurable defaults', () {
    const field = AppDynamicField(
      name: 'email',
      label: 'Email',
      type: AppDynamicFieldType.email,
      required: true,
      columnSpan: 2,
    );

    expect(field.name, 'email');
    expect(field.type, AppDynamicFieldType.email);
    expect(field.required, isTrue);
    expect(field.columnSpan, 2);
  });

  test('form config supports a multi-column layout', () {
    const config = AppDynamicFormConfig(
      columns: 3,
      spacing: 12,
      runSpacing: 16,
      showSubmitButton: false,
    );

    expect(config.columns, 3);
    expect(config.spacing, 12);
    expect(config.runSpacing, 16);
    expect(config.showSubmitButton, isFalse);
  });

  test('field supports declarative and custom validation configuration', () {
    const field = AppDynamicField(
      name: 'email',
      label: 'Email',
      type: AppDynamicFieldType.email,
      required: true,
      minLength: 5,
      maxLength: 80,
      email: true,
      pattern: r'@example\.com$',
      patternMessage: 'Use an example.com address.',
    );

    expect(field.required, isTrue);
    expect(field.minLength, 5);
    expect(field.maxLength, 80);
    expect(field.email, isTrue);
    expect(field.patternMessage, 'Use an example.com address.');
  });
}
