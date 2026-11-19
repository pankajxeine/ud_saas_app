import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:ud_sass_app/data/layout_setting.dart';

class ThemeState extends Equatable {
  const ThemeState({required this.settings});

  final LayoutSettings settings;

  ThemeMode get themeMode => settings.themeMode;

  ThemeState copyWith({required LayoutSettings settings}) =>
      ThemeState(settings: settings);

  @override
  List<Object?> get props => [
    settings.themeDocument,
    settings.themeMode,
    settings.initialPath,
    settings.scaling,
    settings.density,
    settings.seedColor,
  ];
}
