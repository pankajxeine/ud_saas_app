import 'package:flutter/material.dart';

const profile = [
  (title: 'Name', value: 'Alexandru'),
  (title: 'Username', value: 'nank1ro'),
];

class HeaderTrailingSheet extends StatelessWidget {
  const HeaderTrailingSheet({super.key, required this.body, required this.icon});

  final Widget body;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: body,
          ),
        ),
      ),
      child: icon,
    );
  }
}
