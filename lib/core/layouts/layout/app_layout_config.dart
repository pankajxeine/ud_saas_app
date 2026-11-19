enum AppBarLayout { fullWidth, contentOnly }

class AppLayoutConfig {
  const AppLayoutConfig({
    this.appBarLayout = AppBarLayout.fullWidth,
    this.showAppBar = true,
    this.showSidebar = true,
    this.showNavigationRail = true,
    this.showBottomNavigation = true,
    this.useBackgroundGradient = false,
    this.useSurfaceGradient = false,
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
}
