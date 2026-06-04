enum MovementType { entry, sale }

class StockMovement {
  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.categoryName,
    required this.quantity,
    required this.unitPrice,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String productName;
  final String categoryId;
  final String categoryName;
  final int quantity;
  final double unitPrice;
  final MovementType type;
  final DateTime createdAt;

  double get totalAmount => quantity * unitPrice;
}
