/// The active responsive breakpoint for the form.
enum EntityBreakpoint { mobile, tablet, desktop }

/// Layout configuration for an individual field.
///
/// This is field-level metadata. It overrides the default one-column
/// placement at the selected breakpoint.
///
/// Example:
///
/// {
///   "layout": {
///     "mobileColSpan": 1,
///     "tabletColSpan": 2,
///     "desktopColSpan": 2,
///     "minHeight": 100
///   }
/// }
///
/// A null span means: use the default span of 1.
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

  /// Minimum height in logical pixels.
  ///
  /// Useful for textareas, JSON editors, and custom fields.
  /// The field can grow beyond this height when its content requires it.
  final double? minHeight;

  /// Returns the configured column span for the active breakpoint.
  ///
  /// A missing or invalid span defaults to 1.
  int columnSpanFor(EntityBreakpoint breakpoint) {
    final span = switch (breakpoint) {
      EntityBreakpoint.mobile => mobileColSpan,
      EntityBreakpoint.tablet => tabletColSpan,
      EntityBreakpoint.desktop => desktopColSpan,
    };

    if (span == null || span < 1) {
      return 1;
    }

    return span;
  }

  /// Creates layout metadata from a JSON map.
  factory FieldLayoutMeta.fromJson(Map<String, dynamic> json) {
    return FieldLayoutMeta(
      mobileColSpan: _toInt(json['mobileColSpan']),
      tabletColSpan: _toInt(json['tabletColSpan']),
      desktopColSpan: _toInt(json['desktopColSpan']),
      minHeight: _toDouble(json['minHeight']),
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

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

/// Responsive grid configuration for EntityReactiveForm.
///
/// The layout engine uses Wrap, so fields flow automatically from
/// left to right and then onto the next line.
///
/// Example:
///
/// EntityGridLayout(
///   mobileColumns: 1,
///   tabletColumns: 2,
///   desktopColumns: 4,
///   mobileBreakpoint: 600,
///   desktopBreakpoint: 1024,
///   horizontalSpacing: 16,
///   verticalSpacing: 16,
/// )
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

  /// Number of columns on small screens.
  final int mobileColumns;

  /// Number of columns on medium screens.
  final int tabletColumns;

  /// Number of columns on large screens.
  final int desktopColumns;

  /// Width below which the mobile layout is used.
  final double mobileBreakpoint;

  /// Width below which the tablet layout is used.
  ///
  /// At or above this width, the desktop layout is used.
  final double desktopBreakpoint;

  /// Horizontal space between fields.
  final double horizontalSpacing;

  /// Vertical space between fields.
  final double verticalSpacing;

  /// Default layout configuration.
  static const EntityGridLayout standard = EntityGridLayout();

  /// Determines the active breakpoint from the available width.
  EntityBreakpoint breakpointFor(double width) {
    if (width < mobileBreakpoint) {
      return EntityBreakpoint.mobile;
    }

    if (width < desktopBreakpoint) {
      return EntityBreakpoint.tablet;
    }

    return EntityBreakpoint.desktop;
  }

  /// Returns the number of columns for the active breakpoint.
  int columnsFor(double width) {
    final breakpoint = breakpointFor(width);

    return switch (breakpoint) {
      EntityBreakpoint.mobile => mobileColumns,
      EntityBreakpoint.tablet => tabletColumns,
      EntityBreakpoint.desktop => desktopColumns,
    };
  }

  /// Resolves the final column span for a field.
  ///
  /// The field span is always restricted to the available column count.
  int resolveColumnSpan({
    required FieldLayoutMeta? fieldLayout,
    required EntityBreakpoint breakpoint,
    required int columns,
  }) {
    final requestedSpan = fieldLayout?.columnSpanFor(breakpoint) ?? 1;

    return requestedSpan.clamp(1, columns).toInt();
  }

  /// Resolves the minimum height for a field.
  double resolveMinHeight(FieldLayoutMeta? fieldLayout) {
    final height = fieldLayout?.minHeight;

    if (height == null || height <= 0) {
      return 0;
    }

    return height;
  }
}
