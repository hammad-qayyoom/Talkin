class PurchaseRequest {
  final double amount;
  final String userId;
  final String paymentType;
  final List<String> productIds;

  PurchaseRequest({
    required this.amount,
    required this.userId,
    required this.paymentType,
    required this.productIds,
  });
}
