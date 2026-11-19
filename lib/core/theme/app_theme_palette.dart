import 'package:flutter/material.dart';

class AppThemePalette {
  final String id;
  final String name;
  final Color color;

  const AppThemePalette({
    required this.id,
    required this.name,
    required this.color,
  });

  static const Color defaultColor = Color(0xFF4F46E5);
  static const List<AppThemePalette> presets = [
    AppThemePalette(id: 'indigo', name: 'Indigo', color: Color(0xFF4F46E5)),
    AppThemePalette(id: 'blue', name: 'Blue', color: Color(0xFF2563EB)),
    AppThemePalette(id: 'sky', name: 'Sky', color: Color(0xFF0284C7)),
    AppThemePalette(id: 'cyan', name: 'Cyan', color: Color(0xFF0891B2)),
    AppThemePalette(id: 'teal', name: 'Teal', color: Color(0xFF0D9488)),
    AppThemePalette(id: 'green', name: 'Green', color: Color(0xFF16A34A)),
    AppThemePalette(id: 'lime', name: 'Lime', color: Color(0xFF65A30D)),
    AppThemePalette(id: 'amber', name: 'Amber', color: Color(0xFFD97706)),
    AppThemePalette(id: 'orange', name: 'Orange', color: Color(0xFFEA580C)),
    AppThemePalette(id: 'red', name: 'Red', color: Color(0xFFDC2626)),
    AppThemePalette(id: 'rose', name: 'Rose', color: Color(0xFFE11D48)),
    AppThemePalette(id: 'pink', name: 'Pink', color: Color(0xFFDB2777)),
    AppThemePalette(id: 'purple', name: 'Purple', color: Color(0xFF9333EA)),
    AppThemePalette(id: 'violet', name: 'Violet', color: Color(0xFF7C3AED)),
    AppThemePalette(id: 'slate', name: 'Slate', color: Color(0xFF475569)),
    AppThemePalette(id: 'neutral', name: 'Neutral', color: Color(0xFF525252)),
  ];

  static Color fromHex(String value) {
    final hex = value.replaceAll('#', '').trim();

    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) {
      throw const FormatException('Invalid HEX color');
    }

    return Color(int.parse('FF$hex', radix: 16));
  }

  static String toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  static AppThemePalette? findById(String id) {
    for (final palette in presets) {
      if (palette.id == id) return palette;
    }
    return null;
  }

  static AppThemePalette? findByColor(Color color) {
    for (final palette in presets) {
      if (palette.color.toARGB32() == color.toARGB32()) {
        return palette;
      }
    }
    return null;
  }

  static Color parseHex(String value) {
    final normalized = value.replaceAll('#', '').trim();

    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(normalized)) {
      throw const FormatException('Invalid HEX color');
    }

    return Color(int.parse('FF$normalized', radix: 16));
  }
}
