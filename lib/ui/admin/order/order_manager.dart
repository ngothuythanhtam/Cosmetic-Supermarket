import '../../../models/order_item.dart';
import '../../../services/orders_service.dart';
import 'package:flutter/foundation.dart';

class AdminOrdersManager with ChangeNotifier {
  final OrdersService _ordersService = OrdersService();
  final List<OrderItem> _orders = [];

  int get orderCount => _orders.length;
  List<OrderItem> get orders => [..._orders];

  Future<void> adminFetchAllOrders() async {
    print("✅ Fetching orders...");
    final fetchedOrders = await _ordersService.adminFetchAllOrders();
    if (fetchedOrders.isEmpty) print("❌ No orders found or failed to fetch.");
    _orders.clear();
    _orders.addAll(fetchedOrders);
    notifyListeners();
  }

  Future<void> adminUpdateOrderStatus(String orderId, String newStatus) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updatedOrder = _orders[index].copyWith(status: newStatus);
      print('✅ Updating order status: ${updatedOrder.toJson()}');

      final result = await _ordersService.updateOrder(updatedOrder);
      if (result != null) {
        _orders[index] = result;
        notifyListeners();
      } else {
        print('❌ Failed to update order status');
      }
    } else {
      print('❌ Order not found with ID: $orderId');
    }
  }
}
