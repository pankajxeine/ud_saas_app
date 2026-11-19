import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ud_sass_app/core/theme/app_theme.dart';
import 'package:ud_sass_app/core/theme/bloc/theme_cubit.dart';
import 'package:ud_sass_app/core/theme/bloc/theme_state.dart';
import 'package:ud_sass_app/core/theme/app_theme_palette.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final editor = _AppearanceEditor(settings: state.settings);
            const preview = _ThemePreview();

            if (constraints.maxWidth < 900) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                child: Column(children: [editor, preview]),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: editor),
                  const SizedBox(width: AppTheme.spaceLg),
                  const Expanded(flex: 2, child: preview),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _AppearanceEditor extends StatefulWidget {
  const _AppearanceEditor({required this.settings});

  final dynamic settings;

  @override
  State<_AppearanceEditor> createState() => _AppearanceEditorState();
}

class _AppearanceEditorState extends State<_AppearanceEditor> {
  late double radius;
  late double scale;
  late double opacity;
  late double blur;
  late String fontFamily;
  late Color seedColor;

  late final TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
    _hexController = TextEditingController(text: _colorToHex(seedColor));
  }

  void _initializeSettings() {
    radius = (widget.settings.themeDocument.radiusPx / 16).clamp(0.0, 1.5);
    scale = widget.settings.scaling.clamp(0.8, 1.2);
    opacity = widget.settings.themeDocument.surfaceOpacity ?? 1.0;
    blur = widget.settings.themeDocument.surfaceBlur ?? 0.0;
    fontFamily = widget.settings.themeDocument.bodyFont ?? 'GeistSans';
    seedColor = widget.settings.seedColor ?? AppThemePalette.defaultColor;
  }

  @override
  void didUpdateWidget(covariant _AppearanceEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.settings.seedColor != widget.settings.seedColor) {
      seedColor = widget.settings.seedColor ?? AppThemePalette.defaultColor;
      _hexController.text = _colorToHex(seedColor);
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  Color? _parseHex(String value) {
    var hex = value.trim().replaceAll('#', '');

    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }

    if (hex.length != 6 || !RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) {
      return null;
    }

    return Color(int.parse('FF$hex', radix: 16));
  }

  void _selectSeedColor(Color color) {
    setState(() {
      seedColor = color;
      _hexController.text = _colorToHex(color);
    });

    context.read<ThemeCubit>().setSeedColor(color);
  }

  Future<void> _openColorPicker() async {
    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (_) => _CustomColorDialog(initialColor: seedColor),
    );

    if (selectedColor != null) {
      _selectSeedColor(selectedColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ThemeCubit>();
    final theme = Theme.of(context);
    final mode = widget.settings.themeMode.toString().split('.').last;

    const fontFamilies = {'GeistSans', 'Roboto', 'Inter', 'System'};

    String normalizeFontFamily(String? value) {
      if (value == null || value.isEmpty) return 'System';

      switch (value) {
        case 'Geist, sans-serif':
        case 'Geist Sans':
        case 'GeistSans':
          return 'GeistSans';
        case 'Roboto':
          return 'Roboto';
        case 'Inter':
          return 'Inter';
        default:
          return 'System';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Appearance', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppTheme.spaceSm),
        Text(
          'Customize color mode, typography, spacing, surfaces, and motion.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTheme.spaceLg),

        // COLOR MODE
        _SettingsSection(
          title: 'Color mode',
          description: 'Choose light, dark, or follow the system setting.',
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'light',
                icon: Icon(Icons.light_mode),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: 'dark',
                icon: Icon(Icons.dark_mode),
                label: Text('Dark'),
              ),
              ButtonSegment(
                value: 'system',
                icon: Icon(Icons.devices),
                label: Text('System'),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (selection) async {
              switch (selection.first) {
                case 'light':
                  await cubit.setBrightness(Brightness.light);
                case 'dark':
                  await cubit.setBrightness(Brightness.dark);
                case 'system':
                  await cubit.setSystemMode();
              }
            },
          ),
        ),

        // THEME PALETTE
        _SettingsSection(
          title: 'Theme palette',
          description:
              'Choose an accent color. It will generate coordinated light and dark themes.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 14,
                children: _themePalettes.map((palette) {
                  final selected =
                      seedColor.toARGB32() == palette.color.toARGB32();

                  return Tooltip(
                    message: palette.name,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => _selectSeedColor(palette.color),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: AppTheme.motionFast,
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: palette.color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.outlineVariant,
                                width: selected ? 3 : 1,
                              ),
                            ),
                            child: selected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 4),
                          Text(palette.name, style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTheme.spaceLg),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: seedColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: TextField(
                      controller: _hexController,
                      decoration: const InputDecoration(
                        labelText: 'Custom HEX color',
                        hintText: '#6750A4',
                        prefixIcon: Icon(Icons.tag),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (value) {
                        final color = _parseHex(value);
                        if (color != null) {
                          _selectSeedColor(color);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  IconButton.filledTonal(
                    tooltip: 'Apply HEX color',
                    onPressed: () {
                      final color = _parseHex(_hexController.text);
                      if (color == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Enter a valid HEX color, e.g. #6750A4',
                            ),
                          ),
                        );
                        return;
                      }
                      _selectSeedColor(color);
                    },
                    icon: const Icon(Icons.check),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),
              OutlinedButton.icon(
                onPressed: _openColorPicker,
                icon: const Icon(Icons.color_lens_outlined),
                label: const Text('Open color picker'),
              ),
            ],
          ),
        ),

        // TYPOGRAPHY
        _SettingsSection(
          title: 'Typography',
          description: 'Select the primary application font family.',
          child: DropdownButtonFormField<String>(
            initialValue: normalizeFontFamily(fontFamily),
            decoration: const InputDecoration(labelText: 'Font family'),
            items: const [
              DropdownMenuItem(value: 'GeistSans', child: Text('Geist Sans')),
              DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
              DropdownMenuItem(value: 'Inter', child: Text('Inter')),
              DropdownMenuItem(value: 'System', child: Text('System default')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => fontFamily = value);
              cubit.setFontFamily(value == 'System' ? null : value);
            },
          ),
        ),

        _SliderSection(
          title: 'Corner radius',
          description: 'Controls cards, inputs, buttons, and dialogs.',
          value: radius,
          min: 0,
          max: 1.5,
          divisions: 6,
          label: '${(radius * 16).round()} px',
          onChanged: (value) => setState(() => radius = value),
          onChangeEnd: cubit.setRadius,
        ),

        _SliderSection(
          title: 'Interface scale',
          description: 'Adjust the overall density of the interface.',
          value: scale,
          min: 0.8,
          max: 1.2,
          divisions: 8,
          label: '${(scale * 100).round()}%',
          onChanged: (value) => setState(() => scale = value),
          onChangeEnd: cubit.setScaling,
        ),

        _SliderSection(
          title: 'Surface opacity',
          description: 'Controls transparency of elevated surfaces.',
          value: opacity,
          min: 0.78,
          max: 1,
          divisions: 11,
          label: '${(opacity * 100).round()}%',
          onChanged: (value) => setState(() => opacity = value),
          onChangeEnd: cubit.setSurfaceOpacity,
        ),

        _SliderSection(
          title: 'Surface blur',
          description: 'Controls blur behind translucent surfaces.',
          value: blur,
          min: 0,
          max: 16,
          divisions: 8,
          label: '${blur.round()} px',
          onChanged: (value) => setState(() => blur = value),
          onChangeEnd: cubit.setSurfaceBlur,
        ),

        const SizedBox(height: AppTheme.spaceSm),
        OutlinedButton.icon(
          onPressed: cubit.resetAppearance,
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset appearance'),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// THEME PALETTES
// -----------------------------------------------------------------------------

class _ThemeColorPreset {
  const _ThemeColorPreset(this.name, this.color);

  final String name;
  final Color color;
}

const List<_ThemeColorPreset> _themePalettes = [
  _ThemeColorPreset('Indigo', Color(0xFF4F46E5)),
  _ThemeColorPreset('Blue', Color(0xFF2563EB)),
  _ThemeColorPreset('Sky', Color(0xFF0EA5E9)),
  _ThemeColorPreset('Cyan', Color(0xFF0891B2)),
  _ThemeColorPreset('Teal', Color(0xFF0D9488)),
  _ThemeColorPreset('Green', Color(0xFF16A34A)),
  _ThemeColorPreset('Lime', Color(0xFF65A30D)),
  _ThemeColorPreset('Amber', Color(0xFFD97706)),
  _ThemeColorPreset('Orange', Color(0xFFEA580C)),
  _ThemeColorPreset('Red', Color(0xFFDC2626)),
  _ThemeColorPreset('Rose', Color(0xFFE11D48)),
  _ThemeColorPreset('Pink', Color(0xFFDB2777)),
  _ThemeColorPreset('Purple', Color(0xFF9333EA)),
  _ThemeColorPreset('Violet', Color(0xFF7C3AED)),
  _ThemeColorPreset('Slate', Color(0xFF475569)),
  _ThemeColorPreset('Neutral', Color(0xFF525252)),
];

// -----------------------------------------------------------------------------
// CUSTOM COLOR PICKER
// -----------------------------------------------------------------------------

class _CustomColorDialog extends StatefulWidget {
  const _CustomColorDialog({required this.initialColor});

  final Color initialColor;

  @override
  State<_CustomColorDialog> createState() => _CustomColorDialogState();
}

class _CustomColorDialogState extends State<_CustomColorDialog> {
  late HSVColor hsvColor;
  late TextEditingController hexController;

  @override
  void initState() {
    super.initState();
    hsvColor = HSVColor.fromColor(widget.initialColor);
    hexController = TextEditingController(text: _toHex(widget.initialColor));
  }

  String _toHex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  Color? _parseHex(String value) {
    var hex = value.trim().replaceAll('#', '');

    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }

    if (hex.length != 6 || !RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) {
      return null;
    }

    return Color(int.parse('FF$hex', radix: 16));
  }

  void _updateColor(HSVColor color) {
    setState(() {
      hsvColor = color;
      hexController.text = _toHex(color.toColor());
    });
  }

  @override
  void dispose() {
    hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = hsvColor.toColor();

    return AlertDialog(
      title: const Text('Choose custom color'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 76,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                _toHex(color),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: hsvColor.value > 0.55 ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _ColorSlider(
              label: 'Hue',
              value: hsvColor.hue,
              min: 0,
              max: 360,
              divisions: 360,
              onChanged: (value) {
                _updateColor(hsvColor.withHue(value));
              },
            ),
            _ColorSlider(
              label: 'Saturation',
              value: hsvColor.saturation,
              min: 0,
              max: 1,
              divisions: 100,
              onChanged: (value) {
                _updateColor(hsvColor.withSaturation(value));
              },
            ),
            _ColorSlider(
              label: 'Brightness',
              value: hsvColor.value,
              min: 0,
              max: 1,
              divisions: 100,
              onChanged: (value) {
                _updateColor(hsvColor.withValue(value));
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hexController,
              decoration: const InputDecoration(
                labelText: 'HEX color',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
              onChanged: (value) {
                final parsed = _parseHex(value);
                if (parsed != null) {
                  setState(() {
                    hsvColor = HSVColor.fromColor(parsed);
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final parsed = _parseHex(hexController.text);
            if (parsed == null) return;
            Navigator.pop(context, parsed);
          },
          child: const Text('Apply color'),
        ),
      ],
    );
  }
}

class _ColorSlider extends StatelessWidget {
  const _ColorSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 85, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.toStringAsFixed(2),
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// SHARED SETTINGS WIDGETS
// -----------------------------------------------------------------------------

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTheme.spaceXs),
            Text(description, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppTheme.spaceMd),
            child,
          ],
        ),
      ),
    );
  }
}

class _SliderSection extends StatelessWidget {
  const _SliderSection({
    required this.title,
    required this.description,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String title;
  final String description;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: title,
      description: description,
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: label,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
          SizedBox(width: 60, child: Text(label, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// THEME PREVIEW
// -----------------------------------------------------------------------------

class _ThemePreview extends StatelessWidget {
  const _ThemePreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeExtension>();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(gradient: tokens?.surfaceGradient),
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live preview', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppTheme.spaceLg),
            Text('Dashboard overview', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'Your theme preferences are reflected throughout the application.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            const Row(
              children: [
                Expanded(
                  child: _MetricPreview(label: 'Revenue', value: '\$24,680'),
                ),
                SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: _MetricPreview(label: 'Users', value: '8,492'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLg),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check),
              label: const Text('Primary action'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPreview extends StatelessWidget {
  const _MetricPreview({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppTheme.spaceXs),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
