import 'package:flutter/material.dart' hide Theme;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import 'package:ud_sass_app/ui/shadcn/components/control/button/button.dart';
import 'package:ud_sass_app/ui/shadcn/shared/theme/theme.dart';

import 'bloc/layout/layout_cubit.dart';
import 'bloc/layout/layout_state.dart';
import 'layout/layout_scope.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/app_bar.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({
    super.key,
    required this.body,
  });

  final Widget body;

  @override
  Widget build(BuildContext context) {
    final drawerKey = GlobalKey<ScaffoldState>();
    return BlocProvider(
      create: (_) => LayoutCubit(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<LayoutCubit>().updateSize(
                    constraints.maxWidth,
                    sm: kTabletBreakpoint,
                    lg: kDesktopBreakpoint,
                  );
            }
          });

          return BlocBuilder<LayoutCubit, LayoutState>(
            builder: (context, state) {
              final breakpoint = switch (state.sizeClass) {
                SizeClass.mobile => LayoutBreakpoint.mobile,
                SizeClass.tablet => LayoutBreakpoint.tablet,
                SizeClass.desktop => LayoutBreakpoint.desktop,
              };
              return MainLayoutScope(
                breakpoint: breakpoint,
                openDrawer: () => drawerKey.currentState?.openDrawer(),
                child: _AppShell(
                  drawerKey: drawerKey,
                  isMobile: state.isMobile,
                  collapsed: state.collapsed,
                  onToggleSidebar: context.read<LayoutCubit>().toggleCollapse,
                  child: body,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell({
    required this.child,
    required this.isMobile,
    required this.collapsed,
    required this.onToggleSidebar,
    required this.drawerKey,
  });

  final Widget child;
  final bool isMobile;
  final bool collapsed;
  final VoidCallback onToggleSidebar;
  final GlobalKey<ScaffoldState> drawerKey;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final location = GoRouterState.of(context).matchedLocation;
    final content = Column(
      children: [
        AppTopBar(
          isMobile: isMobile,
          collapsed: collapsed,
          onToggle: onToggleSidebar,
        ),
        Expanded(child: child),
      ],
    );

    return Scaffold(
      key: drawerKey,
      backgroundColor: cs.background,
      drawer: isMobile ? const AppNavDrawer() : null,
      body: SafeArea(
        child: isMobile
            ? content
            : Row(
                children: [
                  AppSidebar(
                    collapsed: collapsed,
                    currentRoute: location,
                    onToggle: onToggleSidebar,
                  ),
                  Expanded(child: content),
                ],
              ),
      ),
    );
  }
}

// class _TopBar extends StatelessWidget {
//   const _TopBar({required this.isMobile});

//   final bool isMobile;

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     return Container(
//       height: 64,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: cs.background,
//         border: Border(bottom: BorderSide(color: cs.border)),
//       ),
//       child: Row(
//         children: [
//           if (isMobile) ...[
//             OutlineButton(
//               onPressed: MainLayoutScope.of(context).openDrawer,
//               child: const Icon(Icons.menu),
//             ),
//             const SizedBox(width: 12),
//           ],
//           if (!isMobile) ...[
//             if (onToggle != null)
//               Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: OutlinedButton(
//                   onPressed: onToggle,
//                   child: Icon(
//                     collapsed ? Icons.menu_open : Icons.menu,
//                     size: 16,
//                   ),
//                 ),
//               ),
//           ],
//           Expanded(
//             child: Text(
//               'Workspace overview',
//               style: Theme.of(context).typography.h4,
//             ),
//           ),
//           OutlineButton(
//             onPressed: () {},
//             child: const Icon(Icons.notifications_none_rounded),
//           ),
//           const SizedBox(width: 8),
//           OutlineButton(
//             onPressed: () => context.go('/settings'),
//             child: const Icon(Icons.settings_outlined),
//           ),
//         ],
//       ),
//     );
//   }
// }
