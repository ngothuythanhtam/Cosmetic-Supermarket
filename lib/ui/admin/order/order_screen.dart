import 'package:flutter/material.dart';
import '../../../models/order_item.dart';
import '../../shared/app_drawer.dart';
import 'order_manager.dart';
import 'order_card.dart';
import 'package:provider/provider.dart';
import '../../../components/colors.dart';
import '../auth/auth_manager.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});
  static const routeName = '/admin_orders';

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  late Future<void> _fetchOrders;
  final ScrollController _scrollController = ScrollController();
  String _selectedStatus = 'All';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders = Future.value();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchOrders = Provider.of<AdminOrdersManager>(context, listen: false)
        .adminFetchAllOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(isAdmin: authManager.isStaff),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Container(
                margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.menu, color: color4, size: 30),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 300,
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 10.0),
                          decoration: BoxDecoration(
                            color: color17,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Search orders...",
                                    hintStyle: TextStyle(color: color4),
                                  ),
                                  style: TextStyle(color: color4),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                              Icon(Icons.search, color: color4, size: 30.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      height: 50,
                      child: RawScrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        thumbColor: color4.withOpacity(0.5),
                        radius: const Radius.circular(10),
                        thickness: 4,
                        minThumbLength: 50,
                        scrollbarOrientation: ScrollbarOrientation.bottom,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            final statuses = [
                              'All',
                              'Confirmed',
                              'Completed',
                              'Canceled'
                            ];
                            final status = statuses[index];
                            final isSelected = _selectedStatus == status;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedStatus = status;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? color17 : color13,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: isSelected ? color4 : color1,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: FutureBuilder(
                        future: _fetchOrders,
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child:
                                    CircularProgressIndicator(color: color11));
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}",
                                    style: TextStyle(color: Colors.grey[600])));
                          } else {
                            return Consumer<AdminOrdersManager>(
                              builder: (ctx, ordersManager, child) {
                                var filteredOrders = ordersManager.orders;
                                print(
                                    '🔴‼️Total orders before filtering: ${filteredOrders.length}');
                                print('🔴‼️Search query: $_searchQuery');
                                print('🔴‼️Selected status: $_selectedStatus');

                                if (_selectedStatus != 'All') {
                                  filteredOrders = filteredOrders
                                      .where((order) =>
                                          order.status.toLowerCase() ==
                                          _selectedStatus.toLowerCase())
                                      .toList();
                                  print(
                                      '🔴‼️Orders after status filter: ${filteredOrders.length}');
                                }

                                if (_searchQuery.isNotEmpty) {
                                  filteredOrders =
                                      filteredOrders.where((order) {
                                    final usernameMatch = order.user?.username
                                            .toLowerCase()
                                            .contains(
                                                _searchQuery.toLowerCase()) ??
                                        false;
                                    final phoneMatch = order.user?.phone
                                            .toLowerCase()
                                            .contains(
                                                _searchQuery.toLowerCase()) ??
                                        false;
                                    print(
                                        '🔴‼️Order: ${order.id}, Username: ${order.user?.username}, '
                                        'Phone: ${order.user?.phone}, Match: ${usernameMatch || phoneMatch}');
                                    return usernameMatch || phoneMatch;
                                  }).toList();
                                  print(
                                      '🔴‼️Orders after search filter: ${filteredOrders.length}');
                                }

                                if (filteredOrders.isEmpty) {
                                  return Center(
                                      child: Text(
                                          "No orders found matching your search",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey[600])));
                                }
                                return ListView.builder(
                                  padding: const EdgeInsets.all(8.0),
                                  itemCount: filteredOrders.length,
                                  itemBuilder: (ctx, i) => OrderItemCard(
                                    filteredOrders[i],
                                    onTap: () => _showOrderDetailsPopup(context,
                                        filteredOrders[i], ordersManager),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

void _showOrderDetailsPopup(
      BuildContext context, OrderItem order, AdminOrdersManager ordersManager) {
    final totalQuantity =
        order.products.fold<int>(0, (sum, product) => sum + (product.quantity));

    // Create a ScrollController for the products list
    final ScrollController _productsScrollController = ScrollController();

    // Function to truncate product title if it's too long
    String truncateProductTitle(String title, {int maxLength = 20}) {
      if (title.length <= maxLength) {
        return title;
      }
      return '${title.substring(0, maxLength)}...';
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: color13,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Order ID: ${order.id}",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: color4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                    children: [
                      Icon(Icons.person, size: 20, color: color4),
                      const SizedBox(width: 8),
                      Text(
                        order.user?.username ?? 'Unknown User',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: color4,
                        ),
                      ),
                    ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 20, color: color4),
                        const SizedBox(width: 8),
                        Text(
                          order.user?.phone ?? 'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            color: color4,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(
                      "Items:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color4,
                      ),
                    ),
                    // Add a constrained height and scrollbar for the product list
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 249, 223, 221),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      
                      constraints: BoxConstraints(
                        maxHeight: order.products.length > 3
                            ? 120 // Set a max height for more than 3 products
                            : double
                                .infinity, // No height constraint if 3 or fewer products
                      ),
                      child: Scrollbar(
                        controller:
                            _productsScrollController, // Add ScrollController
                        thumbVisibility: order.products.length > 3,
                        child: SingleChildScrollView(
                          controller:
                              _productsScrollController, // Same controller for SingleChildScrollView
                          child: Column(
                            children: order.products.map((prod) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Truncate the product title if it's too long
                                    SizedBox(
                                      width:
                                          200, // Constrain the width to ensure truncation works
                                      child: Text(
                                        "${prod.quantity}x ${truncateProductTitle(prod.title)}",
                                        style: TextStyle(color: color4),
                                        overflow: TextOverflow
                                            .ellipsis, // Fallback in case of overflow
                                      ),
                                    ),
                                    Text(
                                      "\$${prod.price.toStringAsFixed(2)}",
                                      style: TextStyle(color: color4),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    
                    
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Quantity:",
                          style: TextStyle(color: color4),
                        ),
                        Text(
                          "$totalQuantity",
                          style: TextStyle(color: color4),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Amount:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color4,
                          ),
                        ),
                        Text(
                          "\$${order.amount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color4,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (order.status == 'confirmed') ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (order.status != 'completed') {
                                    setState(() => _isLoading = true);
                                    await ordersManager.adminUpdateOrderStatus(
                                        order.id!, 'completed');
                                    setState(() => _isLoading = false);
                                    Navigator.of(ctx).pop();
                                    setState(() {
                                      _fetchOrders =
                                          Provider.of<AdminOrdersManager>(
                                                  context,
                                                  listen: false)
                                              .adminFetchAllOrders();
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 97,
                                      202, 100),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Completed',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(
                                  width: 8), 
                              ElevatedButton(
                                onPressed: () async {
                                  if (order.status != 'canceled') {
                                    setState(() => _isLoading = true);
                                    await ordersManager.adminUpdateOrderStatus(
                                        order.id!, 'canceled');
                                    setState(() => _isLoading = false);
                                    Navigator.of(ctx).pop();
                                    setState(() {
                                      _fetchOrders =
                                          Provider.of<AdminOrdersManager>(
                                                  context,
                                                  listen: false)
                                              .adminFetchAllOrders();
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                      255, 218, 104, 96),  
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Canceled',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Status: ${order.status}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color4,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: IconButton(
                icon: Icon(Icons.close, color: color4, size: 28),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Dispose the controller when the dialog is closed
      _productsScrollController.dispose();
    });
  }

}
