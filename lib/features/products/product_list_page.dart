import 'package:flutter/material.dart';

import '../../../core/widgets/components/app_filter_sheet.dart';
import 'product_filter_content.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.inStock,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final bool inStock;
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  bool _showFilters = false;

  // Change this flag to control the filter presentation.
  AppFilterPresentation _filterPresentation = AppFilterPresentation.split;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppFilterSheet(
        open: _showFilters,
        presentation: _filterPresentation,
        mode: AppFilterSheetMode.auto,
        width: 360,
        title: 'Product Filters',
        onClose: () {
          setState(() => _showFilters = false);
        },
        mainContent: _buildProductContent(),
        child: ProductFilterContent(
          onApply:
              ({
                required String? category,
                required RangeValues priceRange,
                required bool inStockOnly,
                required String sortBy,
              }) {
                // setState(() {
                //   _selectedCategory = category;
                //   _priceRange = priceRange;
                //   _inStockOnly = inStockOnly;
                //   _sortBy = sortBy;
                //   _showFilters = false;
                // });
              },
          onReset: () => {},
        ),
      ),
    );
  }

  Widget _buildProductContent() {
    return Column(
      children: [
        AppBar(
          title: const Text('Products'),
          actions: [
            IconButton(
              tooltip: 'Filters',
              onPressed: () {
                setState(() => _showFilters = !_showFilters);
              },
              icon: const Icon(Icons.filter_list),
            ),
            PopupMenuButton<AppFilterPresentation>(
              tooltip: 'Filter layout',
              initialValue: _filterPresentation,
              onSelected: (value) {
                setState(() {
                  _filterPresentation = value;
                });
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: AppFilterPresentation.split,
                  child: Text('Split panel'),
                ),
                PopupMenuItem(
                  value: AppFilterPresentation.overlay,
                  child: Text('Overlay'),
                ),
                PopupMenuItem(
                  value: AppFilterPresentation.auto,
                  child: Text('Automatic'),
                ),
              ],
            ),
          ],
        ),
        const Expanded(child: Center(child: Text('Product list goes here'))),
      ],
    );
  }
}
