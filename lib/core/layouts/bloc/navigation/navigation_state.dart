part of 'navigation_cubit.dart';

class NavigationState extends Equatable {
  final String selectedNav;
  final bool isExpanded;

  const NavigationState({required this.selectedNav, this.isExpanded = true});

  NavigationState copyWith({
    int? selectedIndex,
    String? selectedNav,
    bool? isExpanded,
  }) {
    return NavigationState(
      selectedNav: selectedNav ?? this.selectedNav,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  @override
  List<Object?> get props => [selectedNav, isExpanded];

  static const initial = NavigationState(selectedNav: 'Home', isExpanded: false);

  static NavigationState initialWithExpanded(bool expanded) {
    return NavigationState(selectedNav: 'Home', isExpanded: expanded);
  }
}
