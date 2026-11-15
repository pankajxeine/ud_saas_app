import 'package:flutter/widgets.dart';

import '../models/field_meta.dart';

class EntityFormLayout extends StatelessWidget {
  const EntityFormLayout({
    super.key,
    required this.fields,
    required this.itemBuilder,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 4,
  });

  final List<FieldMeta<dynamic>> fields;

  final Widget Function(BuildContext context, FieldMeta<dynamic> field)
  itemBuilder;

  final double spacing;
  final double runSpacing;

  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final config = _resolveLayout(width);

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: fields.map((field) {
            final span = _resolveSpan(field, config.columns, config.breakpoint);

            final itemWidth =
                ((width - (config.columns - 1) * spacing) / config.columns) *
                    span +
                spacing * (span - 1);

            return SizedBox(
              width: itemWidth,
              child: itemBuilder(context, field),
            );
          }).toList(),
        );
      },
    );
  }

  _LayoutConfig _resolveLayout(double width) {
    if (width >= 1024) {
      return _LayoutConfig(
        columns: desktopColumns,
        breakpoint: _Breakpoint.desktop,
      );
    }

    if (width >= 600) {
      return _LayoutConfig(
        columns: tabletColumns,
        breakpoint: _Breakpoint.tablet,
      );
    }

    return _LayoutConfig(
      columns: mobileColumns,
      breakpoint: _Breakpoint.mobile,
    );
  }

  int _resolveSpan(
    FieldMeta<dynamic> field,
    int columns,
    _Breakpoint breakpoint,
  ) {
    // Adapt this to your existing field.layout model.
    //
    // Expected:
    // field.layout.mobileColSpan
    // field.layout.tabletColSpan
    // field.layout.desktopColSpan

    final int span;

    switch (breakpoint) {
      case _Breakpoint.mobile:
        span = field.layout?.mobileColSpan ?? 1;

      case _Breakpoint.tablet:
        span = field.layout?.tabletColSpan ?? 1;

      case _Breakpoint.desktop:
        span = field.layout?.desktopColSpan ?? 1;
    }

    return span.clamp(1, columns);
  }
}

enum _Breakpoint { mobile, tablet, desktop }

class _LayoutConfig {
  const _LayoutConfig({required this.columns, required this.breakpoint});

  final int columns;
  final _Breakpoint breakpoint;
}
