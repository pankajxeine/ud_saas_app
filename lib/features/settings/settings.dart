import 'package:flutter/material.dart' hide Card;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ud_sass_app/core/layouts/layout/layout_scope.dart';
import 'package:ud_sass_app/core/theme/app_fonts.dart';
import 'package:ud_sass_app/core/theme/app_preset_sources.dart';
import 'package:ud_sass_app/core/theme/theme_app.dart';
import 'package:ud_sass_app/core/theme/theme_app_edits.dart';
import 'package:ud_sass_app/core/theme/theme_cubit.dart';
import 'package:ud_sass_app/core/theme/theme_state.dart';

import 'package:ud_sass_app/features/settings/theme_setting_value.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/components/card.dart';
import 'package:ud_sass_app/ui/dashcn/components/color.dart' as dashcn_color;
import 'package:ud_sass_app/ui/dashcn/components/color_picker.dart'
    as dashcn_picker;
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/bootstrap_icons.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart' as dashcn;

final List<ThemeApp> _themePresets = kPresetSources.keys
    .map(ThemeApp.fromPreset)
    .toList(growable: false);

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < kDesktopBreakpoint) {
          return _MobileSettingsPage(
            onOpenSettings: () => _openSettingsSheet(context),
          );
        }

        return const Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(flex: 5, child: _SettingsControls()),
              SizedBox(width: 24),
              Expanded(flex: 4, child: _ThemePreview()),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openSettingsSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext sheetContext) => FractionallySizedBox(
        heightFactor: 0.92,
        child: _SettingsControls(
          onClose: () => Navigator.of(sheetContext).pop(),
        ),
      ),
    );
  }
}

class _MobileSettingsPage extends StatelessWidget {
  const _MobileSettingsPage({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Appearance & layout',
                style: dashcn.Theme.of(context).typography.h2,
              ),
            ),
            IconButton(
              tooltip: 'Customize appearance',
              onPressed: onOpenSettings,
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Preview your changes here, or open settings to customize your workspace.',
          style: TextStyle(
            color: dashcn.Theme.of(context).colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 16),
        const Expanded(child: _ThemePreview()),
        const SizedBox(height: 12),
        Button(
          variant: ButtonVariant.primary,
          onPressed: onOpenSettings,
          leading: const Icon(Icons.tune, size: 18),
          child: const Text('Customize appearance'),
        ),
      ],
    ),
  );
}

class _SettingsControls extends StatefulWidget {
  const _SettingsControls({this.onClose});

  final VoidCallback? onClose;

  @override
  State<_SettingsControls> createState() => _SettingsControlsState();
}

class _SettingsControlsState extends State<_SettingsControls> {
  final ScrollController _scrollController = ScrollController();
  Brightness _editingBrightness = Brightness.light;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (BuildContext context, ThemeState state) {
        final ThemeCubit cubit = context.read<ThemeCubit>();
        final ThemeApp document = state.settings.themeDocument;
        final dashcn.Density activeDensity =
            state.settings.density ?? state.settings.lightTheme.density;

        return SingleChildScrollView(
          key: const ValueKey<String>('settings-controls-scroll'),
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Theme settings',
                      style: dashcn.Theme.of(context).typography.h2,
                    ),
                  ),
                  if (widget.onClose != null)
                    IconButton(
                      tooltip: 'Close settings',
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Customize your workspace. Changes are saved automatically.',
                style: TextStyle(
                  color: dashcn.Theme.of(context).colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),
              _SettingsCard(
                title: 'Color mode',
                description: 'Choose light, dark, or follow your system.',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _ModeOption(
                      icon: BootstrapIcons.sunFill,
                      label: 'Light',
                      selected: state.themeMode == dashcn.ThemeMode.light,
                      onTap: () => _update(
                        () => cubit.setThemeMode(dashcn.ThemeMode.light),
                      ),
                    ),
                    _ModeOption(
                      icon: BootstrapIcons.moonFill,
                      label: 'Dark',
                      selected: state.themeMode == dashcn.ThemeMode.dark,
                      onTap: () => _update(
                        () => cubit.setThemeMode(dashcn.ThemeMode.dark),
                      ),
                    ),
                    _ModeOption(
                      icon: Icons.devices,
                      label: 'System',
                      selected: state.themeMode == dashcn.ThemeMode.system,
                      onTap: () => _update(
                        () => cubit.setThemeMode(dashcn.ThemeMode.system),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Theme preset',
                description:
                    'Start with a palette and token set, then customize it below.',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _themePresets
                      .map(
                        (ThemeApp preset) => _ThemePresetOption(
                          theme: preset,
                          selected: document.id == preset.id,
                          onTap: () =>
                              _update(() => cubit.setPreset(preset.id)),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Color tokens',
                description:
                    'Edit every theme color independently for light and dark mode.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SegmentedButton<Brightness>(
                      segments: const <ButtonSegment<Brightness>>[
                        ButtonSegment<Brightness>(
                          value: Brightness.light,
                          label: Text('Light palette'),
                          icon: Icon(Icons.light_mode_outlined),
                        ),
                        ButtonSegment<Brightness>(
                          value: Brightness.dark,
                          label: Text('Dark palette'),
                          icon: Icon(Icons.dark_mode_outlined),
                        ),
                      ],
                      selected: <Brightness>{_editingBrightness},
                      onSelectionChanged: (Set<Brightness> selection) {
                        setState(() {
                          _editingBrightness = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    for (final _ColorGroup group in _colorGroups())
                      _ColorTokenGroup(
                        group: group,
                        colors: _editingBrightness == Brightness.dark
                            ? document.dark
                            : document.light,
                        onPick: (String token, Color color) => _update(
                          () => cubit.editTheme(
                            (ThemeApp current) => current.withModeColor(
                              token,
                              formatAppHexColor(color.toARGB32()),
                              _editingBrightness,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Typography',
                description:
                    'Choose bundled heading, body, serif, and monospace fonts.',
                child: Column(
                  children: <Widget>[
                    for (final String slot in kAppFontSlots)
                      _FontSetting(
                        key: ValueKey<String>('font-$slot'),
                        slot: slot,
                        current: document.fonts[slot],
                        onChanged: (String? family) => _update(
                          () => cubit.editTheme(
                            (ThemeApp current) =>
                                current.withFont(slot, family),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Layout & shape',
                description:
                    'Tune the spacing, density, corners, and overall control scale.',
                child: Column(
                  children: <Widget>[
                    _NumberSetting(
                      label: 'Corner radius',
                      value: document.radius,
                      min: 0,
                      max: 1.5,
                      divisions: 30,
                      suffix: 'rem',
                      onChanged: (double value) =>
                          _update(() => cubit.setRadius(value)),
                    ),
                    _NumberSetting(
                      label: 'Base spacing',
                      value: document.spacing,
                      min: 0.25,
                      max: 2,
                      divisions: 35,
                      suffix: 'rem',
                      onChanged: (double value) => _update(
                        () => cubit.editTheme(
                          (ThemeApp current) => current.withSpacingRem(value),
                        ),
                      ),
                    ),
                    _NumberSetting(
                      label: 'Interface scale',
                      value: state.settings.scaling,
                      min: 0.75,
                      max: 1.35,
                      divisions: 24,
                      suffix: '×',
                      onChanged: (double value) =>
                          _update(() => cubit.setScaling(value)),
                    ),
                    _LabeledChoice<dashcn.Density>(
                      label: 'Interface density',
                      value: activeDensity,
                      values: densityOptions.values.toList(),
                      labelFor: (dashcn.Density value) => _densityLabel(value),
                      onChanged: (dashcn.Density value) =>
                          _update(() => cubit.setDensity(value)),
                    ),
                    for (final String step in kAppTrackingSteps)
                      _NumberSetting(
                        label: '${_titleCase(step)} letter spacing',
                        value: document.tracking[step] ?? 0,
                        min: -0.2,
                        max: 0.2,
                        divisions: 40,
                        suffix: 'em',
                        onChanged: (double value) => _update(
                          () => cubit.editTheme(
                            (ThemeApp current) =>
                                current.withTracking(step, value),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Surfaces & shadows',
                description:
                    'Set layered surface opacity and blur, plus the active mode’s shadow atoms.',
                child: Column(
                  children: <Widget>[
                    _NumberSetting(
                      label: 'Surface opacity',
                      value: document.surfaceOpacity ?? 1,
                      min: 0,
                      max: 1,
                      divisions: 20,
                      onChanged: (double value) =>
                          _update(() => cubit.setSurfaceOpacity(value)),
                    ),
                    _NumberSetting(
                      label: 'Surface blur',
                      value: document.surfaceBlur ?? 0,
                      min: 0,
                      max: 24,
                      divisions: 24,
                      suffix: 'px',
                      onChanged: (double value) =>
                          _update(() => cubit.setSurfaceBlur(value)),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SegmentedButton<Brightness>(
                        segments: const <ButtonSegment<Brightness>>[
                          ButtonSegment<Brightness>(
                            value: Brightness.light,
                            label: Text('Light shadow'),
                          ),
                          ButtonSegment<Brightness>(
                            value: Brightness.dark,
                            label: Text('Dark shadow'),
                          ),
                        ],
                        selected: <Brightness>{_editingBrightness},
                        onSelectionChanged: (Set<Brightness> selection) =>
                            setState(
                              () => _editingBrightness = selection.first,
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ShadowSettings(
                      atoms: document.shadowOf(_editingBrightness),
                      onColor: (Color color) => _update(
                        () => cubit.editTheme(
                          (ThemeApp current) => current.withShadow(
                            _editingBrightness,
                            current
                                .shadowOf(_editingBrightness)
                                .copyWith(color: color.toARGB32()),
                          ),
                        ),
                      ),
                      onChanged: (AppShadowAtoms atoms) => _update(
                        () => cubit.editTheme(
                          (ThemeApp current) =>
                              current.withShadow(_editingBrightness, atoms),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Motion',
                description:
                    'Choose the transition intensity and fine-tune custom motion.',
                child: _MotionSettings(
                  document: document,
                  onEdit: (ThemeApp Function(ThemeApp) edit) =>
                      _update(() => cubit.editTheme(edit)),
                ),
              ),
              const SizedBox(height: 24),
              Button(
                variant: ButtonVariant.primary,
                onPressed: () => _update(cubit.resetAppearance),
                leading: const Icon(BootstrapIcons.routerFill, size: 18),
                child: const Text('Reset appearance'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _update(Future<void> Function() update) async {
    try {
      await update();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update appearance: $error')),
      );
    }
  }
}

List<_ColorGroup> _colorGroups() {
  final List<String> keys = kAppColorTokenKeys;
  return <_ColorGroup>[
    _ColorGroup(
      'Foundation and actions',
      keys
          .where(
            (String key) =>
                !key.startsWith('chart') && !key.startsWith('sidebar'),
          )
          .toList(),
    ),
    _ColorGroup(
      'Charts',
      keys.where((String key) => key.startsWith('chart')).toList(),
    ),
    _ColorGroup(
      'Sidebar',
      keys.where((String key) => key.startsWith('sidebar')).toList(),
    ),
  ];
}

String _densityLabel(dashcn.Density value) {
  for (final MapEntry<String, dashcn.Density> entry in densityOptions.entries) {
    if (entry.value == value) {
      return entry.key;
    }
  }
  return 'Custom';
}

String _titleCase(String value) => value
    .replaceAllMapped(RegExp(r'([A-Z])'), (Match match) => ' ${match[1]}')
    .split(RegExp(r'[-_]'))
    .map(
      (String word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}',
    )
    .join(' ');

class _ThemePreview extends StatelessWidget {
  const _ThemePreview();

  @override
  Widget build(BuildContext context) => BlocBuilder<ThemeCubit, ThemeState>(
    builder: (BuildContext context, ThemeState state) {
      final ThemeApp document = state.settings.themeDocument;
      final dashcn.ThemeColors colors = document.colorsFor(
        dashcn.Theme.of(context).brightness,
      );
      final double radius = document.radius * 16;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.background,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Live theme preview',
                style: TextStyle(
                  color: colors.foreground,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: document.fonts['heading'],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Changes to colors, typography, and shape appear here instantly.',
                style: TextStyle(
                  color: colors.mutedForeground,
                  fontFamily: document.fonts['body'],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.card,
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(radius * 0.75),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Workspace overview',
                            style: TextStyle(
                              color: colors.foreground,
                              fontWeight: FontWeight.w600,
                              fontFamily: document.fonts['heading'],
                            ),
                          ),
                        ),
                        Icon(Icons.more_horiz, color: colors.mutedForeground),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Monthly revenue',
                      style: TextStyle(
                        color: colors.mutedForeground,
                        fontSize: 13,
                        fontFamily: document.fonts['body'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$24,680',
                      style: TextStyle(
                        color: colors.foreground,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        fontFamily: document.fonts['heading'],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: LinearProgressIndicator(
                        value: 0.68,
                        minHeight: 8,
                        backgroundColor: colors.muted,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _PreviewSwatch(color: colors.primary, label: 'Primary'),
                        _PreviewSwatch(
                          color: colors.secondary,
                          label: 'Secondary',
                        ),
                        _PreviewSwatch(color: colors.accent, label: 'Accent'),
                        _PreviewSwatch(
                          color: colors.destructive,
                          label: 'Destructive',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: <Widget>[
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Save changes'),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PreviewSwatch extends StatelessWidget {
  const _PreviewSwatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: dashcn.Theme.of(context).typography.h3),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: dashcn.Theme.of(context).colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    ),
  );
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dashcn.ThemeColors colors = dashcn.Theme.of(context).colors;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: selected ? colors.primary : colors.mutedForeground,
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ThemePresetOption extends StatelessWidget {
  const _ThemePresetOption({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final ThemeApp theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dashcn.ThemeColors colors = theme.colorsFor(Brightness.light);
    final dashcn.ThemeColors current = dashcn.Theme.of(context).colors;
    return Tooltip(
      message: theme.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 145,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? current.primary : current.border,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  theme.name,
                  overflow: TextOverflow.ellipsis,
                  style: dashcn.Theme.of(context).typography.small,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorGroup {
  const _ColorGroup(this.title, this.tokens);

  final String title;
  final List<String> tokens;
}

class _ColorTokenGroup extends StatelessWidget {
  const _ColorTokenGroup({
    required this.group,
    required this.colors,
    required this.onPick,
  });

  final _ColorGroup group;
  final Map<String, String> colors;
  final Future<void> Function(String token, Color color) onPick;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    title: Text(group.title),
    children: group.tokens
        .map(
          (String token) => _ColorTokenRow(
            token: token,
            color: appColorOf(colors[token]!),
            onPick: (Color color) => onPick(token, color),
          ),
        )
        .toList(),
  );
}

class _ColorTokenRow extends StatelessWidget {
  const _ColorTokenRow({
    required this.token,
    required this.color,
    required this.onPick,
  });

  final String token;
  final Color color;
  final ValueChanged<Color> onPick;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: <Widget>[
        Expanded(child: Text(_titleCase(token))),
        Text(
          formatAppHexColor(color.toARGB32()),
          style: dashcn.Theme.of(context).typography.xSmall,
        ),
        const SizedBox(width: 10),
        _ColorButton(color: color, onPressed: () => _editColor(context, color)),
      ],
    ),
  );

  Future<void> _editColor(BuildContext context, Color initialColor) async {
    final Color? result = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) =>
          _ColorEditorDialog(initialColor: initialColor),
    );
    if (result != null) {
      onPick(result);
    }
  }
}

class _ColorButton extends StatelessWidget {
  const _ColorButton({required this.color, required this.onPressed});

  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Choose color',
    onPressed: onPressed,
    icon: Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: dashcn.Theme.of(context).colors.border),
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );
}

class _ColorEditorDialog extends StatefulWidget {
  const _ColorEditorDialog({required this.initialColor});

  final Color initialColor;

  @override
  State<_ColorEditorDialog> createState() => _ColorEditorDialogState();
}

class _ColorEditorDialogState extends State<_ColorEditorDialog> {
  late Color _color = widget.initialColor;

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 360,
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Edit color', style: dashcn.Theme.of(context).typography.h3),
              const SizedBox(height: 16),
              dashcn_picker.ColorPicker(
                value: dashcn_color.ColorDerivative.fromColor(_color),
                showAlpha: true,
                showHistoryButton: false,
                enableEyeDropper: false,
                onChanging: (dashcn_color.ColorDerivative next) =>
                    setState(() => _color = next.toColor()),
                onChanged: (dashcn_color.ColorDerivative next) =>
                    setState(() => _color = next.toColor()),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _color),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _FontSetting extends StatelessWidget {
  const _FontSetting({
    super.key,
    required this.slot,
    required this.current,
    required this.onChanged,
  });

  final String slot;
  final String? current;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<AppFontFamily> options = switch (slot) {
      'mono' => kAppMonoFonts,
      'serif' || 'heading' => kAppHeadingFonts,
      _ => kAppBodyFonts,
    };
    final String? selected = _selectedFont(options, current);
    final List<AppFontFamily> menu = <AppFontFamily>[
      ...options,
      if (current != null &&
          current!.isNotEmpty &&
          !options.any((AppFontFamily font) => font.family == current))
        AppFontFamily(
          label: '$current (current)',
          family: current!,
          assets: const <String>[],
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        initialValue: selected,
        isExpanded: true,
        decoration: InputDecoration(labelText: '${_titleCase(slot)} font'),
        items: menu
            .map(
              (AppFontFamily font) => DropdownMenuItem<String>(
                value: font.family,
                child: Text(font.label),
              ),
            )
            .toList(),
        onChanged: (String? family) =>
            onChanged(family == null || family.isEmpty ? null : family),
      ),
    );
  }

  String? _selectedFont(List<AppFontFamily> options, String? current) {
    if (current == null || current.isEmpty) {
      return '';
    }
    for (final AppFontFamily option in options) {
      if (option.family == current) {
        return current;
      }
    }
    return current;
  }
}

class _NumberSetting extends StatefulWidget {
  const _NumberSetting({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions = 20,
    this.suffix = '',
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String suffix;
  final ValueChanged<double> onChanged;

  @override
  State<_NumberSetting> createState() => _NumberSettingState();
}

class _NumberSettingState extends State<_NumberSetting> {
  late double _value = _clamp(widget.value);

  double _clamp(double value) => value.clamp(widget.min, widget.max).toDouble();

  @override
  void didUpdateWidget(covariant _NumberSetting oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = _clamp(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(widget.label)),
            Text('${_value.toStringAsFixed(2)}${widget.suffix}'),
          ],
        ),
        Slider(
          value: _value,
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          onChanged: (double value) => setState(() => _value = value),
          onChangeEnd: widget.onChanged,
        ),
      ],
    ),
  );
}

class _LabeledChoice<T> extends StatelessWidget {
  const _LabeledChoice({
    required this.label,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: DropdownButtonFormField<T>(
      initialValue: values.contains(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: values
          .map(
            (T item) =>
                DropdownMenuItem<T>(value: item, child: Text(labelFor(item))),
          )
          .toList(),
      onChanged: (T? next) {
        if (next != null) {
          onChanged(next);
        }
      },
    ),
  );
}

class _ShadowSettings extends StatelessWidget {
  const _ShadowSettings({
    required this.atoms,
    required this.onColor,
    required this.onChanged,
  });

  final AppShadowAtoms atoms;
  final ValueChanged<Color> onColor;
  final ValueChanged<AppShadowAtoms> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Row(
        children: <Widget>[
          const Expanded(child: Text('Shadow color')),
          Text(
            formatAppHexColor(atoms.color),
            style: dashcn.Theme.of(context).typography.xSmall,
          ),
          _ColorButton(
            color: Color(atoms.color),
            onPressed: () async {
              final Color? color = await showDialog<Color>(
                context: context,
                builder: (BuildContext context) =>
                    _ColorEditorDialog(initialColor: Color(atoms.color)),
              );
              if (color != null) {
                onColor(color);
              }
            },
          ),
        ],
      ),
      _NumberSetting(
        label: 'Shadow opacity',
        value: atoms.opacity,
        min: 0,
        max: 1,
        divisions: 20,
        onChanged: (double value) => onChanged(atoms.copyWith(opacity: value)),
      ),
      _NumberSetting(
        label: 'Shadow blur',
        value: atoms.blur,
        min: 0,
        max: 48,
        divisions: 48,
        suffix: 'px',
        onChanged: (double value) => onChanged(atoms.copyWith(blur: value)),
      ),
      _NumberSetting(
        label: 'Shadow spread',
        value: atoms.spread,
        min: -12,
        max: 24,
        divisions: 36,
        suffix: 'px',
        onChanged: (double value) => onChanged(atoms.copyWith(spread: value)),
      ),
      _NumberSetting(
        label: 'Shadow offset X',
        value: atoms.offsetX,
        min: -24,
        max: 24,
        divisions: 48,
        suffix: 'px',
        onChanged: (double value) => onChanged(atoms.copyWith(offsetX: value)),
      ),
      _NumberSetting(
        label: 'Shadow offset Y',
        value: atoms.offsetY,
        min: -24,
        max: 24,
        divisions: 48,
        suffix: 'px',
        onChanged: (double value) => onChanged(atoms.copyWith(offsetY: value)),
      ),
    ],
  );
}

class _MotionSettings extends StatelessWidget {
  const _MotionSettings({required this.document, required this.onEdit});

  final ThemeApp document;
  final ValueChanged<ThemeApp Function(ThemeApp)> onEdit;

  @override
  Widget build(BuildContext context) {
    final bool enabled = document.motionEnabled ?? true;
    final dashcn.MotionIntensity intensity =
        document.motionIntensity ?? dashcn.MotionIntensity.standard;
    return Column(
      children: <Widget>[
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable motion'),
          value: enabled,
          onChanged: (bool value) =>
              onEdit((ThemeApp theme) => theme.withMotionEnabled(value)),
        ),
        _LabeledChoice<dashcn.MotionIntensity>(
          label: 'Intensity',
          value: intensity,
          values: dashcn.MotionIntensity.values,
          labelFor: (value) => _titleCase(value.name),
          onChanged: (dashcn.MotionIntensity value) =>
              onEdit((ThemeApp theme) => theme.withMotionIntensity(value)),
        ),
        if (intensity == dashcn.MotionIntensity.custom) ...<Widget>[
          _NumberSetting(
            label: 'Duration multiplier',
            value: document.motionCustomDurationMultiplier ?? 1,
            min: 0.25,
            max: 3,
            divisions: 22,
            suffix: '×',
            onChanged: (double value) => onEdit(
              (ThemeApp theme) =>
                  theme.withMotionCustomDurationMultiplier(value),
            ),
          ),
          _NumberSetting(
            label: 'Press scale',
            value: document.motionCustomPressScale ?? 0.96,
            min: 0.8,
            max: 1,
            divisions: 20,
            onChanged: (double value) => onEdit(
              (ThemeApp theme) => theme.withMotionCustomPressScale(value),
            ),
          ),
          _NumberSetting(
            label: 'Enter offset',
            value: document.motionCustomEnterOffset ?? 8,
            min: 0,
            max: 24,
            divisions: 24,
            suffix: 'px',
            onChanged: (double value) => onEdit(
              (ThemeApp theme) => theme.withMotionCustomEnterOffset(value),
            ),
          ),
          _LabeledChoice<dashcn.MotionCurveName>(
            label: 'Motion curve',
            value:
                document.motionCustomCurve ??
                dashcn.MotionCurveName.emphasizedOut,
            values: dashcn.MotionCurveName.values,
            labelFor: (dashcn.MotionCurveName value) => _titleCase(value.name),
            onChanged: (dashcn.MotionCurveName value) =>
                onEdit((ThemeApp theme) => theme.withMotionCustomCurve(value)),
          ),
        ],
      ],
    );
  }
}
