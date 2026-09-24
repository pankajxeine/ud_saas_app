import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit({bool initialExpanded = false})
    : super(NavigationState.initialWithExpanded(initialExpanded));

  void selectNav(String label) {
    emit(state.copyWith(selectedNav: label));
  }

  void toggleExpanded() {
    emit(state.copyWith(isExpanded: !state.isExpanded));
  }
}
