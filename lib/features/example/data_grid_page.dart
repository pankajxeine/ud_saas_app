import 'package:ud_sass_app/ui/shadcn/components/layout/alert/alert.dart';
import 'package:ud_sass_app/ui/shadcn/components/layout/flex/flex.dart';
import 'package:ud_sass_app/core/widgets/data_table/data_table.dart'; // <-- your wrapper
import 'package:ud_sass_app/ui/shadcn/components/layout/scaffold/scaffold.dart';

class DataGridPage extends StatelessWidget {
  const DataGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define columns
    final columns = [
      TrinaColumn(
        title: "Order ID",
        field: "id",
        type: TrinaColumnType.text(),
        width: 120,
        enableRowChecked: true,
      ),
      TrinaColumn(
        title: "Customer",
        field: "customer",
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: "Status",
        field: "status",
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: "Amount",
        field: "amount",
        type: TrinaColumnType.number(),
      ),
    ];

    // Define rows
    final rows = [
      TrinaRow(cells: {
        "id": TrinaCell(value: "ORD-001"),
        "customer": TrinaCell(value: "Alice"),
        "status": TrinaCell(value: "Pending"),
        "amount": TrinaCell(value: 250.0),
      }),
      TrinaRow(cells: {
        "id": TrinaCell(value: "ORD-002"),
        "customer": TrinaCell(value: "Bob"),
        "status": TrinaCell(value: "Shipped"),
        "amount": TrinaCell(value: 120.0),
      }),
      TrinaRow(cells: {
        "id": TrinaCell(value: "ORD-003"),
        "customer": TrinaCell(value: "Charlie"),
        "status": TrinaCell(value: "Delivered"),
        "amount": TrinaCell(value: 560.0),
      }),
    ];

    return Scaffold(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DataTable(
          columns: columns,
          rows: rows,
          onRowTap: (rowIdx) {
            final orderId = rows[rowIdx].cells["id"]?.value;
            Alert(
                title: Text('Alert title'),
                content: Text("Tapped row $rowIdx → $orderId"));
          },
        ),
      ),
    );
  }
}
