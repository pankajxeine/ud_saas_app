import 'package:flutter/material.dart';

class ProductFilterContent extends StatefulWidget {
  const ProductFilterContent({
    super.key,
    this.initialCategory,
    this.initialPriceRange = const RangeValues(0, 1000),
    this.initialInStockOnly = false,
    this.initialSortBy = 'name',
    required this.onApply,
    required this.onReset,
  });

  final String? initialCategory;
  final RangeValues initialPriceRange;
  final bool initialInStockOnly;
  final String initialSortBy;

  final void Function({
    required String? category,
    required RangeValues priceRange,
    required bool inStockOnly,
    required String sortBy,
  })
  onApply;

  final VoidCallback onReset;

  @override
  State<ProductFilterContent> createState() => _ProductFilterContentState();
}

class _ProductFilterContentState extends State<ProductFilterContent> {
  late String? _category;
  late RangeValues _priceRange;
  late bool _inStockOnly;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    _category = widget.initialCategory;
    _priceRange = widget.initialPriceRange;
    _inStockOnly = widget.initialInStockOnly;
    _sortBy = widget.initialSortBy;
  }

  @override
  void didUpdateWidget(covariant ProductFilterContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialCategory != widget.initialCategory ||
        oldWidget.initialPriceRange != widget.initialPriceRange ||
        oldWidget.initialInStockOnly != widget.initialInStockOnly ||
        oldWidget.initialSortBy != widget.initialSortBy) {
      _initialize();
    }
  }

  void _reset() {
    setState(() {
      _category = null;
      _priceRange = const RangeValues(0, 5000);
      _inStockOnly = false;
      _sortBy = 'Recommended';
    });

    widget.onReset();
  }

  void _apply() {
    widget.onApply(
      category: _category,
      priceRange: _priceRange,
      inStockOnly: _inStockOnly,
      sortBy: _sortBy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFilterTitle('Category'),
        Wrap(
          spacing: 8,
          children: [
            _categoryChip('Electronics'),
            _categoryChip('Fashion'),
            _categoryChip('Furniture'),
          ],
        ),

        const SizedBox(height: 24),

        _buildFilterTitle('Price range'),
        Row(
          children: [
            Text('₹${_priceRange.start.round()}'),
            const Spacer(),
            Text('₹${_priceRange.end.round()}'),
          ],
        ),
        RangeSlider(
          min: 0,
          max: 5000,
          divisions: 50,
          values: _priceRange,
          onChanged: (value) {
            setState(() => _priceRange = value);
          },
        ),

        const SizedBox(height: 16),

        _buildFilterTitle('Availability'),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('In stock only'),
          value: _inStockOnly,
          onChanged: (value) {
            setState(() => _inStockOnly = value ?? false);
          },
        ),

        const SizedBox(height: 16),

        _buildFilterTitle('Sort by'),
        DropdownButtonFormField<String>(
          value: _sortBy,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'Recommended', child: Text('Recommended')),
            DropdownMenuItem(
              value: 'Price: Low to High',
              child: Text('Price: Low to High'),
            ),
            DropdownMenuItem(
              value: 'Price: High to Low',
              child: Text('Price: High to Low'),
            ),
            DropdownMenuItem(value: 'Name', child: Text('Name')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _sortBy = value);
            }
          },
        ),

        const SizedBox(height: 28),

        FilledButton(onPressed: _apply, child: const Text('Apply filters')),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: _reset, child: const Text('Reset filters')),
      ],
    );
  }

  Widget _buildFilterTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _categoryChip(String category) {
    final selected = _category == category;

    return ChoiceChip(
      label: Text(category),
      selected: selected,
      onSelected: (value) {
        setState(() {
          _category = value ? category : null;
        });
      },
    );
  }
}
