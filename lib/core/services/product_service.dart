import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductService {
  ProductService._();

  static final ProductService instance = ProductService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get products =>
      _firestore.collection('products');

  Future<void> createProduct(ProductModel product) async {
    await products.doc(product.id).set(
          product.toMap(),
        );
  }

  Future<ProductModel?> getProduct(String id) async {
    final document = await products.doc(id).get();

    if (!document.exists) {
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
    await products.doc(id).update(
          data,
        );
  }

  Future<void> deleteProduct(String id) async {
    await products.doc(id).delete();
  }

  Stream<List<ProductModel>> getApprovedProducts() {
    return products
        .where('status', isEqualTo: 'approved')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProductModel.fromMap(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Stream<List<ProductModel>> getPendingProducts() {
    return products
        .where('status', isEqualTo: 'pending')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProductModel.fromMap(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Stream<List<ProductModel>> getSellerProducts(
    String sellerId,
  ) {
    return products
        .where('sellerId', isEqualTo: sellerId)
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProductModel.fromMap(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }
}