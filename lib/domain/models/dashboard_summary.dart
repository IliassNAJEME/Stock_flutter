class ProductSalesSummary {
  const ProductSalesSummary({
    required this.productName,
    required this.quantitySold,
  });

  final String productName;
  final int quantitySold;
}

class CategorySalesSummary {
  const CategorySalesSummary({
    required this.categoryName,
    required this.amount,
  });

  final String categoryName;
  final double amount;
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalStockValue,
    required this.totalEntries,
    required this.totalSales,
    required this.topSellingProducts,
    required this.salesByCategory,
  });

  final double totalStockValue;
  final int totalEntries;
  final int totalSales;
  final List<ProductSalesSummary> topSellingProducts;
  final List<CategorySalesSummary> salesByCategory;
}
