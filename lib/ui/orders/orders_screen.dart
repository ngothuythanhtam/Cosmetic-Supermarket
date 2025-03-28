import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin/auth/auth_manager.dart';
import '../shared/app_drawer.dart';
import 'orders_manager.dart';
import '../orders/order_item_cart.dart';

const Color primaryColor = Color.fromARGB(255, 231, 110, 110);
const Color secondaryColor = Color(0xFFFFDDE1); 
const Color backgroundColor = Color(0xFFFAFAFA); 

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<void> _fetchOrders;
  @override
  void initState() {
    super.initState();
    _fetchOrders = context.read<OrdersManager>().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: secondaryColor,
        title: Text(
          "My Orders",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(color: primaryColor),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      drawer: AppDrawer(isAdmin: authManager.isStaff),
      body: FutureBuilder(
        future: _fetchOrders,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error, primaryColor);
          } else {
            return Consumer<OrdersManager>(
              builder: (ctx, ordersManager, child) {
                return ordersManager.orderCount == 0
                    ? _buildEmptyOrders(primaryColor)
                    : _buildOrderList(ordersManager);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildErrorWidget(Object? error, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            "Something went wrong",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Error: $error",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            "No orders yet",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your order history will appear here",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(OrdersManager ordersManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: ListView.builder(
        itemCount: ordersManager.orderCount,
        itemBuilder: (ctx, i) => OrderItemCard(ordersManager.orders[i]),
      ),
    );
  }
}
