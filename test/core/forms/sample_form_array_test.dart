import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:ud_sass_app/core/forms/examples/sample_form_array.dart';
import 'package:ud_sass_app/core/forms/factories/entity_form_control_factory.dart';

void main() {
  test('sample schema creates an object FormArray with initial data', () {
    final form = EntityFormControlFactory.createFormGroup(
      fields: sampleOrderFormMeta.fields,
      initialData: const {
        'customerName': 'Ada Lovelace',
        'items': [
          {'productName': 'Notebook', 'quantity': 2, 'unitPrice': 12.5},
        ],
      },
    );

    final items = form.control('items') as FormArray<dynamic>;
    final item = items.controls[0] as FormGroup;

    expect(items.controls, hasLength(1));
    expect(item.control('productName').value, 'Notebook');
    expect(item.control('quantity').value, 2);
    expect(item.control('unitPrice').value, 12.5);

    form.dispose();
  });
}
