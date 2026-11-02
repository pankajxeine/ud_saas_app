import 'package:equatable/equatable.dart';

import 'package:ud_sass_app/data/layout_setting.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart' as dashcn;

class ThemeState extends Equatable {
  const ThemeState({required this.settings});

  final LayoutSettings settings;

  dashcn.ThemeMode get themeMode => settings.themeMode;

  ThemeState copyWith({required LayoutSettings settings}) =>
      ThemeState(settings: settings);

  @override
  List<Object?> get props => [
    settings.themeDocument,
    settings.themeMode,
    settings.initialPath,
    settings.scaling,
    settings.density,
  ];
}
