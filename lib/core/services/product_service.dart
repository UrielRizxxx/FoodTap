import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/product_status.dart';
import '../models/product_model.dart';
import 'cloudinary_service.dart';

class ProductService {
  ProductService._();

  static final ProductService instance = ProductService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get products =>
      _firestore.collection('products');

  String get newProductId => products.doc().id;

  Future<String> uploadProductImage({
    required File image,
    required String productId,
  }) async {
    return CloudinaryService.instance.uploadProductImage(
      image: image,
      productId: productId,
    );
  }

  Future<void> createProduct(ProductModel product) async {
    await products.doc(product.id).set(
          product.toMap(),
        );
  }

  Future<ProductModel?> getProduct(String id) async {
    final document = await products.doc(id).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return ProductModel.fromMap(
      document.data()!,
    );
  }

  Future<void> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    await products.doc(id).update(data);
  }

  Future<void> suspendProduct(String id) async {
    await products.doc(id).update({
      'status': ProductStatus.suspended,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> reactivateProduct(String id) async {
    await products.doc(id).update({
      'status': ProductStatus.approved,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteProduct(String id) async {
    await products.doc(id).delete();
  }

  Stream<List<ProductModel>> getApprovedProducts() {
    return products
        .where(
          'status',
          isEqualTo: ProductStatus.approved,
        )
        .snapshots()
        .map(
          (snapshot) {
            final items = snapshot.docs
                .map(
                  (doc) => ProductModel.fromMap(
                    doc.data(),
                  ),
                )
                .toList();

            items.sort(
              (a, b) => b.createdAt.compareTo(a.createdAt),
            );

            return items;
          },
        );
  }

  Stream<List<ProductModel>> getPendingProducts() {
    return products
        .where(
          'status',
          isEqualTo: ProductStatus.pending,
        )
        .snapshots()
        .map(
          (snapshot) {
            final items = snapshot.docs
                .map(
                  (doc) => ProductModel.fromMap(
                    doc.data(),
                  ),
                )
                .toList();

            items.sort(
              (a, b) => b.createdAt.compareTo(a.createdAt),
            );

            return items;
          },
        );
  }

  Stream<List<ProductModel>> getSellerProducts(
    String sellerId,
  ) {
    return products
        .where(
          'sellerId',
          isEqualTo: sellerId,
        )
        .snapshots()
        .map(
          (snapshot) {
            final items = snapshot.docs
                .map(
                  (doc) => ProductModel.fromMap(
                    doc.data(),
                  ),
                )
                .toList();

            items.sort(
              (a, b) => b.createdAt.compareTo(a.createdAt),
            );

            return items;
          },
        );
  }
}