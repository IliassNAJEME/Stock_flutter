import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../services/firestore_tenant_service.dart';

class FirestoreCategoryRepository implements CategoryRepository {
  FirestoreCategoryRepository(this._service);

  final FirestoreTenantService _service;

  @override
  Future<Category> addCategory({
    required String clientId,
    required String name,
  }) async {
    final document = _service.categories(clientId).doc();
    final now = DateTime.now();

    await document.set({
      'name': name,
      'createdAt': Timestamp.fromDate(now),
    });

    return Category(id: document.id, name: name, createdAt: now);
  }

  @override
  Stream<List<Category>> watchCategories(String clientId) {
    return _service
        .categories(clientId)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Category(
                  id: doc.id,
                  name: doc.data()['name'] as String? ?? '',
                  createdAt: (doc.data()['createdAt'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
                ),
              )
              .toList(),
        );
  }
}
