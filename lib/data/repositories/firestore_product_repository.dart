import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../services/firestore_tenant_service.dart';

class FirestoreProductRepository implements ProductRepository {
  FirestoreProductRepository(this._service);

  final FirestoreTenantService _service;

  @override
  Future<void> addProduct({
    required String clientId,
    required Product product,
  }) {
    return _service.products(clientId).doc(product.id).set({
      'name': product.name,
      'categoryId': product.categoryId,
      'categoryName': product.categoryName,
      'stockQuantity': product.stockQuantity,
      'unitPrice': product.unitPrice,
      'reorderThreshold': product.reorderThreshold,
      'createdAt': Timestamp.fromDate(product.createdAt),
    });
  }

  @override
  Future<List<Product>> getLowStockProducts(String clientId) async {
    final snapshot = await _service.products(clientId).get();
    final products = snapshot.docs.map(_mapProduct).toList();
    return products.where((product) => product.isBelowThreshold).toList()
      ..sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));
  }

  @override
  Future<void> updateProductStock({
    required String clientId,
    required String productId,
    required int newStock,
  }) {
    return _service.products(clientId).doc(productId).update({
      'stockQuantity': newStock,
    });
  }

  @override
  Stream<List<Product>> watchProducts(String clientId) {
    return _service
        .products(clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapProduct).toList());
  }

  Product _mapProduct(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Product(
      id: doc.id,
      name: data['name'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      stockQuantity: (data['stockQuantity'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
      reorderThreshold: (data['reorderThreshold'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
