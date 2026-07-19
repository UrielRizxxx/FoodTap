import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/product_model.dart';
import '../../../core/services/product_service.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.searchText,
    required this.selectedCategory,
  });

  final String searchText;
  final String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProductModel>>(
      stream: ProductService.instance.getApprovedProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
                ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'No fue posible cargar los productos.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        final products = snapshot.data ?? [];

        final normalizedSearch =
            searchText.trim().toLowerCase();

        final filteredProducts = products.where((product) {
          final matchesSearch =
              normalizedSearch.isEmpty ||
              product.title
                  .toLowerCase()
                  .contains(normalizedSearch) ||
              product.description
                  .toLowerCase()
                  .contains(normalizedSearch) ||
              product.sellerName
                  .toLowerCase()
                  .contains(normalizedSearch);

          final matchesCategory =
              selectedCategory == null ||
              product.category == selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();

        if (filteredProducts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 18),
                Text(
                  'No hay productos disponibles',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Cuando haya publicaciones aprobadas\naparecerán aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.only(
            bottom: 20,
          ),
          itemCount: filteredProducts.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final product = filteredProducts[index];

            return ProductCard(
              title: product.title,
              seller: product.sellerName,
              price: product.price,
              imageUrl: product.imageUrl,
              onTap: () {
                context.push(
                  '/product-detail',
                  extra: product,
                );
              },
            );
          },
        );
      },
    );
  }
}