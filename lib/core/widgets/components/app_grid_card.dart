import 'package:flutter/material.dart';

import 'add_action_card.dart';

typedef GridItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

enum AddCardPosition { first, last }

class AppSliverGrid<T> extends StatelessWidget {
  const AppSliverGrid({
    super.key,
    required this.items,
    required this.itemBuilder,

    // Add card
    this.showAddCard = false,
    this.addCardTitle = 'Add New',
    this.addCardDescription = 'Create a new item',
    this.onAddTap,
    this.addCardIcon,
    this.addCardControl,
    this.addCardControlBuilder,
    this.addCardPosition = AddCardPosition.first,

    // Responsive breakpoints
    this.largeDesktopBreakpoint = 1400,
    this.desktopBreakpoint = 1000,
    this.tabletBreakpoint = 650,

    // Responsive columns
    this.largeDesktopColumns = 4,
    this.desktopColumns = 3,
    this.tabletColumns = 2,
    this.mobileColumns = 1,

    // Grid sizing
    this.minCardWidth = 240,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.mobileChildAspectRatio = 2.4,
    this.childAspectRatio = 1.8,
    this.mainAxisExtent,

    // Scrolling
    this.shrinkWrap = false,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
  }) : assert(
         !showAddCard || onAddTap != null,
         'onAddTap must be provided when showAddCard is true.',
       ),
       assert(
         addCardControl == null || addCardControlBuilder == null,
         'Use either addCardControl or addCardControlBuilder, not both.',
       ),
       assert(
         largeDesktopBreakpoint >= desktopBreakpoint &&
             desktopBreakpoint >= tabletBreakpoint &&
             tabletBreakpoint > 0,
         'Breakpoints must be in descending order.',
       ),
       assert(
         largeDesktopColumns > 0 &&
             desktopColumns > 0 &&
             tabletColumns > 0 &&
             mobileColumns > 0,
         'Column counts must be greater than zero.',
       ),
       assert(minCardWidth > 0),
       assert(mainAxisSpacing >= 0 && crossAxisSpacing >= 0),
       assert(mobileChildAspectRatio > 0 && childAspectRatio > 0),
       assert(mainAxisExtent == null || mainAxisExtent > 0);

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
  final AddCardPosition addCardPosition;

  // Responsive breakpoints
  final double largeDesktopBreakpoint;
  final double desktopBreakpoint;
  final double tabletBreakpoint;

  // Responsive columns
  final int largeDesktopColumns;
  final int desktopColumns;
  final int tabletColumns;
  final int mobileColumns;

  // Grid sizing
  final double minCardWidth;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double mobileChildAspectRatio;
  final double childAspectRatio;
  final double? mainAxisExtent;

  // Scrolling
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final crossAxisCount = _getCrossAxisCount(availableWidth);

        // Only show the add card when its callback is available.
        // The constructor assertion also catches incorrect usage in debug.
        final hasAddCard = showAddCard && onAddTap != null;

        final itemCount = items.length + (hasAddCard ? 1 : 0);

        final isMobile = availableWidth < tabletBreakpoint;

        final aspectRatio = isMobile
            ? mobileChildAspectRatio
            : childAspectRatio;

        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          clipBehavior: clipBehavior,
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: aspectRatio,
            mainAxisExtent: mainAxisExtent,
          ),
          itemBuilder: (context, index) {
            final isAddCard =
                hasAddCard &&
                ((addCardPosition == AddCardPosition.first && index == 0) ||
                    (addCardPosition == AddCardPosition.last &&
                        index == items.length));

            if (isAddCard) {
              return AddActionCard(
                title: addCardTitle,
                description: addCardDescription,
                onTap: onAddTap ?? () {},
                icon: addCardIcon,
                control: addCardControlBuilder?.call(context) ?? addCardControl,
              );
            }

            final itemIndex =
                hasAddCard && addCardPosition == AddCardPosition.first
                ? index - 1
                : index;

            return itemBuilder(context, items[itemIndex], itemIndex);
          },
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    final configuredColumns = width >= largeDesktopBreakpoint
        ? largeDesktopColumns
        : width >= desktopBreakpoint
        ? desktopColumns
        : width >= tabletBreakpoint
        ? tabletColumns
        : mobileColumns;

    // Do not create columns that would make cards narrower than
    // the configured minimum width.
    final widthLimitedColumns =
        ((width + crossAxisSpacing) / (minCardWidth + crossAxisSpacing))
            .floor()
            .clamp(1, configuredColumns)
            .toInt();

    return widthLimitedColumns;
  }
}
