import 'package:flutter/material.dart' hide DataTable, Scaffold;
import 'package:ud_sass_app/core/widgets/data_table/data_table.dart';
import 'package:ud_sass_app/ui/dashcn/components/alert.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/components/input.dart';
import 'package:ud_sass_app/ui/dashcn/components/scaffold.dart' as app_scaffold;
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/bootstrap_icons.dart';
import 'package:ud_sass_app/ui/dashcn/src/primitives/input_features/adornment_features.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart' as dashcn;

class DataGridPage extends StatefulWidget {
  const DataGridPage({super.key});

  @override
  State<DataGridPage> createState() => _DataGridPageState();
}

class _DataGridPageState extends State<DataGridPage> {
  final TextEditingController _searchController = TextEditingController();
  late final List<TrinaColumn> _columns;
  late final List<TrinaRow<dynamic>> _rows;
  bool _pendingOnly = false;
  bool _searchExpanded = false;

  @override
  void initState() {
    super.initState();
    _columns = <TrinaColumn>[
      TrinaColumn(
        title: 'Order ID',
        field: 'id',
        type: TrinaColumnType.text(),
        width: 120,
        enableRowChecked: true,
      ),
      TrinaColumn(
        title: 'Customer',
        field: 'customer',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Status',
        field: 'status',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Amount',
        field: 'amount',
        type: TrinaColumnType.number(),
      ),
    ];
    _rows = <TrinaRow<dynamic>>[
      _order(id: 'ORD-001', customer: 'Alice', status: 'Pending', amount: 250),
      _order(id: 'ORD-002', customer: 'Bob', status: 'Shipped', amount: 120),
      _order(
        id: 'ORD-003',
        customer: 'Charlie',
        status: 'Delivered',
        amount: 560,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TrinaRow<dynamic>> get _visibleRows {
    final String query = _searchController.text.trim().toLowerCase();
    return _rows.where((TrinaRow<dynamic> row) {
      final String status = row.cells['status']?.value.toString() ?? '';
      if (_pendingOnly && status != 'Pending') {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return row.cells.values.any(
        (TrinaCell cell) => cell.value.toString().toLowerCase().contains(query),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<TrinaRow<dynamic>> rows = _visibleRows;
    return app_scaffold.Scaffold(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          title: 'Orders',
          subtitle: 'Manage and track your recent orders.',
          headerActionsBuilder: (BuildContext context, bool compact) =>
              _OrderTableControls(
                compact: compact,
                pendingOnly: _pendingOnly,
                searchExpanded: _searchExpanded,
                searchController: _searchController,
                onSearchChanged: (_) => setState(() {}),
                onToggleSearch: () {
                  setState(() {
                    _searchExpanded = !_searchExpanded;
                    if (!_searchExpanded) {
                      _searchController.clear();
                    }
                  });
                },
                onToggleFilter: () =>
                    setState(() => _pendingOnly = !_pendingOnly),
                onAdd: _addOrder,
              ),
          columns: _columns,
          rows: rows,
          mobilePageSize: 2,
          mobilePageSizes: const <int>[2, 5, 10, 20, 50],
          mobileRowKey: (TrinaRow<dynamic> row) =>
              row.cells['id']?.value.toString() ?? '',
          onRowTap: (int rowIdx) {
            final Object? orderId = rows[rowIdx].cells['id']?.value;
            Alert(
              title: const Text('Order details'),
              content: Text('Tapped order $orderId'),
            );
          },
        ),
      ),
    );
  }

  void _addOrder() {
    setState(() {
      final int orderNumber = _rows.length + 1;
      _rows.add(
        _order(
          id: 'ORD-${orderNumber.toString().padLeft(3, '0')}',
          customer: 'New customer',
          status: 'Pending',
          amount: 0,
        ),
      );
    });
  }

  TrinaRow<dynamic> _order({
    required String id,
    required String customer,
    required String status,
    required num amount,
  }) => TrinaRow<dynamic>(
    cells: <String, TrinaCell>{
      'id': TrinaCell(value: id),
      'customer': TrinaCell(value: customer),
      'status': TrinaCell(value: status),
      'amount': TrinaCell(value: amount),
    },
  );
}

class _OrderTableControls extends StatelessWidget {
  const _OrderTableControls({
    required this.compact,
    required this.pendingOnly,
    required this.searchExpanded,
    required this.searchController,
    required this.onSearchChanged,
    required this.onToggleSearch,
    required this.onToggleFilter,
    required this.onAdd,
  });

  final bool compact;
  final bool pendingOnly;
  final bool searchExpanded;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onToggleSearch;
  final VoidCallback onToggleFilter;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final dashcn.ThemeColors colors = dashcn.Theme.of(context).colors;
    final Widget search = SizedBox(
      width: compact ? 150 : 220,
      child: Input(
        controller: searchController,
        onChanged: onSearchChanged,
        placeholder: const Text('Search orders'),
        borderRadius: BorderRadius.circular(9),
        filled: true,
        features: const [
          InputLeadingFeature(Icon(BootstrapIcons.search, size: 16)),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (compact)
            if (searchExpanded)
              search
            else
              Button(
                size: ButtonSize.icon,
                variant: ButtonVariant.ghost,
                onPressed: onToggleSearch,
                child: const Icon(BootstrapIcons.search, size: 18),
              )
          else
            search,
          if (compact && searchExpanded)
            Button(
              size: ButtonSize.icon,
              variant: ButtonVariant.ghost,
              onPressed: onToggleSearch,
              child: const Icon(BootstrapIcons.x, size: 18),
            ),
          Button(
            variant: pendingOnly
                ? ButtonVariant.secondary
                : ButtonVariant.ghost,
            size: compact ? ButtonSize.icon : ButtonSize.sm,
            onPressed: onToggleFilter,
            leading: compact
                ? null
                : const Icon(BootstrapIcons.filter, size: 16),
            child: compact
                ? const Icon(BootstrapIcons.filter, size: 18)
                : Text(pendingOnly ? 'Pending' : 'Filter'),
          ),
          const SizedBox(width: 4),
          Button(
            size: compact ? ButtonSize.icon : ButtonSize.sm,
            onPressed: onAdd,
            leading: compact ? null : const Icon(BootstrapIcons.plus, size: 16),
            child: compact
                ? const Icon(BootstrapIcons.plus, size: 18)
                : const Text('Add order'),
          ),
        ],
      ),
    );
  }
}
