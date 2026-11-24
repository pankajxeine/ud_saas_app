enum AppBarLayout { fullWidth, contentOnly }

class AppLayoutConfig {
  const AppLayoutConfig({
    this.appBarLayout = AppBarLayout.fullWidth,
    this.showAppBar = true,
    this.showSidebar = true,
    this.showNavigationRail = true,
    this.showBottomNavigation = true,
    this.useBackgroundGradient = true,
    this.useSurfaceGradient = true,
  });

  final AppBarLayout appBarLayout;

  final bool showAppBar;
  final bool showSidebar;
  final bool showNavigationRail;
  final bool showBottomNavigation;

  /// Applies AppThemeExtension.backgroundGradient to the shell.
  final bool useBackgroundGradient;

  /// Applies AppThemeExtension.surfaceGradient to the content area.
  final bool useSurfaceGradient;

  AppLayoutConfig copyWith({
    AppBarLayout? appBarLayout,
    bool? showAppBar,
    bool? showSidebar,
    bool? showNavigationRail,
    bool? showBottomNavigation,
    bool? useBackgroundGradient,
    bool? useSurfaceGradient,
  }) {
    return AppLayoutConfig(
      appBarLayout: appBarLayout ?? this.appBarLayout,
      showAppBar: showAppBar ?? this.showAppBar,
      showSidebar: showSidebar ?? this.showSidebar,
      showNavigationRail: showNavigationRail ?? this.showNavigationRail,
      showBottomNavigation:
          showBottomNavigation ?? this.showBottomNavigation,
      useBackgroundGradient:
          useBackgroundGradient ?? this.useBackgroundGradient,
      useSurfaceGradient: useSurfaceGradient ?? this.useSurfaceGradient,
    );
  }
}
