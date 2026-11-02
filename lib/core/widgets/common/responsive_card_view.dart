import 'package:flutter/material.dart' hide Theme;
import 'package:ud_sass_app/ui/dashcn/theme.dart';

class ResponsiveCardField {
  const ResponsiveCardField({required this.label, required this.value});

  final String label;
  final String value;
}

/// Renders a responsive list of record cards with optional view and edit actions.
class ResponsiveCardView<T> extends StatelessWidget {
  const ResponsiveCardView({
    super.key,
    required this.items,
    required this.titleBuilder,
    required this.fieldsBuilder,
    this.onView,
    this.onEdit,
    this.subtitleBuilder,
  });

  final List<T> items;
  final String Function(T item) titleBuilder;
  final String? Function(T item)? subtitleBuilder;
  final List<ResponsiveCardField> Function(T item) fieldsBuilder;
  final void Function(T item)? onView;
  final void Function(T item)? onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final subtitle = subtitleBuilder?.call(item);
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleBuilder(item),
                            style: Theme.of(context).typography.medium,
                          ),
                          if (subtitle != null && subtitle.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: Theme.of(context).typography.small
                                  .copyWith(color: colors.mutedForeground),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (onView != null)
                      IconButton(
                        tooltip: 'View',
                        onPressed: () => onView!(item),
                        icon: const Icon(Icons.visibility_outlined),
                      ),
                    if (onEdit != null)
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () => onEdit!(item),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                  ],
                ),
                const Divider(height: 20),
                for (final field in fieldsBuilder(item))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 112,
                          child: Text(
                            field.label,
                            style: Theme.of(context).typography.small.copyWith(
                              color: colors.mutedForeground,
                            ),
                          ),
                        ),
                        Expanded(child: Text(field.value)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
