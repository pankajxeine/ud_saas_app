import 'package:flutter/material.dart';

import 'package:ud_sass_app/core/widgets/data_table/data_table.dart';

class SampleTable extends StatefulWidget {
  const SampleTable({super.key});

  @override
  State<SampleTable> createState() => _DataGridPageState();
}

class _DataGridPageState extends State<SampleTable> {
  final TextEditingController _searchController = TextEditingController();

  late final List<TrinaColumn> _columns;
  late final List<TrinaRow<dynamic>> _rows;

  String _statusFilter = 'all';
  bool _searchExpanded = false;
  String _searchField = 'all';

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

      if (_statusFilter != 'all' && status != _statusFilter) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      if (_searchField == 'all') {
        return row.cells.values.any(
          (cell) => cell.value.toString().toLowerCase().contains(query),
        );
      }

      return row.cells[_searchField]?.value.toString().toLowerCase().contains(
            query,
          ) ??
          false;
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
                  statusFilter: _statusFilter,
                  searchExpanded: _searchExpanded,
                  searchField: _searchField,
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
                  onSearchFieldChanged: (field) {
                    setState(() => _searchField = field);
                  },
                  onApplyFilters: (status) {
                    setState(() => _statusFilter = status);
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
    required this.statusFilter,
    required this.searchExpanded,
    required this.searchField,
    required this.searchController,
    required this.onSearchChanged,
    required this.onToggleSearch,
    required this.onSearchFieldChanged,
    required this.onApplyFilters,
    required this.onAdd,
  });

  final bool compact;
  final String statusFilter;
  final bool searchExpanded;
  final String searchField;

  final TextEditingController searchController;

  final ValueChanged<String> onSearchChanged;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSearchFieldChanged;
  final ValueChanged<String> onApplyFilters;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final searchFieldWidget = SizedBox(
      width: compact ? 300 : 380,
      child: Row(
        children: [
          Expanded(
            child: SearchBar(
              controller: searchController,
              onChanged: onSearchChanged,
              hintText: 'Search orders',
              leading: const Icon(Icons.search_rounded, size: 19),
              trailing: [
                if (searchController.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                    icon: const Icon(Icons.close, size: 18),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 24,
                      child: VerticalDivider(
                        thickness: 1,
                        color: scheme.outlineVariant,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: searchField,
                        borderRadius: BorderRadius.circular(12),
                        isDense: true,
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All')),
                          DropdownMenuItem(
                            value: 'id',
                            child: Text('Order ID'),
                          ),
                          DropdownMenuItem(
                            value: 'customer',
                            child: Text('Customer'),
                          ),
                          DropdownMenuItem(
                            value: 'status',
                            child: Text('Status'),
                          ),
                          DropdownMenuItem(
                            value: 'amount',
                            child: Text('Amount'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) onSearchFieldChanged(value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
              textInputAction: TextInputAction.search,
              elevation: const WidgetStatePropertyAll(0),
              side: WidgetStatePropertyAll(
                BorderSide(color: scheme.outlineVariant),
              ),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
        ],
      ),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: () => _openFilterSheet(context),
          icon: Icon(
            statusFilter == 'all'
                ? Icons.filter_alt_outlined
                : Icons.filter_alt,
            size: 18,
          ),
          label: Text(
            statusFilter == 'all' ? 'Filter' : 'Filter: $statusFilter',
          ),
        ),
        if (!compact || searchExpanded)
          searchFieldWidget
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

  Future<void> _openFilterSheet(BuildContext context) async {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;
    final selectedStatus = isMobile
        ? await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (context) => _OrderFilterPanel(status: statusFilter),
          )
        : await showGeneralDialog<String>(
            context: context,
            barrierLabel: 'Filters',
            barrierDismissible: true,
            barrierColor: Colors.black54,
            transitionDuration: const Duration(milliseconds: 220),
            pageBuilder: (context, animation, secondaryAnimation) {
              final sheetWidth = width < 900 ? width * .72 : 380.0;
              return Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: SizedBox(
                    width: sheetWidth,
                    height: double.infinity,
                    child: _OrderFilterPanel(status: statusFilter),
                  ),
                ),
              );
            },
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              );
            },
          );

    if (selectedStatus != null) onApplyFilters(selectedStatus);
  }
}

class _OrderFilterPanel extends StatefulWidget {
  const _OrderFilterPanel({required this.status});

  final String status;

  @override
  State<_OrderFilterPanel> createState() => _OrderFilterPanelState();
}

class _OrderFilterPanelState extends State<_OrderFilterPanel> {
  late String _status = widget.status;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Close filters',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                    onPressed: () => Navigator.pop(context, 'all'),
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, _status),
                    child: const Text('Apply filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
