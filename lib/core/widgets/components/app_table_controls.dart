import 'package:flutter/material.dart';

/// A search field option shown in [AppTableControls].
class AppTableSearchField {
  const AppTableSearchField({required this.value, required this.label});

  final String value;
  final String label;
}

/// Responsive controls for tables, lists and page content.
///
/// Desktop:
/// Search (left) | Filter + Add (right)
///
/// Tablet / Mobile:
/// Search (left) | Filter icon + Add icon (right)
class AppTableControls extends StatelessWidget {
  const AppTableControls({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.searchHint = 'Search',
    this.searchFields = const <AppTableSearchField>[],
    this.selectedSearchField,
    this.onSearchFieldChanged,
    this.showSearchBar = true,
    this.showSearchToggle = true,
    this.searchExpanded = false,
    this.onToggleSearch,
    this.showFilterButton = true,
    this.onFilterPressed,
    this.filterLabel = 'Filter',
    this.hasActiveFilters = false,
    this.showAddButton = false,
    this.onAdd,
    this.addLabel = 'Add',
    this.addTooltip = 'Add',
    this.compactBreakpoint = 640,
    this.searchMaxWidth = 420,
    this.searchMinWidth = 180,
  });

  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final String searchHint;

  final List<AppTableSearchField> searchFields;
  final String? selectedSearchField;
  final ValueChanged<String>? onSearchFieldChanged;

  final bool showSearchBar;
  final bool showSearchToggle;
  final bool searchExpanded;
  final VoidCallback? onToggleSearch;

  final bool showFilterButton;
  final VoidCallback? onFilterPressed;
  final String filterLabel;
  final bool hasActiveFilters;

  final bool showAddButton;
  final VoidCallback? onAdd;
  final String addLabel;
  final String addTooltip;

  final double compactBreakpoint;
  final double searchMaxWidth;
  final double searchMinWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = width < compactBreakpoint;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LEFT: Search
            if (showSearchBar)
              Flexible(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: searchMaxWidth,
                      minWidth: searchMinWidth.clamp(0, width),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: _buildSearchBar(context),
                    ),
                  ),
                ),
              )
            else
              const Spacer(),

            const SizedBox(width: 12),

            // RIGHT: Filter and Add actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showFilterButton) _buildFilterButton(context, compact),

                if (showAddButton) ...[
                  const SizedBox(width: 8),
                  _buildAddButton(compact),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // Filter Button
  // ------------------------------------------------------------

  Widget _buildFilterButton(BuildContext context, bool compact) {
    final scheme = Theme.of(context).colorScheme;

    if (compact) {
      return Tooltip(
        message: hasActiveFilters ? '$filterLabel active' : filterLabel,
        child: IconButton(
          onPressed: onFilterPressed,
          style: IconButton.styleFrom(
            backgroundColor: hasActiveFilters
                ? scheme.secondaryContainer
                : scheme.surfaceContainerHighest,
            foregroundColor: hasActiveFilters
                ? scheme.onSecondaryContainer
                : scheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: Icon(
            hasActiveFilters
                ? Icons.filter_alt_rounded
                : Icons.filter_alt_outlined,
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onFilterPressed,
      icon: Icon(
        hasActiveFilters ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
        size: 18,
      ),
      label: Text(hasActiveFilters ? '$filterLabel active' : filterLabel),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ------------------------------------------------------------
  // Add Button
  // ------------------------------------------------------------

  Widget _buildAddButton(bool compact) {
    if (compact) {
      return IconButton.filled(
        tooltip: addTooltip,
        onPressed: onAdd,
        icon: const Icon(Icons.add_rounded),
      );
    }

    return FilledButton.icon(
      onPressed: onAdd,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: Text(addLabel),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ------------------------------------------------------------
  // Search Bar
  // ------------------------------------------------------------

  Widget _buildSearchBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final field = searchFields.isEmpty
        ? null
        : (selectedSearchField ?? searchFields.first.value);

    return SearchBar(
      controller: searchController,
      onChanged: onSearchChanged,
      onSubmitted: onSearchSubmitted,
      hintText: searchHint,
      leading: const Icon(Icons.search_rounded, size: 19),
      trailing: [
        if (searchController?.text.isNotEmpty ?? false)
          IconButton(
            tooltip: 'Clear search',
            onPressed: () {
              searchController?.clear();
              onSearchChanged?.call('');
            },
            icon: const Icon(Icons.close, size: 18),
          ),

        if (field != null) ...[
          SizedBox(
            height: 24,
            child: VerticalDivider(thickness: 1, color: scheme.outlineVariant),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: field,
              borderRadius: BorderRadius.circular(12),
              isDense: true,
              items: [
                for (final option in searchFields)
                  DropdownMenuItem(
                    value: option.value,
                    child: Text(option.label),
                  ),
              ],
              onChanged: onSearchFieldChanged == null
                  ? null
                  : (value) {
                      if (value != null) {
                        onSearchFieldChanged!(value);
                      }
                    },
            ),
          ),
        ],
      ],
      textInputAction: TextInputAction.search,
      elevation: const WidgetStatePropertyAll(0),
      side: WidgetStatePropertyAll(BorderSide(color: scheme.outlineVariant)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 10),
      ),
      constraints: const BoxConstraints(minHeight: 48),
    );
  }
}
