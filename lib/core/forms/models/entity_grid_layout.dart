import 'package:flutter/foundation.dart';

/// Responsive layout breakpoints used by [EntityReactiveForm].
enum EntityBreakpoint { mobile, tablet, desktop }

/// Layout overrides stored on an individual field's metadata.
///
/// A null column span means the field uses the default span of one column.
/// [minHeight] is a minimum height in logical pixels, not a row span.
///
/// Example JSON:
///
/// {
///   "mobileColSpan": 1,
///   "tabletColSpan": 2,
///   "desktopColSpan": 2,
///   "minHeight": 100
/// }
@immutable
class FieldLayoutMeta {
  const FieldLayoutMeta({
    this.mobileColSpan,
    this.tabletColSpan,
    this.desktopColSpan,
    this.minHeight,
  });

  final int? mobileColSpan;
  final int? tabletColSpan;
  final int? desktopColSpan;
  final double? minHeight;

  int columnSpanFor(EntityBreakpoint breakpoint) {
    final configuredSpan = switch (breakpoint) {
      EntityBreakpoint.mobile => mobileColSpan,
      EntityBreakpoint.tablet => tabletColSpan,
      EntityBreakpoint.desktop => desktopColSpan,
    };

    if (configuredSpan == null || configuredSpan < 1) {
      return 1;
    }

    return configuredSpan;
  }

  factory FieldLayoutMeta.fromJson(Map<String, dynamic> json) {
    return FieldLayoutMeta(
      mobileColSpan: _readInt(json['mobileColSpan']),
      tabletColSpan: _readInt(json['tabletColSpan']),
      desktopColSpan: _readInt(json['desktopColSpan']),
      minHeight: _readDouble(json['minHeight']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (mobileColSpan != null) 'mobileColSpan': mobileColSpan,
      if (tabletColSpan != null) 'tabletColSpan': tabletColSpan,
      if (desktopColSpan != null) 'desktopColSpan': desktopColSpan,
      if (minHeight != null) 'minHeight': minHeight,
    };
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _readDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

/// Responsive configuration for the Wrap-based form layout.
///
/// Fields are laid out in reading order, from left to right and then
/// onto the next run. This layout intentionally does not expose rowSpan
/// or explicit row/column coordinates because Wrap cannot guarantee them.
@immutable
class EntityGridLayout {
  const EntityGridLayout({
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 4,
    this.mobileBreakpoint = 600,
    this.desktopBreakpoint = 1024,
    this.horizontalSpacing = 16,
    this.verticalSpacing = 16,
  }) : assert(mobileColumns >= 1),
       assert(tabletColumns >= 1),
       assert(desktopColumns >= 1),
       assert(mobileBreakpoint > 0),
       assert(desktopBreakpoint > mobileBreakpoint),
       assert(horizontalSpacing >= 0),
       assert(verticalSpacing >= 0);

  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;

  /// Width below which the mobile column configuration is selected.
  final double mobileBreakpoint;

  /// Width at which the desktop column configuration starts.
  final double desktopBreakpoint;

  final double horizontalSpacing;
  final double verticalSpacing;

  static const EntityGridLayout standard = EntityGridLayout();

  EntityBreakpoint breakpointFor(double width) {
    if (width < mobileBreakpoint) {
      return EntityBreakpoint.mobile;
    }
    if (width < desktopBreakpoint) {
      return EntityBreakpoint.tablet;
    }
    return EntityBreakpoint.desktop;
  }

  int columnsFor(double width) {
    return switch (breakpointFor(width)) {
      EntityBreakpoint.mobile => mobileColumns,
      EntityBreakpoint.tablet => tabletColumns,
      EntityBreakpoint.desktop => desktopColumns,
    };
  }

  /// Resolves a field's requested span and clamps it to the current grid.
  int resolveColumnSpan({
    required FieldLayoutMeta? fieldLayout,
    required EntityBreakpoint breakpoint,
    required int columns,
  }) {
    final safeColumns = columns < 1 ? 1 : columns;
    final requestedSpan = fieldLayout?.columnSpanFor(breakpoint) ?? 1;

    return requestedSpan.clamp(1, safeColumns).toInt();
  }

  /// Returns the configured minimum height, or zero when not configured.
  double resolveMinHeight(FieldLayoutMeta? fieldLayout) {
    final value = fieldLayout?.minHeight;
    if (value == null || !value.isFinite || value <= 0) {
      return 0;
    }
    return value;
  }
}
