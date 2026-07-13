import 'package:flutter/material.dart';

import '../../../core/widgets/custom_text_field.dart';

class ProductPriceField extends StatelessWidget {
  const ProductPriceField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      label: 'Precio',
      icon: Icons.attach_money,
    );
  }
}