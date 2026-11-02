import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------
class StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? change; // e.g. "+12%"
  final bool positive;
  final VoidCallback? onTap;

  const StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.change,
    this.positive = true,
    this.onTap,
  });
}

// ---------------------------------------------------------------------
// Lets the horizontal list be dragged with mouse/trackpad on web & desktop
// (touch devices work by default)
// ---------------------------------------------------------------------
class _DragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

// ---------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    void open(String name) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Open $name')));

    final items = [
      StatItem(
        title: 'Total sales',
        value: '₹1.2L',
        icon: Icons.currency_rupee,
        color: Colors.green,
        change: '+12%',
        onTap: () => open('Total sales'),
      ),
      StatItem(
        title: 'Orders',
        value: '342',
        icon: Icons.shopping_bag_outlined,
        color: Colors.blue,
        change: '+5%',
        onTap: () => open('Orders'),
      ),
      StatItem(
        title: 'Customers',
        value: '1,208',
        icon: Icons.people_outline,
        color: Colors.orange,
        change: '+8%',
        onTap: () => open('Customers'),
      ),
      StatItem(
        title: 'Refunds',
        value: '14',
        icon: Icons.assignment_return_outlined,
        color: Colors.red,
        change: '-3%',
        positive: false,
        onTap: () => open('Refunds'),
      ),
      StatItem(
        title: 'Sales agents',
        value: '27',
        icon: Icons.badge_outlined,
        color: Colors.purple,
        onTap: () => open('Sales agents'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Overview',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 12),
          StatsStrip(items: items),
          // ...rest of your page below
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Strip: fills the width when everything fits, scrolls horizontally when not
// ---------------------------------------------------------------------
class StatsStrip extends StatelessWidget {
  final List<StatItem> items;
  final double cardWidth;
  final double cardHeight;
  final double gap;
  final double horizontalPadding;

  const StatsStrip({
    super.key,
    required this.items,
    this.cardWidth = 160,
    this.cardHeight = 140,
    this.gap = 12,
    this.horizontalPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final needed = items.length * cardWidth +
            (items.length - 1) * gap +
            horizontalPadding * 2;

        // Wide screen: cards share the full width evenly, no scrolling
        if (needed <= constraints.maxWidth) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: SizedBox(
              height: cardHeight,
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) SizedBox(width: gap),
                    Expanded(child: StatCard(item: items[i])),
                  ],
                ],
              ),
            ),
          );
        }

        // Small screen: fixed-width cards in a horizontal list.
        // The last visible card is cut off, which hints that it scrolls.
        return SizedBox(
          height: cardHeight,
          child: ScrollConfiguration(
            behavior: _DragScrollBehavior(),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(width: gap),
              itemBuilder: (_, i) => SizedBox(
                width: cardWidth,
                child: StatCard(item: items[i]),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------
// Card
// ---------------------------------------------------------------------
class StatCard extends StatelessWidget {
  final StatItem item;
  const StatCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Material + InkWell gives the ripple and keeps it clipped to the rounded border
    return Material(
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: item.color.withAlpha(30),
                child: Icon(item.icon, size: 18, color: item.color),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (item.change != null)
                    Row(
                      children: [
                        Icon(
                          item.positive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 12,
                          color: item.positive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          item.change!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: item.positive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
