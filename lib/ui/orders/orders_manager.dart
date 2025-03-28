import '../../models/cart_item.dart';
import '../../models/order_item.dart';
import 'package:flutter/foundation.dart';
import '../../services/orders_service.dart';

class OrdersManager with ChangeNotifier {
  final OrdersService _ordersService = OrdersService();
  final List<OrderItem> _orders = [];

  int get orderCount {
    return _orders.length;
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    print("Fetching orders...");
    final fetchedOrders =
        await _ordersService.fetchOrders(filteredByUser: true);
    if (fetchedOrders.isEmpty) {
      print("No orders found or failed to fetch.");
    }
    _orders.clear();
    _orders.addAll(fetchedOrders);
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    print('Adding order: total=$total, products=${cartProducts.length}');

    for (var item in cartProducts) {
      if (item.id == null) {
        print('Error: Cart item has no ID');
        return;
      }
    }
    final newOrder = OrderItem(
      amount: total,
      products: cartProducts,
      dateTime: DateTime.now(),
    );

    final addedOrder = await _ordersService.addOrder(newOrder);
    if (addedOrder != null) {
      print('Order successfully added: ${addedOrder.toJson()}');
      _orders.insert(0, addedOrder);
      notifyListeners();
    } else {
      print('Failed to add order');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updatedOrder = _orders[index].copyWith(status: newStatus);
      print(
          'Updating order status: ${updatedOrder.toJson()}');

      final result = await _ordersService.updateOrder(updatedOrder);
      if (result != null) {
        _orders[index] = result;
        notifyListeners();
      } else {
        print('Failed to update order status');
      }
    } else {
    print('Order not found with ID: $orderId'); 
    }
  }

  Future<void> deleteOrder(String id) async {
    final success = await _ordersService.deleteOrder(id);
    if (success) {
      _orders.removeWhere((o) => o.id == id);
      notifyListeners();
    }
  }
}
