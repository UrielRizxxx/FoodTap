import 'package:flutter/material.dart';

import '../../../core/constants/product_categories.dart';
import 'category_chip.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ProductCategories.all.length,
        itemBuilder: (context, index) {
          final category = ProductCategories.all[index];

          return CategoryChip(
            title: category,
            selected: selectedCategory == category,
            onTap: () {
              onCategorySelected(category);
            },
          );
        },
      ),
    );
  }
}
