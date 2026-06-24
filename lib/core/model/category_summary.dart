class CategorySummary {
  final String categoryName;
  final double totalAmount;
  final bool isIncome;
  final int transactionCount;

  CategorySummary({
    required this.categoryName,
    required this.totalAmount,
    required this.isIncome,
    required this.transactionCount,
  });
}
