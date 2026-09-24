import 'package:equatable/equatable.dart';

enum SizeClass { mobile, tablet, desktop }

class LayoutState extends Equatable {
  const LayoutState({
    this.sizeClass = SizeClass.desktop,
    this.desktopCollapsed = false,
    this.tabletCollapsed = true,
  });

  final SizeClass sizeClass;
  final bool desktopCollapsed;
  final bool tabletCollapsed;

  bool get isMobile => sizeClass == SizeClass.mobile;
  bool get isTablet => sizeClass == SizeClass.tablet;
  bool get isDesktop => sizeClass == SizeClass.desktop;
  bool get collapsed => isDesktop ? desktopCollapsed : tabletCollapsed;

  LayoutState copyWith({
    SizeClass? sizeClass,
    bool? desktopCollapsed,
    bool? tabletCollapsed,
  }) {
    return LayoutState(
      sizeClass: sizeClass ?? this.sizeClass,
      desktopCollapsed: desktopCollapsed ?? this.desktopCollapsed,
      tabletCollapsed: tabletCollapsed ?? this.tabletCollapsed,
    );
  }

  @override
  List<Object?> get props => [sizeClass, desktopCollapsed, tabletCollapsed];
}
