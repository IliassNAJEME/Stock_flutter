import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/stock_alert_service.dart';
import '../../domain/models/product.dart';
import '../../domain/models/stock_movement.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/movement_repository.dart';
import '../../domain/repositories/product_repository.dart';
import 'auth_providers.dart';

class InventoryController {
  InventoryController({
    required AuthRepository authRepository,
    required CategoryRepository categoryRepository,
    required ProductRepository productRepository,
    required MovementRepository movementRepository,
    required StockAlertService stockAlertService,
    required Ref ref,
  })  : _authRepository = authRepository,
        _categoryRepository = categoryRepository,
        _productRepository = productRepository,
        _movementRepository = movementRepository,
        _stockAlertService = stockAlertService,
        _ref = ref;

  final AuthRepository _authRepository;
  final CategoryRepository _categoryRepository;
  final ProductRepository _productRepository;
  final MovementRepository _movementRepository;
  final StockAlertService _stockAlertService;
  final Ref _ref;

  String get _clientId {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw StateError('Utilisateur non connecte.');
    }
    return user.id;
  }

  Future<void> addCategory(String name) async {
    await _categoryRepository.addCategory(
      clientId: _clientId,
      name: name.trim(),
    );
  }

  Future<void> addProduct({
    required String name,
    required String categoryId,
    required String categoryName,
    required int initialStock,
    required double unitPrice,
    required int reorderThreshold,
  }) async {
    final product = Product(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      categoryId: categoryId,
      categoryName: categoryName,
      stockQuantity: initialStock,
      unitPrice: unitPrice,
      reorderThreshold: reorderThreshold,
      createdAt: DateTime.now(),
    );

    await _productRepository.addProduct(
      clientId: _clientId,
      product: product,
    );

    if (initialStock > 0) {
      await addMovement(
        product: product,
        quantity: initialStock,
        type: MovementType.entry,
      );
    }
  }

  Future<void> addMovement({
    required Product product,
    required int quantity,
    required MovementType type,
  }) async {
    final delta = type == MovementType.entry ? quantity : -quantity;
    final newStock = product.stockQuantity + delta;

    if (newStock < 0) {
      throw StateError('Stock insuffisant pour cette vente.');
    }

    final movement = StockMovement(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      productId: product.id,
      productName: product.name,
      categoryId: product.categoryId,
      categoryName: product.categoryName,
      quantity: quantity,
      unitPrice: product.unitPrice,
      type: type,
      createdAt: DateTime.now(),
    );

    await _movementRepository.addMovement(
      clientId: _clientId,
      movement: movement,
    );
    await _productRepository.updateProductStock(
      clientId: _clientId,
      productId: product.id,
      newStock: newStock,
    );

    _ref.invalidate(dashboardSummaryProvider);
    _ref.invalidate(lowStockProductsProvider);
  }

  Future<String> sendLowStockNotification() async {
    final products = await _productRepository.getLowStockProducts(_clientId);
    return _stockAlertService.notifyLowStock(products);
  }
}
