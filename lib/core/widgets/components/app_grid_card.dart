import 'package:flutter/widgets.dart';
import 'add_action_card.dart';

typedef GridItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

class AppSliverGrid<T> extends StatelessWidget {
  const AppSliverGrid({
    super.key,
    required this.items,
    required this.itemBuilder,

    // Add card properties
    this.showAddCard = false,
    this.addCardTitle = 'Add New',
    this.addCardDescription = 'Create a new item',
    this.onAddTap,
    this.addCardIcon,
    this.addCardControl,
    this.addCardControlBuilder,

    // Responsive breakpoints
    this.largeDesktopBreakpoint = 1400,
    this.desktopBreakpoint = 1000,
    this.tabletBreakpoint = 650,

    // Responsive columns
    this.largeDesktopColumns = 4,
    this.desktopColumns = 3,
    this.tabletColumns = 2,
    this.mobileColumns = 1,

    // Grid spacing
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,

    // Card aspect ratios
    this.mobileChildAspectRatio = 2.8,
    this.childAspectRatio = 1.6,

    // Grid scrolling
    this.shrinkWrap = false,
    this.physics,
    this.padding = EdgeInsets.zero,
  }) : assert(
         !showAddCard || onAddTap != null,
         'onAddTap must be provided when showAddCard is true.',
       ),
       assert(
         addCardControl == null || addCardControlBuilder == null,
         'Use either addCardControl or addCardControlBuilder, not both.',
       );

  final List<T> items;
  final GridItemBuilder<T> itemBuilder;

  // Add card
  final bool showAddCard;
  final String addCardTitle;
  final String addCardDescription;
  final VoidCallback? onAddTap;
  final IconData? addCardIcon;
  final Widget? addCardControl;
  final WidgetBuilder? addCardControlBuilder;

  // Responsive breakpoints
  final double largeDesktopBreakpoint;
  final double desktopBreakpoint;
  final double tabletBreakpoint;

  // Responsive columns
  final int largeDesktopColumns;
  final int desktopColumns;
  final int tabletColumns;
  final int mobileColumns;

  // Grid spacing
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  // Card aspect ratios
  final double mobileChildAspectRatio;
  final double childAspectRatio;

  // Scrolling
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = _getCrossAxisCount(width);

        final itemCount = items.length + (showAddCard ? 1 : 0);

        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: crossAxisCount == mobileColumns
                ? mobileChildAspectRatio
                : childAspectRatio,
          ),
          itemBuilder: (context, index) {
            // Automatically generated AddActionCard.
            if (showAddCard && index == 0) {
              return AddActionCard(
                title: addCardTitle,
                description: addCardDescription,
                onTap: onAddTap!,
                icon: addCardIcon,
                control: addCardControlBuilder?.call(context) ?? addCardControl,
              );
            }

            final itemIndex = showAddCard ? index - 1 : index;

            return itemBuilder(context, items[itemIndex], itemIndex);
          },
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= largeDesktopBreakpoint) return largeDesktopColumns;
    if (width >= desktopBreakpoint) return desktopColumns;
    if (width >= tabletBreakpoint) return tabletColumns;
    return mobileColumns;
  }
}
