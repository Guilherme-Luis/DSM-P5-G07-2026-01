import '../core/api_client.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class OrderService {
  final ApiClient api;

  OrderService(this.api);

  Future<void> createOrder(List<CartItem> items) async {
    final body = {
      'items': items
          .map((item) => {
        'productId': item.product.id,
        'quantity': item.quantity,
      })
          .toList(),
    };

    await api.post('/orders', body: body);
  }

  Future<List<Order>> listMyOrders() async {
    final response = await api.get('/orders');
    final List data = response is List ? response : (response['orders'] ?? []);
    return data.map((e) => Order.fromJson(e)).toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await api.patch('/orders/$orderId/status', body: {
      'status': status.toUpperCase(),
    });
  }
  Future<void> deleteOrder(String orderId) async {
    await api.delete('/orders/$orderId');
  }
}
