import 'dart:async';

import 'package:flutter/material.dart';

import 'package:ud_sass_app/core/widgets/components/app_filter_sheet.dart';
import 'package:ud_sass_app/core/widgets/components/app_table_controls.dart';
import 'package:ud_sass_app/core/widgets/data_table/data_table.dart';

class DataGridPage extends StatefulWidget {
  const DataGridPage({super.key});

  @override
  State<DataGridPage> createState() => _DataGridPageState();
}

class _DataGridPageState extends State<DataGridPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  late final List<TrinaColumn> _columns;
  late final List<TrinaRow<dynamic>> _rows;

  String _statusFilter = 'all';
  bool _searchExpanded = false;
  String _searchField = 'all';
  String _submittedSearchQuery = '';
  bool showFilters = false;

  @override
  void initState() {
    super.initState();

    _columns = [
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

    _rows = [
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
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<TrinaRow<dynamic>> get _visibleRows {
    return _rows.where((row) {
      final status = row.cells['status']?.value.toString() ?? '';

      if (_statusFilter != 'all' && status != _statusFilter) {
        return false;
      }

      return _matchesSearch(
        row,
        query: _submittedSearchQuery,
        field: _searchField,
      );
    }).toList();
  }

  /// Returns whether [row] matches the submitted search query.
  ///
  /// The special `all` field searches every cell in the row. Otherwise only
  /// the selected cell field is searched.
  bool _matchesSearch(
    TrinaRow<dynamic> row, {
    required String query,
    required String field,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    final values = field == 'all'
        ? row.cells.values.map((cell) => cell.value)
        : <dynamic>[row.cells[field]?.value];

    return values.any(
      (value) => value?.toString().toLowerCase().contains(normalizedQuery) ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visibleRows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: AppFilterSheet(
            open: showFilters,
            presentation: AppFilterPresentation.auto,
            mode: AppFilterSheetMode.auto,
            desktopBreakpoint: 1024,
            mobileBreakpoint: 600,
            width: 320,
            title: 'Order filters',
            onClose: () => setState(() => showFilters = false),
            mainContent: _buildTable(context, rows),
            child: _OrderFilterPanel(
              status: _statusFilter,
              onApply: (status) {
                setState(() => _statusFilter = status);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context, List<TrinaRow<dynamic>> rows) {
    return AppDataTable(
      customHeader: const _PageHeader(
        title: 'Orders',
        subtitle: 'Manage and track your recent orders.',
      ),
      headerActionsBuilder: AppTableControls(
        searchController: _searchController,
        onSearchChanged: (value) {
          _scheduleSearch(value);
        },
        onSearchSubmitted: (value) {
          _searchDebounce?.cancel();
          _applySearch(value);
        },
        searchHint: 'Search orders',
        searchFields: const [
          AppTableSearchField(value: 'all', label: 'All'),
          AppTableSearchField(value: 'id', label: 'Order ID'),
          AppTableSearchField(value: 'customer', label: 'Customer'),
          AppTableSearchField(value: 'status', label: 'Status'),
          AppTableSearchField(value: 'amount', label: 'Amount'),
        ],
        selectedSearchField: _searchField,
        onSearchFieldChanged: (field) {
          setState(() => _searchField = field);
        },
        searchExpanded: _searchExpanded,
        onToggleSearch: () {
          setState(() {
            _searchExpanded = !_searchExpanded;
            if (!_searchExpanded) {
              _searchDebounce?.cancel();
              _searchController.clear();
              _submittedSearchQuery = '';
            }
          });
        },
        onFilterPressed: () {
          setState(() => showFilters = !showFilters);
        },
        hasActiveFilters: _statusFilter != 'all',
        showAddButton: true,
        onAdd: _addOrder,
        addLabel: 'Add order',
        addTooltip: 'Add order',
        compactBreakpoint: 640,
      ),
      columns: _columns,
      rows: rows,
      pageSize: 10,
      mobilePageSize: 5,
      mobilePageSizes: const [5, 10, 20, 50],
      mobileRowKey: (row) => row.cells['id']?.value.toString() ?? '',
      onRowTap: (rowIdx) {
        final orderId = rows[rowIdx].cells['id']?.value;
        _showOrderDetails(orderId);
      },
    );
  }

  void _scheduleSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _applySearch(value);
    });
  }

  void _applySearch(String value) {
    final query = value.trim();
    if (_submittedSearchQuery == query) return;
    setState(() => _submittedSearchQuery = query);
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _addOrder() {
    setState(() {
      final number = _rows.length + 1;

      _rows.add(
        _order(
          id: 'ORD-${number.toString().padLeft(3, '0')}',
          customer: 'New customer',
          status: 'Pending',
          amount: 0,
        ),
      );
    });
  }

  void _showOrderDetails(Object? orderId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Order details'),
          content: Text('Order ID: $orderId'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Row factory
  // ---------------------------------------------------------------------------

  TrinaRow<dynamic> _order({
    required String id,
    required String customer,
    required String status,
    required num amount,
  }) {
    return TrinaRow(
      cells: {
        'id': TrinaCell(value: id),
        'customer': TrinaCell(value: customer),
        'status': TrinaCell(value: status),
        'amount': TrinaCell(value: amount),
      },
    );
  }
}

// =============================================================================
// Page Header
// =============================================================================

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        (compact
                                ? theme.textTheme.titleLarge
                                : theme.textTheme.headlineSmall)
                            ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// Table Controls
// =============================================================================

class _OrderFilterPanel extends StatefulWidget {
  const _OrderFilterPanel({required this.status, this.onApply});

  final String status;
  final ValueChanged<String>? onApply;

  @override
  State<_OrderFilterPanel> createState() => _OrderFilterPanelState();
}

class _OrderFilterPanelState extends State<_OrderFilterPanel> {
  late String _status = widget.status;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: _status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All statuses')),
            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
            DropdownMenuItem(value: 'Shipped', child: Text('Shipped')),
            DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _status = value);
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _submit('all'),
                child: const Text('Clear'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => _submit(_status),
                child: const Text('Apply filters'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submit(String status) {
    if (widget.onApply != null) {
      widget.onApply!(status);
      if (status == 'all') setState(() => _status = 'all');
      return;
    }

    Navigator.pop(context, status);
  }
}
