import 'package:flutter_bloc/flutter_bloc.dart';

import 'layout_state.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(const LayoutState());

  void updateSize(double width, {required double sm, required double lg}) {
    SizeClass next;
    if (width < sm) {
      next = SizeClass.mobile;
    } else if (width < lg) {
      next = SizeClass.tablet;
    } else {
      next = SizeClass.desktop;
    }

    if (next == state.sizeClass) return;

    switch (next) {
      case SizeClass.desktop:
        emit(state.copyWith(sizeClass: next, desktopCollapsed: false));
        break;
      case SizeClass.tablet:
        emit(state.copyWith(sizeClass: next, tabletCollapsed: true));
        break;
      case SizeClass.mobile:
        emit(state.copyWith(sizeClass: next));
        break;
    }
  }

  void toggleCollapse() {
    if (state.isDesktop) {
      emit(state.copyWith(desktopCollapsed: !state.desktopCollapsed));
    } else if (state.isTablet) {
      emit(state.copyWith(tabletCollapsed: !state.tabletCollapsed));
    }
  }
}
