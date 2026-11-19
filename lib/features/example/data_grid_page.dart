import 'package:flutter/material.dart';

import 'package:ud_sass_app/core/widgets/data_table/data_table.dart';

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
    _searchController.dispose();
    super.dispose();
  }

  List<TrinaRow<dynamic>> get _visibleRows {
    final query = _searchController.text.trim().toLowerCase();

    return _rows.where((row) {
      final status = row.cells['status']?.value.toString() ?? '';

      if (_pendingOnly && status != 'Pending') {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return row.cells.values.any(
        (cell) => cell.value.toString().toLowerCase().contains(query),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visibleRows;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(
            title: 'Orders',
            subtitle: 'Manage and track your recent orders.',
            totalCount: _rows.length,
            filteredCount: rows.length,
          ),

          const SizedBox(height: 16),

          Expanded(
            child: AppDataTable(
              title: 'All Orders',
              subtitle: '${rows.length} orders found',
              headerActionsBuilder: (context, compact) {
                return _OrderTableControls(
                  compact: compact,
                  pendingOnly: _pendingOnly,
                  searchExpanded: _searchExpanded,
                  searchController: _searchController,
                  onSearchChanged: (_) {
                    setState(() {});
                  },
                  onToggleSearch: () {
                    setState(() {
                      _searchExpanded = !_searchExpanded;

                      if (!_searchExpanded) {
                        _searchController.clear();
                      }
                    });
                  },
                  onToggleFilter: () {
                    setState(() {
                      _pendingOnly = !_pendingOnly;
                    });
                  },
                  onAdd: _addOrder,
                );
              },
              columns: _columns,
              rows: rows,
              mobilePageSize: 5,
              mobilePageSizes: const [5, 10, 20, 50],
              mobileRowKey: (row) => row.cells['id']?.value.toString() ?? '',
              onRowTap: (rowIdx) {
                final orderId = rows[rowIdx].cells['id']?.value;

                _showOrderDetails(orderId);
              },
            ),
          ),
        ],
      ),
    );
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
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.totalCount,
    required this.filteredCount,
  });

  final String title;
  final String subtitle;
  final int totalCount;
  final int filteredCount;

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
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$filteredCount / $totalCount',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final searchField = SizedBox(
      width: compact ? 170 : 220,
      height: 40,
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        textInputAction: TextInputAction.search,
        style: theme.textTheme.bodySmall,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search orders',
          prefixIcon: const Icon(Icons.search_rounded, size: 18),
          prefixIconConstraints: const BoxConstraints(minWidth: 36),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!compact || searchExpanded)
          searchField
        else
          IconButton(
            tooltip: 'Search',
            visualDensity: VisualDensity.compact,
            onPressed: onToggleSearch,
            icon: const Icon(Icons.search_rounded),
          ),

        if (compact && searchExpanded)
          IconButton(
            tooltip: 'Close search',
            visualDensity: VisualDensity.compact,
            onPressed: onToggleSearch,
            icon: const Icon(Icons.close_rounded),
          ),

        FilterChip(
          selected: pendingOnly,
          showCheckmark: false,
          visualDensity: VisualDensity.compact,
          avatar: Icon(
            Icons.filter_alt_outlined,
            size: 16,
            color: pendingOnly
                ? scheme.onSecondaryContainer
                : scheme.onSurfaceVariant,
          ),
          label: const Text('Pending'),
          onSelected: (_) => onToggleFilter(),
        ),

        if (compact)
          IconButton.filled(
            tooltip: 'Add order',
            visualDensity: VisualDensity.compact,
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
          )
        else
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add order'),
          ),
      ],
    );
  }
}
