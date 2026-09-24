import 'package:trina_grid/trina_grid.dart';
import 'package:ud_sass_app/ui/shadcn/components/control/button/button.dart';
import 'package:ud_sass_app/ui/shadcn/components/layout/flex/flex.dart';
import 'package:ud_sass_app/ui/shadcn/shared/icons/bootstrap_icons.dart';
import 'package:ud_sass_app/ui/shadcn/shared/theme/theme.dart';

export 'package:trina_grid/trina_grid.dart'
    show
        TrinaColumn,
        TrinaColumnType,
        TrinaColumnTextAlign,
        TrinaRow,
        TrinaCell,
        TrinaGridStateManager;

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
class DataTable extends StatelessWidget {
  const DataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onLoaded,
    this.onRowTap,
    this.rowActionIcon = BootstrapIcons.arrowsMove,
    this.rowActionTooltip = 'Open',
    this.pageSize = 25,
    this.paginate = true,
  });

  final List<TrinaColumn> columns;
  final List<TrinaRow<dynamic>> rows;
  final void Function(TrinaGridStateManager)? onLoaded;

  /// Opens the row. Rendered as an explicit trailing action column, because
  /// double-tap is undiscoverable and, on desktop, trina_grid detects it with
  /// a manual timing window that is easy to miss. Double-tap still works as a
  /// shortcut for anyone who tries it.
  final void Function(int rowIdx)? onRowTap;

  final IconData rowActionIcon;
  final String rowActionTooltip;
  final int pageSize;
  final bool paginate;

  void handleOnRowChecked(TrinaGridOnRowCheckedEvent event) {
    if (event.isRow) {
      // or event.isAll
      print('Toggled A Row.');
      print(event.row?.cells['column1']?.value);
    } else {
      print('Toggled All Rows.');
      // print(stateManager.checkedRows.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).typography;

    return ClipRRect(
      borderRadius: AppRadius.allMd,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: c.border),
          borderRadius: AppRadius.allMd,
        ),
        child: TrinaGrid(
          columns: [
            ...columns,
            if (onRowTap != null)
              TrinaColumn(
                title: '',
                field: '_actions',
                width: 64,
                minWidth: 64,
                readOnly: true,
                enableSorting: false,
                enableColumnDrag: false,
                enableContextMenu: false,
                enableDropToResize: false,
                textAlign: TrinaColumnTextAlign.center,
                type: TrinaColumnType.text(),
                renderer: (ctx) => Center(
                  child: IconButton.outline(
                    icon: Icon(rowActionIcon, size: 16),
                    // tooltip: rowActionTooltip,
                    // color: c.mutedForeground,
                    // splashRadius: 16,
                    // visualDensity: VisualDensity.compact,
                    onPressed: () => onRowTap!(ctx.rowIdx),
                  ),
                ),
              ),
          ],
          rows: [
            for (final row in rows)
              if (onRowTap == null)
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
            if (paginate) e.stateManager.setPageSize(pageSize, notify: false);
            onLoaded?.call(e.stateManager);
          },
          onRowChecked: handleOnRowChecked,
          createFooter: paginate
              ? (TrinaGridStateManager sm) => PaginationFooter(stateManager: sm)
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
}
