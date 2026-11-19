import 'package:flutter/material.dart';

import 'app_theme_palette.dart';

class ThemeColorPicker extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const ThemeColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  State<ThemeColorPicker> createState() => _ThemeColorPickerState();
}

class _ThemeColorPickerState extends State<ThemeColorPicker> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: AppThemePalette.toHex(widget.selectedColor),
    );
  }

  @override
  void didUpdateWidget(covariant ThemeColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedColor != widget.selectedColor) {
      _controller.text = AppThemePalette.toHex(widget.selectedColor);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectColor(Color color) {
    widget.onColorChanged(color);
    _controller.text = AppThemePalette.toHex(color);
  }

  void _applyHex() {
    try {
      final color = AppThemePalette.fromHex(_controller.text);
      _selectColor(color);
    } on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid HEX color, e.g. #4F46E5')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Theme color', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppThemePalette.presets.map((palette) {
            final selected =
                palette.color.toARGB32() == widget.selectedColor.toARGB32();

            return Tooltip(
              message: palette.name,
              child: InkWell(
                onTap: () => _selectColor(palette.color),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: palette.color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: scheme.onSurface, width: 2)
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        Text('Custom color', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: '#4F46E5',
                  prefixIcon: Icon(Icons.palette_outlined),
                ),
                onSubmitted: (_) => _applyHex(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _applyHex,
              icon: const Icon(Icons.check),
              tooltip: 'Apply color',
            ),
          ],
        ),
      ],
    );
  }
}
