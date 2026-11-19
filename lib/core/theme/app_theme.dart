import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;

import 'app_theme_palette.dart';

/// Shared design tokens used by both Material and Cupertino application
/// shells. Feature widgets should read these values from the active theme
/// instead of defining their own spacing, radii, or colors.

abstract final class AppTheme {
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 18;
  static const double radiusPill = 999;

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  static const Duration motionFast = Duration(milliseconds: 150);
  static const Duration motionNormal = Duration(milliseconds: 220);
  static const Duration motionSlow = Duration(milliseconds: 360);

  static material.IconButtonThemeData iconButtonTheme(
    material.ColorScheme scheme,
  ) {
    return material.IconButtonThemeData(
      style: material.IconButton.styleFrom(foregroundColor: scheme.onSurface),
    );
  }

  static material.ButtonStyle filledIconButtonStyle(
    material.ColorScheme scheme,
  ) {
    return material.IconButton.styleFrom(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
      disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
    );
  }

  static material.ButtonStyle filledTonalIconButtonStyle(
    material.ColorScheme scheme,
  ) {
    return material.IconButton.styleFrom(
      backgroundColor: scheme.secondaryContainer,
      foregroundColor: scheme.onSecondaryContainer,
    );
  }

  static material.ButtonStyle outlinedIconButtonStyle(
    material.ColorScheme scheme,
  ) {
    return material.IconButton.styleFrom(
      foregroundColor: scheme.onSurface,
      side: BorderSide(color: scheme.outline),
    );
  }

  static final material.ThemeData lightMaterial = lightMaterialFor();

  static final material.ThemeData darkMaterial = darkMaterialFor();

  static material.ThemeData lightMaterialFor({
    material.Color seedColor = AppThemePalette.defaultColor,
    Map<String, String>? colorTokens,
    double radius = radiusMedium,
    String? fontFamily,
    double? surfaceOpacity,
    double? surfaceBlur,
    material.Color? shadowColor,
    double shadowOpacity = 0.16,
    double shadowBlur = 12,
    AppDensity? density,
  }) {
    return materialFor(
      brightness: material.Brightness.light,
      seedColor: seedColor,
      colorTokens: colorTokens,
      radius: radius,
      fontFamily: fontFamily,
      surfaceOpacity: surfaceOpacity,
      surfaceBlur: surfaceBlur,
      shadowColor: shadowColor,
      shadowOpacity: shadowOpacity,
      shadowBlur: shadowBlur,
      density: density,
    );
  }

  static material.ThemeData darkMaterialFor({
    material.Color seedColor = AppThemePalette.defaultColor,
    Map<String, String>? colorTokens,
    double radius = radiusMedium,
    String? fontFamily,
    double? surfaceOpacity,
    double? surfaceBlur,
    material.Color? shadowColor,
    double shadowOpacity = 0.16,
    double shadowBlur = 12,
    AppDensity? density,
  }) {
    return materialFor(
      brightness: material.Brightness.dark,
      seedColor: seedColor,
      colorTokens: colorTokens,
      radius: radius,
      fontFamily: fontFamily,
      surfaceOpacity: surfaceOpacity,
      surfaceBlur: surfaceBlur,
      shadowColor: shadowColor,
      shadowOpacity: shadowOpacity,
      shadowBlur: shadowBlur,
      density: density,
    );
  }

  static material.ThemeData _buildMaterial(material.Brightness brightness) {
    return materialFor(
      brightness: brightness,
      seedColor: AppThemePalette.defaultColor,
    );
  }

  static material.ThemeData materialFor({
    required material.Brightness brightness,
    material.Color seedColor = AppThemePalette.defaultColor,
    Map<String, String>? colorTokens,
    double radius = radiusMedium,
    String? fontFamily,
    double? surfaceOpacity,
    double? surfaceBlur,
    material.Color? shadowColor,
    double shadowOpacity = 0.16,
    double shadowBlur = 12,
    AppDensity? density,
  }) {
    final effectiveSeed = _colorFromHex(colorTokens?['primary']) ?? seedColor;

    final scheme = _colorScheme(
      seedColor: effectiveSeed,
      brightness: brightness,
      tokens: colorTokens,
    );

    final isDark = brightness == material.Brightness.dark;
    final textTheme = _textTheme(scheme);

    return material.ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      fontFamily: fontFamily == null || fontFamily.isEmpty
          ? 'GeistSans'
          : fontFamily,
      visualDensity: density == null
          ? material.VisualDensity.standard
          : material.VisualDensity(
              horizontal: ((density.baseGap - 12) / 4).clamp(-1.0, 1.0),
              vertical: ((density.baseGap - 12) / 4).clamp(-1.0, 1.0),
            ),

      appBarTheme: material.AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        surfaceTintColor: material.Colors.transparent,
        iconTheme: material.IconThemeData(color: scheme.onSurfaceVariant),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),

      iconTheme: material.IconThemeData(color: scheme.onSurfaceVariant),
      // iconButtonTheme: material.IconButtonThemeData(
      //   style: material.ButtonStyle(
      //     backgroundColor: WidgetStateProperty.resolveWith((states) {
      //       if (states.contains(WidgetState.disabled)) {
      //         return scheme.onSurface.withValues(alpha: 0.12);
      //       }
      //       return scheme.primary;
      //     }),
      //     foregroundColor: WidgetStateProperty.resolveWith((states) {
      //       if (states.contains(WidgetState.disabled)) {
      //         return scheme.onSurface.withValues(alpha: 0.38);
      //       }
      //       return scheme.onPrimary;
      //     }),
      //     overlayColor: WidgetStatePropertyAll(
      //       scheme.onPrimary.withValues(alpha: 0.10),
      //     ),
      //   ),
      // ),
      primaryIconTheme: material.IconThemeData(color: scheme.primary),

      inputDecorationTheme: material.InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: isDark ? scheme.surfaceContainerHighest : scheme.surface,
        border: _outline(scheme.outline),
        enabledBorder: _outline(scheme.outlineVariant),
        focusedBorder: _outline(scheme.primary, width: 2),
        errorBorder: _outline(scheme.error),
        focusedErrorBorder: _outline(scheme.error, width: 2),
        contentPadding: const material.EdgeInsets.symmetric(
          horizontal: spaceMd,
          vertical: 14,
        ),
      ),

      cardTheme: material.CardThemeData(
        color: scheme.surfaceContainerLow,
        margin: material.EdgeInsets.zero,
        elevation: isDark ? 1 : 0,
        shadowColor: (shadowColor ?? scheme.shadow).withValues(
          alpha: shadowOpacity,
        ),
        surfaceTintColor: material.Colors.transparent,
        shape: material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.all(
            material.Radius.circular(radius),
          ),
          side: material.BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
      ),

      filledButtonTheme: material.FilledButtonThemeData(
        style: material.FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const material.Size(0, 44),
          padding: const material.EdgeInsets.symmetric(horizontal: spaceMd),
          shape: material.RoundedRectangleBorder(
            borderRadius: material.BorderRadius.all(
              material.Radius.circular(radius),
            ),
          ),
        ),
      ),

      outlinedButtonTheme: material.OutlinedButtonThemeData(
        style: material.OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const material.Size(0, 44),
          side: material.BorderSide(color: scheme.outline),
          shape: material.RoundedRectangleBorder(
            borderRadius: material.BorderRadius.all(
              material.Radius.circular(radius),
            ),
          ),
        ),
      ),

      textButtonTheme: material.TextButtonThemeData(
        style: material.TextButton.styleFrom(
          foregroundColor: scheme.primary,
          shape: material.RoundedRectangleBorder(
            borderRadius: material.BorderRadius.all(
              material.Radius.circular(radius),
            ),
          ),
        ),
      ),

      chipTheme: material.ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.secondaryContainer,
        side: material.BorderSide(color: scheme.outlineVariant),
        shape: material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.all(
            material.Radius.circular(radius),
          ),
        ),
      ),

      navigationRailTheme: material.NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        selectedIconTheme: material.IconThemeData(color: scheme.primary),
        unselectedIconTheme: material.IconThemeData(
          color: scheme.onSurfaceVariant,
        ),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.primary,
          fontWeight: material.FontWeight.w700,
        ),
      ),

      navigationBarTheme: material.NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        elevation: 0,
      ),

      navigationDrawerTheme: material.NavigationDrawerThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
      ),

      dividerTheme: material.DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),

      dialogTheme: material.DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: material.Colors.transparent,
        shape: material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.all(
            material.Radius.circular(radius),
          ),
        ),
      ),

      snackBarTheme: material.SnackBarThemeData(
        behavior: material.SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.all(
            material.Radius.circular(radius),
          ),
        ),
      ),

      progressIndicatorTheme: material.ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),

      floatingActionButtonTheme: material.FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
      ),

      tooltipTheme: material.TooltipThemeData(
        decoration: material.BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: material.BorderRadius.circular(radiusSmall),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onInverseSurface,
        ),
      ),

      extensions: [
        AppThemeExtension.fromScheme(
          scheme,
          dark: isDark,
          surfaceOpacity: surfaceOpacity,
          surfaceBlur: surfaceBlur,
          shadowColor: shadowColor ?? scheme.shadow,
          shadowBlur: shadowBlur,
        ),
      ],
    );
  }

  static material.ColorScheme _colorScheme({
    required material.Color seedColor,
    required material.Brightness brightness,
    Map<String, String>? tokens,
  }) {
    final base = material.ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    material.Color? color(String key) => _colorFromHex(tokens?[key]);

    return base.copyWith(
      primary: color('primary'),
      onPrimary: color('primaryForeground'),
      secondary: color('secondary'),
      onSecondary: color('secondaryForeground'),
      surface: color('background') ?? color('card'),
      onSurface: color('foreground'),
      surfaceContainerHighest: color('muted') ?? color('card'),
      surfaceContainerLow: color('background'),
      surfaceContainer: color('card'),
      onSurfaceVariant: color('mutedForeground'),
      outline: color('border'),
      error: color('destructive'),
      onError: color('destructiveForeground'),
    );
  }

  static material.Color? _colorFromHex(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final normalized = value.replaceFirst('#', '').trim();

    if (!RegExp(r'^(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(normalized)) {
      return null;
    }

    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;

    return material.Color(int.parse(hex, radix: 16));
  }

  static material.TextTheme _textTheme(material.ColorScheme scheme) {
    return material.TextTheme(
      displayLarge: const material.TextStyle(
        fontSize: 36,
        fontWeight: material.FontWeight.w800,
      ),
      displayMedium: const material.TextStyle(
        fontSize: 30,
        fontWeight: material.FontWeight.w800,
      ),
      headlineLarge: const material.TextStyle(
        fontSize: 26,
        fontWeight: material.FontWeight.w700,
      ),
      headlineMedium: const material.TextStyle(
        fontSize: 22,
        fontWeight: material.FontWeight.w700,
      ),
      titleLarge: const material.TextStyle(
        fontSize: 20,
        fontWeight: material.FontWeight.w700,
      ),
      titleMedium: const material.TextStyle(
        fontSize: 16,
        fontWeight: material.FontWeight.w600,
      ),
      bodyLarge: material.TextStyle(fontSize: 16, color: scheme.onSurface),
      bodyMedium: material.TextStyle(fontSize: 14, color: scheme.onSurface),
      bodySmall: material.TextStyle(
        fontSize: 12,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: const material.TextStyle(
        fontSize: 14,
        fontWeight: material.FontWeight.w700,
      ),
      labelMedium: const material.TextStyle(
        fontSize: 12,
        fontWeight: material.FontWeight.w600,
      ),
    );
  }

  static material.OutlineInputBorder _outline(
    material.Color color, {
    double width = 1,
  }) {
    return material.OutlineInputBorder(
      borderRadius: const material.BorderRadius.all(
        material.Radius.circular(radiusSmall),
      ),
      borderSide: material.BorderSide(color: color, width: width),
    );
  }

  static CupertinoThemeData cupertino(
    material.Brightness brightness, {
    material.Color seedColor = AppThemePalette.defaultColor,
    Map<String, String>? colorTokens,
    String? fontFamily,
  }) {
    final effectiveSeed = _colorFromHex(colorTokens?['primary']) ?? seedColor;

    final scheme = _colorScheme(
      seedColor: effectiveSeed,
      brightness: brightness,
      tokens: colorTokens,
    );

    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: scheme.primary,
      scaffoldBackgroundColor: scheme.surface,
      barBackgroundColor: scheme.surface.withValues(alpha: 0.94),
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 16,
          fontFamily: fontFamily ?? 'GeistSans',
        ),
        navTitleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          fontFamily: fontFamily ?? 'GeistSans',
        ),
      ),
    );
  }

  static material.ThemeMode materialMode(Object value) {
    return switch (_name(value)) {
      'light' => material.ThemeMode.light,
      'system' => material.ThemeMode.system,
      _ => material.ThemeMode.dark,
    };
  }

  static material.Brightness brightness(Object value) {
    final mode = materialMode(value);

    if (mode == material.ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }

    return mode == material.ThemeMode.dark
        ? material.Brightness.dark
        : material.Brightness.light;
  }

  static String colorHex(material.Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2).toUpperCase()}';
  }

  static String _name(Object value) =>
      value.toString().split('.').last.toLowerCase();
}

@immutable
class AppDensity {
  const AppDensity({
    required this.baseContainerPadding,
    required this.baseGap,
    required this.baseContentPadding,
  });

  final double baseContainerPadding;
  final double baseGap;
  final double baseContentPadding;

  static const compact = AppDensity(
    baseContainerPadding: 12,
    baseGap: 6,
    baseContentPadding: 12,
  );
  static const reduced = AppDensity(
    baseContainerPadding: 16,
    baseGap: 8,
    baseContentPadding: 16,
  );
  static const standard = AppDensity(
    baseContainerPadding: 20,
    baseGap: 12,
    baseContentPadding: 20,
  );
  static const spacious = AppDensity(
    baseContainerPadding: 24,
    baseGap: 16,
    baseContentPadding: 24,
  );
}

class AppThemeExtension extends material.ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.backgroundGradient,
    required this.surfaceGradient,
    required this.sidebarGradient,
    required this.appBarGradient,
    required this.cardGradient,
    required this.primaryGradient,
    required this.glassColor,
    required this.overlayColor,
    required this.surfaceOpacity,
    required this.surfaceBlur,
    required this.shadowColor,
    required this.shadowBlur,
  });

  factory AppThemeExtension.fromScheme(
    material.ColorScheme scheme, {
    required bool dark,
    double? surfaceOpacity,
    double? surfaceBlur,
    required material.Color shadowColor,
    required double shadowBlur,
  }) {
    return AppThemeExtension(
      // Main application background.
      backgroundGradient: material.LinearGradient(
        begin: material.Alignment.topLeft,
        end: material.Alignment.bottomRight,
        colors: dark
            ? [scheme.surface, scheme.surfaceContainerHighest]
            : [scheme.surface, scheme.surfaceContainerLow],
      ),

      // Generic surface gradient.
      surfaceGradient: material.LinearGradient(
        begin: material.Alignment.topCenter,
        end: material.Alignment.bottomCenter,
        colors: [scheme.surfaceContainer, scheme.surface],
      ),

      // Sidebar gradient.
      sidebarGradient: material.LinearGradient(
        begin: material.Alignment.topLeft,
        end: material.Alignment.bottomRight,
        colors: dark
            ? [scheme.surface, scheme.surfaceContainerHighest]
            : [scheme.surfaceContainerHighest, scheme.surface],
      ),

      // Top application bar.
      appBarGradient: material.LinearGradient(
        begin: material.Alignment.topCenter,
        end: material.Alignment.bottomCenter,
        colors: [scheme.surface, scheme.surfaceContainerLow],
      ),

      // Card gradient.
      cardGradient: material.LinearGradient(
        begin: material.Alignment.topLeft,
        end: material.Alignment.bottomRight,
        colors: [scheme.surfaceContainer, scheme.surface],
      ),

      // Primary action/highlight gradient.
      primaryGradient: material.LinearGradient(
        begin: material.Alignment.topLeft,
        end: material.Alignment.bottomRight,
        colors: [scheme.primary, scheme.tertiary],
      ),

      glassColor: scheme.surface.withValues(
        alpha: surfaceOpacity ?? (dark ? 0.72 : 0.84),
      ),

      overlayColor: scheme.primary.withValues(alpha: 0.08),

      surfaceOpacity: surfaceOpacity ?? (dark ? 0.72 : 0.84),
      surfaceBlur: surfaceBlur ?? 0,
      shadowColor: shadowColor,
      shadowBlur: shadowBlur,
    );
  }

  final material.LinearGradient backgroundGradient;
  final material.LinearGradient surfaceGradient;
  final material.LinearGradient sidebarGradient;
  final material.LinearGradient appBarGradient;
  final material.LinearGradient cardGradient;
  final material.LinearGradient primaryGradient;

  final material.Color glassColor;
  final material.Color overlayColor;

  final double surfaceOpacity;
  final double surfaceBlur;
  final material.Color shadowColor;
  final double shadowBlur;

  @override
  AppThemeExtension copyWith({
    material.LinearGradient? backgroundGradient,
    material.LinearGradient? surfaceGradient,
    material.LinearGradient? sidebarGradient,
    material.LinearGradient? appBarGradient,
    material.LinearGradient? cardGradient,
    material.LinearGradient? primaryGradient,
    material.Color? glassColor,
    material.Color? overlayColor,
    double? surfaceOpacity,
    double? surfaceBlur,
    material.Color? shadowColor,
    double? shadowBlur,
  }) {
    return AppThemeExtension(
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      surfaceGradient: surfaceGradient ?? this.surfaceGradient,
      sidebarGradient: sidebarGradient ?? this.sidebarGradient,
      appBarGradient: appBarGradient ?? this.appBarGradient,
      cardGradient: cardGradient ?? this.cardGradient,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      glassColor: glassColor ?? this.glassColor,
      overlayColor: overlayColor ?? this.overlayColor,
      surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
      surfaceBlur: surfaceBlur ?? this.surfaceBlur,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlur: shadowBlur ?? this.shadowBlur,
    );
  }

  @override
  AppThemeExtension lerp(covariant AppThemeExtension? other, double t) {
    if (other == null) return this;

    return AppThemeExtension(
      backgroundGradient:
          material.LinearGradient.lerp(
            backgroundGradient,
            other.backgroundGradient,
            t,
          ) ??
          backgroundGradient,

      surfaceGradient:
          material.LinearGradient.lerp(
            surfaceGradient,
            other.surfaceGradient,
            t,
          ) ??
          surfaceGradient,

      sidebarGradient:
          material.LinearGradient.lerp(
            sidebarGradient,
            other.sidebarGradient,
            t,
          ) ??
          sidebarGradient,

      appBarGradient:
          material.LinearGradient.lerp(
            appBarGradient,
            other.appBarGradient,
            t,
          ) ??
          appBarGradient,

      cardGradient:
          material.LinearGradient.lerp(cardGradient, other.cardGradient, t) ??
          cardGradient,

      primaryGradient:
          material.LinearGradient.lerp(
            primaryGradient,
            other.primaryGradient,
            t,
          ) ??
          primaryGradient,

      glassColor:
          material.Color.lerp(glassColor, other.glassColor, t) ?? glassColor,

      overlayColor:
          material.Color.lerp(overlayColor, other.overlayColor, t) ??
          overlayColor,

      surfaceOpacity:
          ui.lerpDouble(surfaceOpacity, other.surfaceOpacity, t) ??
          surfaceOpacity,

      surfaceBlur:
          ui.lerpDouble(surfaceBlur, other.surfaceBlur, t) ?? surfaceBlur,

      shadowColor:
          material.Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,

      shadowBlur: ui.lerpDouble(shadowBlur, other.shadowBlur, t) ?? shadowBlur,
    );
  }
}
