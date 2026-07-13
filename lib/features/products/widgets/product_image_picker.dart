import 'dart:io';

import 'package:flutter/material.dart';

class ProductImagePicker extends StatelessWidget {
  const ProductImagePicker({
    super.key,
    required this.image,
    required this.onTap,
  });

  final File? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: image == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 42,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Agregar fotografía',
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
    );
  }
}