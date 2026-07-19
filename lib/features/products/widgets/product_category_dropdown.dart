import 'package:flutter/material.dart';

import '../../../core/constants/product_categories.dart';

class ProductCategoryDropdown extends StatelessWidget {
  const ProductCategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: 'Categoría',
        prefixIcon: const Icon(
          Icons.category_outlined,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      items: ProductCategories.all
          .map(
            (category) => DropdownMenuItem(
              value: category,
              child: Text(category),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}