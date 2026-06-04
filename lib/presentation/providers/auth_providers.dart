import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/app_dio.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/firestore_category_repository.dart';
import '../../data/repositories/firestore_dashboard_repository.dart';
import '../../data/repositories/firestore_movement_repository.dart';
import '../../data/repositories/firestore_product_repository.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/services/firestore_tenant_service.dart';
import '../../data/services/stock_alert_service.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/category.dart';
import '../../domain/models/dashboard_summary.dart';
import '../../domain/models/product.dart';
import '../../domain/models/stock_movement.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/repositories/movement_repository.dart';
import '../../domain/repositories/product_repository.dart';
import 'inventory_controller.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final dioProvider = Provider((ref) => AppDio().client);

final authServiceProvider = Provider((ref) {
  return FirebaseAuthService(ref.watch(firebaseAuthProvider));
});

final tenantServiceProvider = Provider((ref) {
  return FirestoreTenantService(ref.watch(firestoreProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(ref.watch(authServiceProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return FirestoreCategoryRepository(ref.watch(tenantServiceProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirestoreProductRepository(ref.watch(tenantServiceProvider));
});

final movementRepositoryProvider = Provider<MovementRepository>((ref) {
  return FirestoreMovementRepository(ref.watch(tenantServiceProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return FirestoreDashboardRepository(
    movementRepository: ref.watch(movementRepositoryProvider),
    productRepository: ref.watch(productRepositoryProvider),
  );
});

final stockAlertServiceProvider = Provider((ref) {
  return StockAlertService(ref.watch(dioProvider));
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentClientIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider).asData?.value;
  return authState?.id;
});

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final clientId = ref.watch(currentClientIdProvider);
  if (clientId == null) {
    return Stream.value(const []);
  }

  return ref.watch(categoryRepositoryProvider).watchCategories(clientId);
});

final productsProvider = StreamProvider<List<Product>>((ref) {
  final clientId = ref.watch(currentClientIdProvider);
  if (clientId == null) {
    return Stream.value(const []);
  }

  return ref.watch(productRepositoryProvider).watchProducts(clientId);
});

final movementsProvider = StreamProvider<List<StockMovement>>((ref) {
  final clientId = ref.watch(currentClientIdProvider);
  if (clientId == null) {
    return Stream.value(const []);
  }

  return ref.watch(movementRepositoryProvider).watchMovements(clientId);
});

final selectedRangeProvider =
    NotifierProvider<SelectedRangeNotifier, DateTimeRange>(
  SelectedRangeNotifier.new,
);

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final clientId = ref.watch(currentClientIdProvider);
  if (clientId == null) {
    return const DashboardSummary(
      totalStockValue: 0,
      totalEntries: 0,
      totalSales: 0,
      topSellingProducts: [],
      salesByCategory: [],
    );
  }

  final range = ref.watch(selectedRangeProvider);
  return ref.watch(dashboardRepositoryProvider).getSummary(
        clientId: clientId,
        start: range.start,
        end: range.end,
      );
});

final lowStockProductsProvider = FutureProvider<List<Product>>((ref) async {
  final clientId = ref.watch(currentClientIdProvider);
  if (clientId == null) {
    return const [];
  }

  return ref.watch(productRepositoryProvider).getLowStockProducts(clientId);
});

final inventoryControllerProvider = Provider((ref) {
  return InventoryController(
    authRepository: ref.watch(authRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
    productRepository: ref.watch(productRepositoryProvider),
    movementRepository: ref.watch(movementRepositoryProvider),
    stockAlertService: ref.watch(stockAlertServiceProvider),
    ref: ref,
  );
});

class SelectedRangeNotifier extends Notifier<DateTimeRange> {
  @override
  DateTimeRange build() {
    final now = DateTime.now();
    return DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
  }

  void update(DateTimeRange range) {
    state = range;
  }
}
