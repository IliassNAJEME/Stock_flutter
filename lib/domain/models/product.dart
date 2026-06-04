class Product {
  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.stockQuantity,
    required this.unitPrice,
    required this.reorderThreshold,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final int stockQuantity;
  final double unitPrice;
  final int reorderThreshold;
  final DateTime createdAt;

  bool get isBelowThreshold => stockQuantity <= reorderThreshold;
  double get stockValue => stockQuantity * unitPrice;
}
