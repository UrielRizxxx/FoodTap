import 'package:flutter/material.dart';

import '../../../core/widgets/custom_text_field.dart';

class ProductStockField extends StatelessWidget {
  const ProductStockField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      keyboardType: TextInputType.number,
      label: 'Cantidad disponible',
      icon: Icons.inventory_2_outlined,
    );
  }
}