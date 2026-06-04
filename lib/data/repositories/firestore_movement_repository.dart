import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/stock_movement.dart';
import '../../domain/repositories/movement_repository.dart';
import '../services/firestore_tenant_service.dart';

class FirestoreMovementRepository implements MovementRepository {
  FirestoreMovementRepository(this._service);

  final FirestoreTenantService _service;

  @override
  Future<void> addMovement({
    required String clientId,
    required StockMovement movement,
  }) {
    return _service.movements(clientId).doc(movement.id).set({
      'productId': movement.productId,
      'productName': movement.productName,
      'categoryId': movement.categoryId,
      'categoryName': movement.categoryName,
      'quantity': movement.quantity,
      'unitPrice': movement.unitPrice,
      'type': movement.type.name,
      'createdAt': Timestamp.fromDate(movement.createdAt),
    });
  }

  @override
  Future<List<StockMovement>> getMovementsByDateRange({
    required String clientId,
    required DateTime start,
    required DateTime end,
  }) async {
    final snapshot = await _service
        .movements(clientId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    return snapshot.docs.map(_mapMovement).toList();
  }

  @override
  Stream<List<StockMovement>> watchMovements(String clientId) {
    return _service
        .movements(clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapMovement).toList());
  }

  StockMovement _mapMovement(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return StockMovement(
      id: doc.id,
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
      type: (data['type'] as String? ?? 'entry') == 'sale'
          ? MovementType.sale
          : MovementType.entry,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
