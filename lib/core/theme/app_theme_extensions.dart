import 'dart:ui' as ui;
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;

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
