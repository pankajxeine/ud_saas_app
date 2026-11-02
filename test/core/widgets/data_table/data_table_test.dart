import 'package:flutter/material.dart' hide DataTable;
import 'package:flutter_test/flutter_test.dart';
import 'package:ud_sass_app/core/widgets/data_table/data_table.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart' as dashcn;

void main() {
  testWidgets('renders responsive header and mobile rows with pagination', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final List<TrinaColumn> columns = <TrinaColumn>[
      TrinaColumn(title: 'Order ID', field: 'id', type: TrinaColumnType.text()),
      TrinaColumn(
        title: 'Customer',
        field: 'customer',
        type: TrinaColumnType.text(),
      ),
    ];
    final List<TrinaRow<dynamic>> rows = <TrinaRow<dynamic>>[
      _row('ORD-001', 'Alice'),
      _row('ORD-002', 'Bob'),
      _row('ORD-003', 'Charlie'),
    ];
    Set<String>? selectedRows;

    await tester.pumpWidget(
      dashcn.Theme(
        data: const dashcn.ThemeData(),
        child: MaterialApp(
          home: Material(
            child: SizedBox.expand(
              child: DataTable(
                title: 'Orders',
                subtitle: 'Recent orders',
                columns: columns,
                rows: rows,
                mobilePageSize: 1,
                mobilePageSizes: const <int>[1, 2],
                mobileRowKey: (TrinaRow<dynamic> row) =>
                    row.cells['id']!.value.toString(),
                onMobileSelectionChanged: (Set<String> value) {
                  selectedRows = value;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Recent orders'), findsOneWidget);
    expect(find.text('ORD-001'), findsOneWidget);
    expect(find.text('ORD-002'), findsNothing);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.byTooltip('Next page'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();
    expect(selectedRows, <String>{'ORD-001'});

    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    expect(find.text('ORD-001'), findsNothing);
    expect(find.text('ORD-002'), findsOneWidget);
    expect(find.text('2 / 3'), findsOneWidget);
  });
}

TrinaRow<dynamic> _row(String id, String customer) => TrinaRow<dynamic>(
  cells: <String, TrinaCell>{
    'id': TrinaCell(value: id),
    'customer': TrinaCell(value: customer),
  },
);
