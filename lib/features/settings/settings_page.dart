// import 'package:flutter/material.dart';
// import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart' hide Card, TextField, Theme, Colors;

import 'package:ud_sass_app/ui/shadcn/components/control/button/_impl/variants/button_variants.dart';
import 'package:ud_sass_app/ui/shadcn/components/layout/card/card.dart';
import 'package:ud_sass_app/ui/shadcn/shared/theme/generated_colors.dart';
import 'package:ud_sass_app/ui/shadcn/shared/theme/theme.dart';
import 'package:ud_sass_app/ui/shadcn/shared/icons/bootstrap_icons.dart';
import 'package:ud_sass_app/core/widgets/components/choice_chip.dart';
import 'package:ud_sass_app/core/widgets/components/ink_well.dart';

import '../../core/theme/theme_cubit.dart';
import '../../core/theme/theme_state.dart';
import '../../core/theme/app_theme.dart';

import '../../core/layouts/main_layout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeCubit, AppThemeState>(
      builder: (context, state) {
        final cubit = context.read<AppThemeCubit>();
        return MainLayout(
            desktop: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Appearance', style: Theme.of(context).typography.h2),
                  const SizedBox(height: 8),
                  Text(
                    'Personalize your workspace. Your choices are saved automatically.',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.mutedForeground),
                  ),
                  const SizedBox(height: 28),
                  _SettingsCard(
                    title: 'Color mode',
                    description:
                        'Choose the interface brightness that feels best for you.',
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _ModeOption(
                          icon: BootstrapIcons.sunFill,
                          label: 'Light',
                          selected: state.brightness == Brightness.light,
                          onTap: () => cubit.setBrightness(Brightness.light),
                        ),
                        _ModeOption(
                          icon: BootstrapIcons.moonFill,
                          label: 'Dark',
                          selected: state.brightness == Brightness.dark,
                          onTap: () => cubit.setBrightness(Brightness.dark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SettingsCard(
                    title: 'Base preset',
                    description:
                        'Set the default surface and token palette for the interface.',
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: colorPresets
                          .map(
                            (preset) => _ColorOption(
                              scheme: preset,
                              selected: state.presetId == preset.id,
                              onTap: () => cubit.setPreset(preset.id),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SettingsCard(
                    title: 'Accent preset',
                    description:
                        'This is used for primary actions and selected navigation.',
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: colorPresets
                          .map(
                            (preset) => _ColorOption(
                              scheme: preset,
                              selected: state.preset == preset,
                              onTap: () => cubit.setCustomScheme(preset),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SettingsCard(
                    title: 'Interface density',
                    description:
                        'Control how much space is used between elements.',
                    child: ChoiceChipWrapper<AppDensity>(
                      items: AppDensity.values,
                      labelSelector: (density) => density.displayName,
                      initialValue: state.density,
                      onSelected: cubit.setDensity,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SettingsCard(
                    title: 'Corner radius',
                    description:
                        'Adjust the roundness of cards, fields, and buttons.',
                    child: ChoiceChipWrapper<String>(
                      items: radiusOptions.keys.toList(),
                      initialValue: radiusOptions.entries
                          .firstWhere(
                            (entry) =>
                                (entry.value - (state.radius ?? 0.25)).abs() <
                                0.01,
                            orElse: () => const MapEntry('Default', 0.5),
                          )
                          .key,
                      onSelected: (label) {
                        final value = radiusOptions[label];
                        if (value != null) {
                          cubit.setRadius(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SettingsCard(
                    title: 'Scaling',
                    description:
                        'Adjust the app scale for denser or more spacious layouts.',
                    child: ChoiceChipWrapper<String>(
                      items: scalingOptions.keys.toList(),
                      initialValue: scalingOptions.entries
                          .firstWhere(
                            (entry) =>
                                (entry.value - state.scaling).abs() < 0.001,
                            orElse: () => const MapEntry('Default', 1.0),
                          )
                          .key,
                      onSelected: (label) {
                        final value = scalingOptions[label];
                        if (value != null) {
                          cubit.setScaling(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SettingsCard(
                    title: 'Font size',
                    description: 'Choose the text scale for the app interface.',
                    child: ChoiceChipWrapper<FontSize>(
                      items: FontSize.values,
                      labelSelector: (fontSize) => fontSize.displayName,
                      initialValue: state.fontSize,
                      onSelected: cubit.setFontSize,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SettingsCard(
                    title: 'Surface opacity',
                    description:
                        'Set the opacity of the background surface layering.',
                    child: ChoiceChipWrapper<String>(
                      items: surfaceOpacityOptions.keys.toList(),
                      initialValue: surfaceOpacityOptions.entries
                          .firstWhere(
                            (entry) =>
                                (entry.value - state.surfaceOpacity).abs() <
                                0.01,
                            orElse: () => const MapEntry('Solid', 1.0),
                          )
                          .key,
                      onSelected: (label) {
                        final value = surfaceOpacityOptions[label];
                        if (value != null) {
                          cubit.setSurfaceOpacity(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SettingsCard(
                    title: 'Surface blur',
                    description:
                        'Control the blur strength for layered surfaces.',
                    child: ChoiceChipWrapper<String>(
                      items: surfaceBlurOptions.keys.toList(),
                      initialValue: surfaceBlurOptions.entries
                          .firstWhere(
                            (entry) =>
                                (entry.value - state.surfaceBlur).abs() < 0.01,
                            orElse: () => const MapEntry('None', 0.0),
                          )
                          .key,
                      onSelected: (label) {
                        final value = surfaceBlurOptions[label];
                        if (value != null) {
                          cubit.setSurfaceBlur(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    onPressed: cubit.resetAppearance,
                    leading: const Icon(BootstrapIcons.routerFill, size: 18),
                    child: const Text('Reset appearance'),
                  ),
                ],
              ),
            ),
          ),
        ));
      },
    );
  }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).typography.h3),
              const SizedBox(height: 4),
              if (description.isNotEmpty)
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
              const SizedBox(height: 12),
              child,
            ],
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
    final cs = Theme.of(context).colorScheme;
    return InkWellWrapper(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
              color: selected ? cs.primary : cs.border,
              width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? cs.primary : cs.mutedForeground),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.scheme,
    required this.selected,
    required this.onTap,
  });

  final AppThemePreset scheme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: scheme.name,
        child: InkWellWrapper(
          onTap: onTap,
          borderRadius: BorderRadius.circular(99),
          child: Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.foreground
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: scheme.light.primary),
            ),
          ),
        ),
      );
}
