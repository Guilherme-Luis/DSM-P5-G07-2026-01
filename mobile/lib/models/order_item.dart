class OrderItem {
  final String productId;
  final int quantity;

  OrderItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
  };
}