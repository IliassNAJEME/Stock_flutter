import '../../domain/models/dashboard_summary.dart';
import '../../domain/models/stock_movement.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/repositories/movement_repository.dart';
import '../../domain/repositories/product_repository.dart';

class FirestoreDashboardRepository implements DashboardRepository {
  FirestoreDashboardRepository({
    required MovementRepository movementRepository,
    required ProductRepository productRepository,
  })  : _movementRepository = movementRepository,
        _productRepository = productRepository;

  final MovementRepository _movementRepository;
  final ProductRepository _productRepository;

  @override
  Future<DashboardSummary> getSummary({
    required String clientId,
    required DateTime start,
    required DateTime end,
  }) async {
    final movements = await _movementRepository.getMovementsByDateRange(
      clientId: clientId,
      start: start,
      end: end,
    );
    final products = await _productRepository.getLowStockProducts(clientId);
    final totalStockValue =
        products.fold<double>(0, (sum, product) => sum + product.stockValue);

    final totalEntries = movements
        .where((movement) => movement.type == MovementType.entry)
        .fold<int>(0, (sum, movement) => sum + movement.quantity);

    final salesMovements = movements
        .where((movement) => movement.type == MovementType.sale)
        .toList();

    final totalSales = salesMovements.fold<int>(
      0,
      (sum, movement) => sum + movement.quantity,
    );

    final productSales = <String, int>{};
    final categorySales = <String, double>{};

    for (final movement in salesMovements) {
      productSales.update(
        movement.productName,
        (value) => value + movement.quantity,
        ifAbsent: () => movement.quantity,
      );
      categorySales.update(
        movement.categoryName,
        (value) => value + movement.totalAmount,
        ifAbsent: () => movement.totalAmount,
      );
    }

    final topSellingProducts = productSales.entries
        .map(
          (entry) => ProductSalesSummary(
            productName: entry.key,
            quantitySold: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

    final salesByCategory = categorySales.entries
        .map(
          (entry) => CategorySalesSummary(
            categoryName: entry.key,
            amount: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return DashboardSummary(
      totalStockValue: totalStockValue,
      totalEntries: totalEntries,
      totalSales: totalSales,
      topSellingProducts: topSellingProducts.take(5).toList(),
      salesByCategory: salesByCategory,
    );
  }
}
