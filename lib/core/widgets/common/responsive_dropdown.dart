import 'package:flutter/material.dart';

import '../../layouts/responsive.dart';

/// A compact outlined selector that uses a bottom sheet on mobile screens.
class ResponsiveDropdown<T> extends StatelessWidget {
  const ResponsiveDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.hintText,
    this.labelText,
    this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.foregroundColor,
    this.menuMaxHeight = 400,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final String? labelText;
  final String? title;
  final EdgeInsetsGeometry padding;
  final Color? foregroundColor;
  final double menuMaxHeight;

  DropdownMenuItem<T>? get _selectedItem {
    for (final item in items) {
      if (item.value == value) return item;
    }
    return null;
  }

  Future<void> _showMobileSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .7,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ...items.map(
                  (item) => ListTile(
                    selected: item.value == value,
                    title: item.child,
                    trailing: item.value == value
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () => Navigator.of(context).pop(item.value),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) onChanged?.call(selected);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = foregroundColor == null
        ? null
        : TextStyle(color: foregroundColor);

    final selectedChild = _selectedItem?.child ?? Text(hintText ?? '');

    if (ResponsiveLayout.isMobile(context)) {
      return OutlinedButton.icon(
        onPressed: () => _showMobileSheet(context),
        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
        label: Flexible(
          child: DefaultTextStyle(
            style: textStyle ?? DefaultTextStyle.of(context).style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: selectedChild,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          padding: padding,
          minimumSize: const Size(0, 48),
          tapTargetSize: MaterialTapTargetSize.padded,
          visualDensity: VisualDensity.standard,
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        maximumSize: WidgetStatePropertyAll(
          Size(280, menuMaxHeight),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      menuChildren: items
          .map(
            (item) => MenuItemButton(
              onPressed: () => onChanged?.call(item.value),
              trailingIcon: item.value == value
                  ? const Icon(Icons.check, size: 18)
                  : null,
              child: item.child,
            ),
          )
          .toList(),
      builder: (context, controller, child) {
        return OutlinedButton.icon(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: Icon(
            controller.isOpen
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            size: 20,
          ),
          label: Flexible(
            child: DefaultTextStyle(
              style: textStyle ?? DefaultTextStyle.of(context).style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: selectedChild,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor,
            padding: padding,
            minimumSize: const Size(0, 48),
            tapTargetSize: MaterialTapTargetSize.padded,
            visualDensity: VisualDensity.standard,
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      },
    );
  }
}
