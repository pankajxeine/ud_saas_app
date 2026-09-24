import 'package:flutter_test/flutter_test.dart';
import 'package:ud_sass_app/widgets/dynamic_trina_grid.dart';

void main() {
  test('builds columns from the union of JSON keys', () {
    final data = DynamicTrinaGridData.fromJsonList([
      {'firstName': 'Ada', 'age': 36},
      {'firstName': 'Grace', 'department': 'Engineering'},
    ]);

    expect(
      data.columns.map((column) => column.field),
      ['firstName', 'age', 'department'],
    );
    expect(data.columns.first.title, 'First Name');
    expect(data.rows.first.cells['firstName']!.value, 'Ada');
    expect(data.rows.first.cells['department']!.value, isNull);
  });

  test('supports response envelopes and column overrides', () {
    final data = DynamicTrinaGridData.fromJsonResponse(
      {
        'data': [
          {
            'total': 1250,
            'status': 'paid',
            'metadata': {'source': 'api'}
          },
        ],
      },
      columnConfig: const [
        DynamicTrinaColumnConfig(
          field: 'total',
          title: 'Order Total',
          type: DynamicTrinaColumnType.number,
          width: 180,
        ),
      ],
    );

    expect(data.columns.first.title, 'Order Total');
    expect(data.columns.first.width, 180);
    expect(data.columns.map((column) => column.field), [
      'total',
      'status',
      'metadata',
    ]);
    expect(data.rows.single.data?['metadata'], {'source': 'api'});
    expect(data.rows.single.cells['metadata']!.value, '{source: api}');
  });

  test('treats a single JSON object as one row', () {
    final data = DynamicTrinaGridData.fromJsonResponse({
      'firstName': 'Ada',
      'lastName': 'Lovelace',
    });

    expect(data.rows, hasLength(1));
    expect(data.rows.single.cells['lastName']!.value, 'Lovelace');
  });
}
