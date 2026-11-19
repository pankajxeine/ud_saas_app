import 'package:flutter/material.dart';

class MobileModeNavRail extends StatefulWidget {
  const MobileModeNavRail({super.key});
  @override
  State<MobileModeNavRail> createState() => _MobileModeNavRailState();
}

class _MobileModeNavRailState extends State<MobileModeNavRail> {
  int selected = 0;
  static const items = [
    (Icons.home, 'Home'),
    (Icons.explore, 'Explore'),
    (Icons.library_music, 'Library'),
    (Icons.person, 'Profile'),
    (Icons.apps, 'App'),
  ];
  @override
  Widget build(BuildContext context) => Card(
    child: SizedBox(
      width: 500,
      height: 400,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                items[selected].$2,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          const Divider(height: 1),
          NavigationBar(
            selectedIndex: selected,
            onDestinationSelected: (index) => setState(() => selected = index),
            destinations: [
              for (final item in items)
                NavigationDestination(icon: Icon(item.$1), label: item.$2),
            ],
          ),
        ],
      ),
    ),
  );
}
