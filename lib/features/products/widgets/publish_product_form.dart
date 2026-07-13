import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/primary_button.dart';
import 'product_category_dropdown.dart';
import 'product_description_field.dart';
import 'product_image_picker.dart';
import 'product_name_field.dart';
import 'product_price_field.dart';
import 'product_stock_field.dart';

class PublishProductForm extends StatefulWidget {
  const PublishProductForm({super.key});

  @override
  State<PublishProductForm> createState() =>
      _PublishProductFormState();
}

class _PublishProductFormState
    extends State<PublishProductForm> {
  final titleController = TextEditingController();

  final descriptionController = TextEditingController();

  final priceController = TextEditingController();

  final stockController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? selectedImage;

  String? selectedCategory;

  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductImagePicker(
          image: selectedImage,
          onTap: _pickImage,
        ),

        const SizedBox(height: 20),

        ProductNameField(
          controller: titleController,
        ),

        const SizedBox(height: 16),

        ProductDescriptionField(
          controller: descriptionController,
        ),

        const SizedBox(height: 16),

        ProductPriceField(
          controller: priceController,
        ),

        const SizedBox(height: 16),

        ProductStockField(
          controller: stockController,
        ),

        const SizedBox(height: 16),

        ProductCategoryDropdown(
          value: selectedCategory,
          onChanged: (value) {
            setState(() {
              selectedCategory = value;
            });
          },
        ),

        const SizedBox(height: 30),

        PrimaryButton(
          text: 'Publicar producto',
          isLoading: isLoading,
          onPressed: () {
            // TODO: Publicar producto
          },
        ),
      ],
    );
  }
}