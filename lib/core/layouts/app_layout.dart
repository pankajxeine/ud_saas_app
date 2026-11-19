import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ud_sass_app/core/navigation/app_route_location.dart';
import 'package:ud_sass_app/core/theme/app_theme.dart';

import '../navigation/app_route_definition.dart';

import 'layout/app_layout_config.dart';
import 'bloc/layout/layout_cubit.dart';
import 'bloc/layout/layout_state.dart';
import 'layout/layout_scope.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/app_bar.dart';
import 'widgets/app_navigation.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({
    super.key,
    required this.body,
    this.routesList = const [],
    this.config = const AppLayoutConfig(),
  });

  final Widget body;
  final List<AppRouteDefinition> routesList;
  final AppLayoutConfig config;

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double? _lastWidth;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LayoutCubit(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _updateLayoutSize(context, constraints.maxWidth);

          return BlocBuilder<LayoutCubit, LayoutState>(
            builder: (context, state) {
              final isMobile = state.sizeClass == SizeClass.mobile;
              final isTablet = state.sizeClass == SizeClass.tablet;

              final breakpoint = switch (state.sizeClass) {
                SizeClass.mobile => LayoutBreakpoint.mobile,
                SizeClass.tablet => LayoutBreakpoint.tablet,
                SizeClass.desktop => LayoutBreakpoint.desktop,
              };

              return MainLayoutScope(
                breakpoint: breakpoint,
                openDrawer: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: _AppShell(
                  scaffoldKey: _scaffoldKey,
                  body: widget.body,
                  routesList: widget.routesList,
                  config: widget.config,
                  isMobile: isMobile,
                  isTablet: isTablet,
                  collapsed: state.collapsed,
                  onToggleSidebar: context.read<LayoutCubit>().toggleCollapse,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateLayoutSize(BuildContext context, double width) {
    if (_lastWidth == width) return;

    _lastWidth = width;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<LayoutCubit>().updateSize(
        width,
        sm: kTabletBreakpoint,
        lg: kDesktopBreakpoint,
      );
    });
  }
}

// =============================================================================
// App Shell
// =============================================================================

class _AppShell extends StatelessWidget {
  const _AppShell({
    required this.scaffoldKey,
    required this.body,
    required this.routesList,
    required this.config,
    required this.isMobile,
    required this.isTablet,
    required this.collapsed,
    required this.onToggleSidebar,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget body;
  final List<AppRouteDefinition> routesList;
  final AppLayoutConfig config;

  final bool isMobile;
  final bool isTablet;
  final bool collapsed;
  final VoidCallback onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gradients = theme.extension<AppThemeExtension>();

    final currentRoute = AppRouteLocation.maybeOf(context) ?? '/';

    final isDesktop = !isMobile && !isTablet;

    final showSidebar = config.showSidebar && isDesktop;
    final showRail = config.showNavigationRail && isTablet;
    final showBottomBar = config.showBottomNavigation && isMobile;

    final appBar = config.showAppBar
        ? AppTopBar(
            isMobile: isMobile,
            collapsed: collapsed,
            onToggle: onToggleSidebar,
          )
        : null;

    Widget buildSidebar() {
      if (!showRail && !showSidebar) {
        return const SizedBox.shrink();
      }

      return AppSidebar(
        routesList: routesList,
        collapsed: collapsed,
        currentRoute: currentRoute,
        onToggle: onToggleSidebar,
      );
    }

    // Main content surface with rounded top corners.
    Widget buildContentSurface(Widget child) {
      return Expanded(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusLarge),
              topRight: Radius.circular(AppTheme.radiusLarge),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      );
    }

    Widget buildNavigation() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [buildSidebar(), buildContentSurface(body)],
      );
    }

    final Widget content;

    switch (config.appBarLayout) {
      case AppBarLayout.fullWidth:
        content = Column(
          children: [
            if (appBar != null) appBar,
            Expanded(child: buildNavigation()),
          ],
        );

      case AppBarLayout.contentOnly:
        content = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildSidebar(),
            Expanded(
              child: Column(
                children: [
                  if (appBar != null) appBar,
                  buildContentSurface(body),
                ],
              ),
            ),
          ],
        );
    }

    final backgroundDecoration =
        config.useBackgroundGradient && gradients != null
        ? BoxDecoration(gradient: gradients.backgroundGradient)
        : BoxDecoration(color: colorScheme.surface);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colorScheme.surface,
      drawer: isMobile ? AppNavDrawer(routes: routesList) : null,
      bottomNavigationBar: showBottomBar
          ? AppNavigation(
              currentRoute: currentRoute,
              routesList: routesList,
              type: AppNavigationType.bottomBar,
            )
          : null,
      body: DecoratedBox(
        decoration: backgroundDecoration,
        child: SafeArea(child: content),
      ),
    );
  }
}
