import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/product_status.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/product_service.dart';
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

class _PublishProductFormState extends State<PublishProductForm> {
  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  final TextEditingController stockController =
      TextEditingController();

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
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null || !mounted) return;

      setState(() {
        selectedImage = File(image.path);
      });
    } catch (error) {
      debugPrint(
        'Error al seleccionar la imagen: $error',
      );

      if (!mounted) return;

      _showMessage(
        'No fue posible seleccionar la imagen.',
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  Future<void> _publishProduct() async {
    if (isLoading) return;

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    final price = double.tryParse(
      priceController.text.trim().replaceAll(',', '.'),
    );

    final stock = int.tryParse(
      stockController.text.trim(),
    );

    final user = AuthService.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Inicia sesión para publicar productos.',
      );
      return;
    }

    if (selectedImage == null) {
      _showMessage(
        'Agrega una fotografía del producto.',
      );
      return;
    }

    if (title.isEmpty) {
      _showMessage(
        'Escribe el nombre del producto.',
      );
      return;
    }

    if (description.isEmpty) {
      _showMessage(
        'Escribe una descripción del producto.',
      );
      return;
    }

    if (price == null) {
      _showMessage(
        'Ingresa un precio válido.',
      );
      return;
    }

    if (price <= 0) {
      _showMessage(
        'El precio debe ser mayor a 0.',
      );
      return;
    }

    if (stock == null) {
      _showMessage(
        'Ingresa una cantidad válida.',
      );
      return;
    }

    if (stock <= 0) {
      _showMessage(
        'La cantidad disponible debe ser mayor a 0.',
      );
      return;
    }

    if (selectedCategory == null) {
      _showMessage(
        'Selecciona una categoría.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final productId =
          ProductService.instance.newProductId;

      final imageUrl =
          await ProductService.instance.uploadProductImage(
        image: selectedImage!,
        productId: productId,
      );

      final now = DateTime.now();

      final product = ProductModel(
        id: productId,
        title: title,
        description: description,
        price: price,
        category: selectedCategory!,
        imageUrl: imageUrl,
        sellerId: user.uid,
        sellerName:
            user.displayName?.trim().isNotEmpty == true
                ? user.displayName!.trim()
                : user.email ?? 'Vendedor',
        sellerPhoto: user.photoURL,
        status: ProductStatus.pending,
        stock: stock,
        views: 0,
        favorites: 0,
        latitude: null,
        longitude: null,
        address: null,
        createdAt: now,
        updatedAt: now,
        approvedAt: null,
        approvedBy: null,
        rejectionReason: null,
      );

      await ProductService.instance.createProduct(
        product,
      );

      if (!mounted) return;

      _showMessage(
        'Producto enviado a revisión.',
      );

      context.go('/home');
    } catch (error, stackTrace) {
      debugPrint(
        'Error al publicar producto: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      _showMessage(
        'No fue posible publicar el producto.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Column(
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
            text: 'Publicar para revisión',
            isLoading: isLoading,
            onPressed: _publishProduct,
          ),
        ],
      ),
    );
  }
}