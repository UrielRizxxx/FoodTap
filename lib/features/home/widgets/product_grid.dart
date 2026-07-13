import 'package:flutter/material.dart';

import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: .72,
      children: const [
        ProductCard(
          title: 'Manzanas',
          seller: 'Frutería López',
          price: 35,
          imageUrl:
              'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce',
        ),
        ProductCard(
          title: 'Pan dulce',
          seller: 'Panadería El Trigo',
          price: 18,
          imageUrl:
              'https://images.unsplash.com/photo-1509440159596-0249088772ff',
        ),
        ProductCard(
          title: 'Naranjas',
          seller: 'Mercado Central',
          price: 28,
          imageUrl:
              'https://images.unsplash.com/photo-1547514701-42782101795e',
        ),
        ProductCard(
          title: 'Leche',
          seller: 'Abarrotes Juan',
          price: 29,
          imageUrl:
              'https://images.unsplash.com/photo-1550583724-b2692b85b150',
        ),
      ],
    );
  }
}