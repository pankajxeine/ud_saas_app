import 'package:flutter/material.dart';

class ChoiceChipWrapper<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T)? labelSelector; // optional for objects
  final T? initialValue;
  final ValueChanged<T> onSelected;

  const ChoiceChipWrapper({
    Key? key,
    required this.items,
    required this.onSelected,
    this.labelSelector,
    this.initialValue,
  }) : super(key: key);

  @override
  State<ChoiceChipWrapper<T>> createState() => _ChoiceChipWrapperState<T>();
}

class _ChoiceChipWrapperState<T> extends State<ChoiceChipWrapper<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant ChoiceChipWrapper<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _selectedValue = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: widget.items.map((item) {
        final isSelected = _selectedValue == item;

        // If labelSelector is provided, use it; otherwise fallback to toString()
        final label = widget.labelSelector != null
            ? widget.labelSelector!(item)
            : item.toString();

        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedValue = item;
            });
            widget.onSelected(item);
          },
        );
      }).toList(),
    );
  }
}
