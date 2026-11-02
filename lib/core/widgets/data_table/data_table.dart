import 'package:flutter/material.dart' hide IconButton, Theme;
import 'package:trina_grid/trina_grid.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';

import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/bootstrap_icons.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';

export 'package:trina_grid/trina_grid.dart'
    show
        TrinaColumn,
        TrinaColumnType,
        TrinaColumnTextAlign,
        TrinaRow,
        TrinaCell,
        TrinaGridStateManager;
export 'data_table_header.dart' show DataTableHeader;
export 'mobile_data_table.dart' show MobileDataTableView, MobileDataTableFooter;

import 'data_table_header.dart';
import 'mobile_data_table.dart';
import 'pagination_footer.dart';

abstract final class AppRadius {
  static const Radius sm = Radius.circular(6);
  static const Radius md = Radius.circular(8);
  static const Radius lg = Radius.circular(12);

  static const BorderRadius allSm = BorderRadius.all(sm);
  static const BorderRadius allMd = BorderRadius.all(md);
  static const BorderRadius allLg = BorderRadius.all(lg);
}

/// The themed data grid.
///
/// Spike B found that `trina_grid` does **not** inherit the shadcn theme even
/// though it depends on `shadcn_ui`: it ships its own hamburger column
/// affordances, a bright-blue pagination footer that clashes with the slate
/// palette, and columns that leave a dead zone rather than filling the width.
///
/// This widget is where that is fixed, once, for every screen. It is also the
/// clearest argument for the wrapper layer existing at all — the theming has to
/// live somewhere, and this keeps it out of twenty-two feature files.
class DataTable extends StatefulWidget {
  const DataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.title,
    this.subtitle,
    this.headerActionsBuilder,
    this.onLoaded,
    this.onRowTap,
    this.onRowEdit,
    this.rowActionIcon = BootstrapIcons.eye,
    this.rowActionTooltip = 'Open',
    this.pageSize = 25,
    this.paginate = true,
    this.mobilePageSize = 10,
    this.mobilePageSizes = const <int>[5, 10, 20, 50],
    this.mobileRowKey,
    this.onMobileSelectionChanged,
    this.mobileBreakpoint = 640,
    this.customHeader,
  });

  final List<TrinaColumn> columns;
  final List<TrinaRow<dynamic>> rows;
  final String? title;
  final String? subtitle;
  final Widget Function(BuildContext context, bool compact)?
  headerActionsBuilder;
  final void Function(TrinaGridStateManager)? onLoaded;
  final Widget? customHeader;

  /// Opens the row. Rendered as an explicit trailing action column, because
  /// double-tap is undiscoverable and, on desktop, trina_grid detects it with
  /// a manual timing window that is easy to miss. Double-tap still works as a
  /// shortcut for anyone who tries it.
  final void Function(int rowIdx)? onRowTap;
  final void Function(int rowIdx)? onRowEdit;

  final IconData rowActionIcon;
  final String rowActionTooltip;
  final int pageSize;
  final bool paginate;
  final int mobilePageSize;
  final List<int> mobilePageSizes;
  final String Function(TrinaRow<dynamic> row)? mobileRowKey;
  final ValueChanged<Set<String>>? onMobileSelectionChanged;
  final double mobileBreakpoint;

  @override
  State<DataTable> createState() => _DataTableState();
}

class _DataTableState extends State<DataTable> {
  int _mobilePage = 1;
  late int _mobilePageSize = widget.mobilePageSize;
  final Set<String> _selectedMobileRows = <String>{};

  @override
  void didUpdateWidget(covariant DataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mobilePageSize != oldWidget.mobilePageSize) {
      _mobilePageSize = widget.mobilePageSize;
      _mobilePage = 1;
    }
    _mobilePage = _mobilePage.clamp(1, _mobilePageCount).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < widget.mobileBreakpoint;
        final bool hasHeader =
            widget.customHeader != null ||
            widget.title != null ||
            widget.subtitle != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (!compact && hasHeader) ...<Widget>[
              _header(context, constraints, includeActions: false),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: compact
                  ? _buildMobileView(_header(context, constraints))
                  : _buildDesktopGrid(context),
            ),
          ],
        );
      },
    );
  }

  int get _mobilePageCount =>
      widget.rows.isEmpty ? 1 : (widget.rows.length / _mobilePageSize).ceil();

  List<TrinaRow<dynamic>> get _mobileRows {
    final int page = _mobilePage.clamp(1, _mobilePageCount).toInt();
    final int start = (page - 1) * _mobilePageSize;
    return widget.rows.skip(start).take(_mobilePageSize).toList();
  }

  String _rowKey(TrinaRow<dynamic> row) {
    final String Function(TrinaRow<dynamic>)? keyBuilder = widget.mobileRowKey;
    if (keyBuilder != null) {
      return keyBuilder(row);
    }
    if (widget.columns.isNotEmpty) {
      final Object? value = row.cells[widget.columns.first.field]?.value;
      if (value != null) {
        return value.toString();
      }
    }
    return identityHashCode(row).toString();
  }

  void _toggleRowSelection(String key) {
    setState(() {
      if (!_selectedMobileRows.add(key)) {
        _selectedMobileRows.remove(key);
      }
    });
    widget.onMobileSelectionChanged?.call(
      Set<String>.unmodifiable(_selectedMobileRows),
    );
  }

  void _toggleVisibleSelection() {
    final List<String> visibleKeys = _mobileRows.map(_rowKey).toList();
    final bool allSelected =
        visibleKeys.isNotEmpty &&
        visibleKeys.every(_selectedMobileRows.contains);
    setState(() {
      if (allSelected) {
        _selectedMobileRows.removeAll(visibleKeys);
      } else {
        _selectedMobileRows.addAll(visibleKeys);
      }
    });
    widget.onMobileSelectionChanged?.call(
      Set<String>.unmodifiable(_selectedMobileRows),
    );
  }

  Widget _buildMobileView(Widget header) => MobileDataTableView(
    title: widget.title,
    columns: widget.columns,
    rows: _mobileRows,
    header: header,
    selectedRowKeys: _selectedMobileRows,
    rowKey: _rowKey,
    onSelectionChanged: _toggleRowSelection,
    onSelectVisible: _toggleVisibleSelection,
    page: _mobilePage.clamp(1, _mobilePageCount).toInt(),
    pageCount: _mobilePageCount,
    pageSize: _mobilePageSize,
    pageSizes: <int>{
      ...widget.mobilePageSizes.where((int size) => size > 0),
      _mobilePageSize,
    }.toList()..sort(),
    totalRows: widget.rows.length,
    onPreviousPage: _mobilePage > 1
        ? () => setState(() => _mobilePage--)
        : null,
    onNextPage: _mobilePage < _mobilePageCount
        ? () => setState(() => _mobilePage++)
        : null,
    onPageSizeChanged: (int value) {
      setState(() {
        _mobilePageSize = value;
        _mobilePage = 1;
      });
    },
    onRowTap: widget.onRowTap,
    rowIndexOffset: (_mobilePage - 1) * _mobilePageSize,
  );

  Widget _buildDesktopGrid(BuildContext context) {
    final c = Theme.of(context).colors;
    final t = Theme.of(context).typography;
    final bool hasFilterableColumns = widget.columns.any(
      (TrinaColumn column) => !column.hide && column.filterWidgetDelegate != null,
    );
    final bool hasHeaderActions = widget.headerActionsBuilder != null;
    return ClipRRect(
      borderRadius: AppRadius.allMd,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: c.border),
          borderRadius: AppRadius.allMd,
        ),
        child: TrinaGrid(
          columns: [
            ...widget.columns,
            if (widget.onRowTap != null || widget.onRowEdit != null)
              TrinaColumn(
                title: '',
                field: '_actions',
                width: widget.onRowTap != null && widget.onRowEdit != null
                    ? 104
                    : 64,
                minWidth: widget.onRowTap != null && widget.onRowEdit != null
                    ? 104
                    : 64,
                readOnly: true,
                enableSorting: false,
                enableColumnDrag: false,
                enableContextMenu: false,
                enableDropToResize: false,
                textAlign: TrinaColumnTextAlign.center,
                type: TrinaColumnType.text(),
                renderer: (ctx) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.onRowTap != null)
                      Tooltip(
                        message: widget.rowActionTooltip,
                        child: Button(
                          size: ButtonSize.icon,
                          variant: ButtonVariant.ghost,
                          onPressed: () => widget.onRowTap!(ctx.rowIdx),
                          child: Icon(widget.rowActionIcon, size: 16),
                        ),
                      ),
                    if (widget.onRowEdit != null)
                      Tooltip(
                        message: 'Edit',
                        child: Button(
                          variant: ButtonVariant.ghost,
                          onPressed: () => widget.onRowEdit!(ctx.rowIdx),
                          size: ButtonSize.icon,
                          child: const Icon(BootstrapIcons.pencil, size: 16),
                        ),
                      ),
                  ],
                ),
              ),
          ],
          rows: [
            for (final row in widget.rows)
              if (widget.onRowTap == null && widget.onRowEdit == null)
                row
              else
                TrinaRow(
                  cells: {
                    ...row.cells,
                    '_actions': TrinaCell(value: ''),
                  },
                ),
          ],
          onLoaded: (TrinaGridOnLoadedEvent e) {
            if (widget.paginate) {
              e.stateManager.setPageSize(widget.pageSize, notify: false);
            }
            widget.onLoaded?.call(e.stateManager);
          },
          createFooter: widget.paginate
              ? (TrinaGridStateManager sm) => PaginationFooter(stateManager: sm)
              : null,
          createHeader: hasFilterableColumns || hasHeaderActions
              ? (TrinaGridStateManager stateManager) => SizedBox(
                  height: 52,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (hasHeaderActions)
                            widget.headerActionsBuilder!(context, false),
                          if (hasHeaderActions && hasFilterableColumns)
                            const SizedBox(width: 8),
                          if (hasFilterableColumns)
                            Tooltip(
                              message: 'Toggle filters',
                              child: Button(
                                variant: ButtonVariant.ghost,
                                size: ButtonSize.icon,
                                onPressed: () => stateManager.setShowColumnFilter(
                                  !stateManager.showColumnFilter,
                                ),
                                child: const Icon(
                                  BootstrapIcons.funnel,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
          configuration: TrinaGridConfiguration(
            columnSize: const TrinaGridColumnSizeConfig(
              // Fixes the dead zone: columns scale to fill available width.
              autoSizeMode: TrinaAutoSizeMode.scale,
            ),
            style: TrinaGridStyleConfig(
              enableRowColorAnimation: true,
              // Surfaces
              gridBackgroundColor: c.card,
              rowColor: c.card,
              menuBackgroundColor: c.card,
              cellColorInEditState: c.card,
              cellColorInReadOnlyState: c.muted,

              // Borders — the grid draws its own frame, so suppress the outer
              // one and let the DecoratedBox above own the rounded edge.
              gridBorderColor: const Color.fromRGBO(0, 0, 0, 0),
              borderColor: c.border,
              activatedBorderColor: c.primary,
              inactivatedBorderColor: c.border,
              gridBorderRadius: AppRadius.allMd,
              gridPopupBorderRadius: AppRadius.allMd,
              enableGridBorderShadow: false,
              enableCellBorderVertical: false,

              // Selection and hover in the accent, not lightBlue.
              activatedColor: c.accent,
              rowHoveredColor: c.muted,
              enableRowHoverColor: true,
              columnActiveColor: c.primary,
              cellActiveColor: c.primary,

              // Iconography: `dehaze` is the hamburger Spike B flagged.
              iconColor: c.mutedForeground,
              disabledIconColor: c.border,
              columnContextIcon: BootstrapIcons.threeDots,
              iconSize: 16,

              // Type comes from the shadcn text theme so the grid matches the
              // rest of the page rather than defaulting to black Roboto.
              columnTextStyle: t.small.copyWith(
                color: c.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
              cellTextStyle: t.p.copyWith(color: c.foreground, fontSize: 14),

              rowHeight: 46,
              columnHeight: 44,
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context,
    BoxConstraints constraints, {
    bool includeActions = true,
  }) {
    if (widget.customHeader != null) {
      return widget.customHeader!;
    }

    final bool compact = constraints.maxWidth < widget.mobileBreakpoint;
    return DataTableHeader(
      title: widget.title ?? '',
      subtitle: widget.subtitle,
      actions: includeActions
          ? widget.headerActionsBuilder?.call(context, compact)
          : null,
      compact: compact,
    );
  }
}
