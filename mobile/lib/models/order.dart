import 'product.dart';

class Order {
  final String id;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<OrderItemDetail> items;

  Order({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      items: (json['items'] as List? ?? [])
          .map((i) => OrderItemDetail.fromJson(i))
          .toList(),
    );
  }
}

class OrderItemDetail {
  final String productId;
  final int quantity;
  final double price;
  final Product? product;

  OrderItemDetail({
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItemDetail.fromJson(Map<String, dynamic> json) {
    return OrderItemDetail(
      productId: json['productId']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 
             (json['product']?['price'] as num?)?.toDouble() ?? 0.0,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}
