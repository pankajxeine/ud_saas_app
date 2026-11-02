import 'package:flutter/material.dart' hide Theme, Checkbox;
import 'package:trina_grid/trina_grid.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/components/checkbox.dart';
import 'package:ud_sass_app/ui/dashcn/components/fab.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/bootstrap_icons.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart' as dashcn;

class MobileDataTableView extends StatelessWidget {
  const MobileDataTableView({
    super.key,
    required this.header,
    required this.columns,
    required this.rows,
    required this.selectedRowKeys,
    required this.rowKey,
    required this.onSelectionChanged,
    required this.onSelectVisible,
    required this.page,
    required this.pageCount,
    required this.pageSize,
    required this.pageSizes,
    required this.totalRows,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onPageSizeChanged,
    this.rowIndexOffset = 0,
    this.onRowTap,
    this.title,
  });
  final String? title;
  final List<TrinaColumn> columns;
  final List<TrinaRow<dynamic>> rows;
  final Set<String> selectedRowKeys;
  final String Function(TrinaRow<dynamic> row) rowKey;
  final ValueChanged<String> onSelectionChanged;
  final VoidCallback onSelectVisible;
  final int page;
  final int pageCount;
  final int pageSize;
  final List<int> pageSizes;
  final int totalRows;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final ValueChanged<int> onPageSizeChanged;
  final int rowIndexOffset;
  final ValueChanged<int>? onRowTap;
  final Widget header;

  @override
  Widget build(BuildContext context) {
    final dashcn.ThemeColors colors = dashcn.Theme.of(context).colors;
    final List<String> visibleKeys = rows.map(rowKey).toList();
    final bool allSelected =
        visibleKeys.isNotEmpty && visibleKeys.every(selectedRowKeys.contains);
    final bool someSelected = visibleKeys.any(selectedRowKeys.contains);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title ?? '',
          style: dashcn.Theme.of(context).typography.h2.copyWith(
            color: colors.mutedForeground,
            fontWeight: FontWeight.w700,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: <Widget>[
              Checkbox(
                value: allSelected
                    ? CheckboxValue.checked
                    : someSelected
                    ? CheckboxValue.indeterminate
                    : CheckboxValue.unchecked,
                tristate: true,
                onChanged: rows.isEmpty ? null : (_) => onSelectVisible(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedRowKeys.isEmpty
                      ? '$totalRows items'
                      : '${selectedRowKeys.length} selected',
                  style: dashcn.Theme.of(
                    context,
                  ).typography.small.copyWith(color: colors.mutedForeground),
                ),
              ),
              header,
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: rows.length,
            padding: const EdgeInsets.only(bottom: 12),
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final TrinaRow<dynamic> row = rows[index];
              final String key = rowKey(row);
              final bool selected = selectedRowKeys.contains(key);
              return _MobileDataTableCard(
                columns: columns,
                row: row,
                selected: selected,
                onTap: onRowTap == null
                    ? () => onSelectionChanged(key)
                    : () => onRowTap!(rowIndexOffset + index),
                onSelectionChanged: () => onSelectionChanged(key),
              );
            },
          ),
        ),
        MobileDataTableFooter(
          page: page,
          pageCount: pageCount,
          pageSize: pageSize,
          pageSizes: pageSizes,
          totalRows: totalRows,
          onPreviousPage: onPreviousPage,
          onNextPage: onNextPage,
          onPageSizeChanged: onPageSizeChanged,
        ),
      ],
    );
  }
}

class _MobileDataTableCard extends StatelessWidget {
  const _MobileDataTableCard({
    required this.columns,
    required this.row,
    required this.selected,
    required this.onTap,
    required this.onSelectionChanged,
  });

  final List<TrinaColumn> columns;
  final TrinaRow<dynamic> row;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final dashcn.ThemeColors colors = dashcn.Theme.of(context).colors;
    final List<TrinaColumn> visibleColumns = columns
        .where((TrinaColumn column) => row.cells.containsKey(column.field))
        .toList();
    final TrinaColumn? titleColumn = visibleColumns.isEmpty
        ? null
        : visibleColumns.first;
    final List<TrinaColumn> detailColumns = titleColumn == null
        ? const <TrinaColumn>[]
        : visibleColumns.skip(1).toList();

    return Material(
      color: selected ? colors.accent : colors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? colors.primary : colors.border,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: selected
                    ? CheckboxValue.checked
                    : CheckboxValue.unchecked,
                onChanged: (_) => onSelectionChanged(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (titleColumn != null)
                      Text(
                        _cellValue(row, titleColumn),
                        style: dashcn.Theme.of(context).typography.large
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    for (final TrinaColumn column in detailColumns) ...<Widget>[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 86,
                            child: Text(
                              column.title,
                              style: dashcn.Theme.of(context).typography.small
                                  .copyWith(color: colors.mutedForeground),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _cellValue(row, column),
                              style: dashcn.Theme.of(context).typography.small
                                  .copyWith(
                                    color: colors.foreground,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _cellValue(TrinaRow<dynamic> row, TrinaColumn column) =>
      row.cells[column.field]?.value?.toString() ?? '—';
}

class MobileDataTableFooter extends StatelessWidget {
  const MobileDataTableFooter({
    super.key,
    required this.page,
    required this.pageCount,
    required this.pageSize,
    required this.pageSizes,
    required this.totalRows,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onPageSizeChanged,
  });

  final int page;
  final int pageCount;
  final int pageSize;
  final List<int> pageSizes;
  final int totalRows;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final dashcn.ThemeColors colors = dashcn.Theme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          // Text(
          //   '$totalRows items',
          //   style: dashcn.Theme.of(
          //     context,
          //   ).typography.small.copyWith(color: colors.mutedForeground),
          // ),
          // const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              key: const ValueKey<String>('mobile-page-size'),
              value: pageSize,
              isDense: true,
              borderRadius: BorderRadius.circular(12),
              items: pageSizes
                  .map(
                    (int size) => DropdownMenuItem<int>(
                      value: size,
                      child: Text('$size / page'),
                    ),
                  )
                  .toList(),
              onChanged: (int? value) {
                if (value != null) {
                  onPageSizeChanged(value);
                }
              },
            ),
          ),
          const Spacer(),
          Fab(
            semanticLabel: 'Previous page',
            size: FabSize.sm,
            tooltip: 'Previous page',
            onPressed: onPreviousPage,
            icon: const Icon(BootstrapIcons.chevronLeft, size: 18),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$page / $pageCount',
              style: dashcn.Theme.of(context).typography.small.copyWith(
                color: colors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Fab(
            semanticLabel: 'data-table-next-page',
            size: FabSize.sm,
            tooltip: 'Next page',
            onPressed: onNextPage,
            icon: const Icon(BootstrapIcons.chevronRight, size: 18),
          ),
        ],
      ),
    );
  }
}
