import 'package:flutter/material.dart';

class ProductDescriptionField extends StatelessWidget {
  const ProductDescriptionField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Descripción',
        alignLabelWithHint: true,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 80),
          child: Icon(Icons.description_outlined),
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
    );
  }
}