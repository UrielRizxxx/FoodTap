import 'package:flutter/material.dart';

import '../../../core/widgets/custom_text_field.dart';

class ProductNameField extends StatelessWidget {
  const ProductNameField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: 'Nombre del producto',
      icon: Icons.shopping_bag_outlined,
    );
  }
}