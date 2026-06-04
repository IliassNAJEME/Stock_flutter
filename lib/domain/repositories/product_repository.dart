import '../models/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchProducts(String clientId);
  Future<void> addProduct({
    required String clientId,
    required Product product,
  });
  Future<void> updateProductStock({
    required String clientId,
    required String productId,
    required int newStock,
  });
  Future<List<Product>> getLowStockProducts(String clientId);
}
