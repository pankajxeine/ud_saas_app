import 'package:flutter/material.dart' hide Theme;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/layout/layout_cubit.dart';
import 'bloc/layout/layout_state.dart';
import 'layout/layout_scope.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    this.mobile,
    this.tablet,
    required this.desktop,
  });

  final Widget? mobile;
  final Widget? tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
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
              final child = switch (breakpoint) {
                LayoutBreakpoint.mobile => mobile ?? desktop,
                LayoutBreakpoint.tablet => tablet ?? desktop,
                LayoutBreakpoint.desktop => desktop,
              };
              return child;
            },
          );
        },
      ),
    );
  }
}
