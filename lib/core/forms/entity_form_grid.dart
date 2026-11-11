// import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'entity_meta.dart';

class EntityFormGridItem {
  const EntityFormGridItem({required this.field, required this.child});

  final FieldMeta<dynamic> field;
  final Widget child;
}

class EntityFormGrid extends StatelessWidget {
  const EntityFormGrid({
    super.key,
    required this.items,
    this.columnSpacing = 16,
    this.rowSpacing = 16,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 900,
    this.desktopBreakpoint = 1200,
    this.maxColumns = 12,
  });

  final List<EntityFormGridItem> items;

  final double columnSpacing;
  final double rowSpacing;

  final double mobileBreakpoint;
  final double tabletBreakpoint;
  final double desktopBreakpoint;

  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (!width.isFinite || width <= 0) {
          return const SizedBox.shrink();
        }

        final breakpoint = _breakpointFor(width);

        return StaggeredGrid.count(
          crossAxisCount: maxColumns,
          crossAxisSpacing: columnSpacing,
          mainAxisSpacing: rowSpacing,
          children: items.map((item) {
            final colSpan = item.field.colSpan
                .forBreakpoint(breakpoint)
                .clamp(1, maxColumns);

            final rowSpan = item.field.rowSpan
                .forBreakpoint(breakpoint)
                .clamp(1, 100);

            return StaggeredGridTile.count(
              crossAxisCellCount: colSpan,
              mainAxisCellCount: rowSpan.toDouble(),
              child: item.child,
            );
          }).toList(),
        );
      },
    );
  }

  EntityBreakpoint _breakpointFor(double width) {
    if (width < mobileBreakpoint) {
      return EntityBreakpoint.mobile;
    }

    if (width < tabletBreakpoint) {
      return EntityBreakpoint.tablet;
    }

    if (width < desktopBreakpoint) {
      return EntityBreakpoint.desktop;
    }

    return EntityBreakpoint.largeDesktop;
  }
}
