import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrdersProvider extends ChangeNotifier {
  final OrderService orderService;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  OrdersProvider({required this.orderService});

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await orderService.listMyOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String orderId, String status) async {
    try {
      await orderService.updateOrderStatus(orderId, status);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        // Recarregamos ou atualizamos localmente
        await loadOrders();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await orderService.deleteOrder(orderId);
      _orders.removeWhere((o) => o.id == orderId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
