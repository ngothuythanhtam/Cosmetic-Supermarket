import '../models/order_item.dart';
import 'pocketbase_client.dart';
import '../models/cart_item.dart';
import '../models/user.dart';
class OrdersService {
  Future<OrderItem?> updateOrder(OrderItem order) async {
    try {
      final pb = await getPocketbaseInstance();
      final orderModel = await pb!.collection('orders').update(
        order.id!,
        body: {
          'amount': order.amount,
          'dateTime': order.dateTime.toIso8601String(),
          'status': order.status,
        },
      );
      return order.copyWith(id: orderModel.id);
    } catch (error) {
      print('Error updating order: $error'); // In lỗi nếu có
      return null;
    }
  }

  Future<bool> deleteOrder(String id) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb!.collection('orders').delete(id);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<List<OrderItem>> fetchOrders({bool filteredByUser = false}) async {
    final List<OrderItem> orders = [];

    try {
      final pb = await getPocketbaseInstance();
      final userId = pb!.authStore.record?.id;
      if (filteredByUser && userId == null) {
        return orders;
      }
      final orderModels = await pb.collection('orders').getFullList(
            filter: filteredByUser ? "userId='$userId'" : null,
          );
      for (final orderModel in orderModels) {
        final orderJson = orderModel.toJson();
        final List<CartItem> products = [];
        for (final cartId in orderJson['products']) {
          try {
            final cartModel = await pb.collection('carts').getOne(cartId);
            final cartJson = cartModel.toJson();

            final productModel =
                await pb.collection('products').getOne(cartJson['productId']);
            final productJson = productModel.toJson();
            products.add(CartItem(
              id: cartJson['id'] ?? '',
              productId: cartJson['productId'] ?? '',
              title: productJson['title'] ?? 'Unknown Product',
              price: productJson['price'] ?? 0.0,
              quantity: cartJson['quantity'] ?? 0,
              status: cartJson['status'] ?? 'pending',
            ));
          } catch (error) {
            print('Error fetching cart or product: $error');
          }
        }
        orders.add(OrderItem.fromJson({
          ...orderJson,
          'products': products.map((p) => p.toJson()).toList(),
        }));
      }

      return orders;
    } catch (error) {
      return orders;
    }
  }

  Future<OrderItem?> addOrder(OrderItem order) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb!.authStore.record?.id;
      final Map<String, int> productQuantities = {};
      final Map<String, int> productStocks = {};
      final List<CartItem> validCartItems = [];
      final List<String> lockedProducts = [];

      for (var cartItem in order.products) {
        try {
          final productRecord =
              await pb.collection('products').getOne(cartItem.productId);
          final currentStock = productRecord.data['stockQuantity'] ?? 0;
          final isLocked = productRecord.data['locked'] ?? false;
          if (isLocked) {
            throw Exception(
                'Product ${cartItem.productId} is currently locked');
          }
          final requiredQuantity =
              (productQuantities[cartItem.productId] ?? 0) + cartItem.quantity;
          if (currentStock < requiredQuantity) {
            throw Exception(
                'Not enough stock for product ${cartItem.productId}. Available: $currentStock, Required: $requiredQuantity');
          }
          await pb.collection('products').update(
            cartItem.productId,
            body: {'locked': true},
          );
          lockedProducts.add(cartItem.productId);
          validCartItems.add(cartItem);
          productQuantities[cartItem.productId] = requiredQuantity;
          productStocks[cartItem.productId] = currentStock;
        } catch (e) {
          continue;
        }
      }
      if (validCartItems.isEmpty) {
        for (var productId in lockedProducts) {
          try {
            await pb.collection('products').update(
              productId,
              body: {'locked': false},
            );
          } catch (e) {
            print('Error unlocking product $productId: $e');
          }
        }
        throw Exception(
            'Cannot create order: No valid products found. Please check if the products still exist.');
      }
      final orderData = {
        'amount': order.amount,
        'dateTime': order.dateTime.toIso8601String(),
        'userId': userId,
        'products': validCartItems.map((p) => p.id).toList(),
        'status': 'confirmed',
      };
      final orderModel = await pb.collection('orders').create(body: orderData);
      try {
        for (var entry in productQuantities.entries) {
          final productId = entry.key;
          final totalQuantity = entry.value;
          final currentStock = productStocks[productId]!;
          final newStock = currentStock - totalQuantity;
          await pb.collection('products').update(
            productId,
            body: {
              'stockQuantity': newStock,
              'locked': false,
            },
          );
          lockedProducts.remove(productId);
        }
        for (var cartItem in validCartItems) {
          final cartRecords = await pb.collection('carts').getFullList(
                filter:
                    "userId='$userId' && productId='${cartItem.productId}' && status='pending'",
              );
          for (final cart in cartRecords) {
            await pb.collection('carts').update(
              cart.id,
              body: {'status': 'checked_out'},
            );
          }
        }
      } catch (error) {
        try {
          await pb.collection('orders').delete(orderModel.id);
        } catch (e) {
          print('Error rolling back order ${orderModel.id}: $e');
        }
        for (var productId in lockedProducts) {
          try {
            await pb.collection('products').update(
              productId,
              body: {'locked': false},
            );
          } catch (e) {
            print('Error unlocking product $productId during rollback: $e');
          }
        }
        throw error;
      }
      return order.copyWith(id: orderModel.id);
    } catch (error) {
      throw Exception('Failed to add order: $error');
    }
  }

  Future<void> cleanInvalidCartItems() async {
    try {
      final pb = await getPocketbaseInstance();
      final cartItems = await pb!.collection('carts').getFullList();
      for (final cart in cartItems) {
        final cartData = cart.toJson();
        final productId = cartData['productId'];
        try {
          await pb.collection('products').getOne(productId);
        } catch (e) {
          print(
              'Deleting cart item ${cart.id} with invalid productId $productId');
          await pb.collection('carts').delete(cart.id);
        }
      }
    } catch (error) {
      print('Error cleaning invalid cart items: $error');
    }
  }

// ********************************************************Admin************************************************//
  Future<List<OrderItem>> adminFetchAllOrders() async {
    final List<OrderItem> orders = [];
    try {
      final pb = await getPocketbaseInstance();
      final orderModels = await pb!.collection('orders').getFullList();

      for (final orderModel in orderModels) {
        final orderJson = orderModel.toJson();
        final List<CartItem> products = [];

        // Ensure products field exists and is a list
        if (orderJson['products'] == null || orderJson['products'] is! List) {
          print(
              '⚠️ Order ${orderJson['id']} has no products or invalid products field');
          continue; // Skip this order if products field is invalid
        }

        for (final cartId in orderJson['products']) {
          try {
            // Validate cartId
            if (cartId == null || cartId.isEmpty) {
              print('⚠️ Invalid cartId in order ${orderJson['id']}: $cartId');
              products.add(CartItem(
                id: '',
                productId: '',
                title: 'Unknown Product (Invalid Cart ID)',
                price: 0.0,
                quantity: 0,
                status: 'error',
              ));
              continue;
            }

            // Fetch cart item
            final cartModel = await pb.collection('carts').getOne(cartId);
            final cartJson = cartModel.toJson();

            // Validate productId in cart
            if (cartJson['productId'] == null ||
                cartJson['productId'].isEmpty) {
              print(
                  '⚠️ Cart $cartId in order ${orderJson['id']} has no productId');
              products.add(CartItem(
                id: cartJson['id'] ?? '',
                productId: '',
                title: 'Unknown Product (Missing Product ID)',
                price: 0.0,
                quantity: cartJson['quantity'] ?? 0,
                status: cartJson['status'] ?? 'pending',
              ));
              continue;
            }

            // Fetch product
            final productModel =
                await pb.collection('products').getOne(cartJson['productId']);
            final productJson = productModel.toJson();

            products.add(CartItem(
              id: cartJson['id'] ?? '',
              productId: cartJson['productId'] ?? '',
              title: productJson['title'] ?? 'Unknown Product',
              price: productJson['price']?.toDouble() ?? 0.0,
              quantity: cartJson['quantity'] ?? 0,
              status: cartJson['status'] ?? 'pending',
            ));
          } catch (error) {
            print(
                '❌ Error fetching cart or product for cartId $cartId in order ${orderJson['id']}: $error');
            products.add(CartItem(
              id: cartId.toString(),
              productId: '',
              title: 'Error: Product Not Found',
              price: 0.0,
              quantity: 0,
              status: 'error',
            ));
          }
        }

        User? user;
        try {
          if (orderJson['userId'] != null && orderJson['userId'].isNotEmpty) {
            final userModel =
                await pb.collection('users').getOne(orderJson['userId']);
            user = User.fromJson(userModel.toJson());
          }
        } catch (error) {
          print('❌ Error fetching user for order ${orderJson['id']}: $error');
          user = null;
        }

        orders.add(OrderItem.fromJson({
          ...orderJson,
          'products': products.map((p) => p.toJson()).toList(),
          'user': user?.toJson(),
        }));
      }
      return orders;
    } catch (error) {
      print('❌ Error fetching orders: $error');
      return orders;
    }
  }

  Future<OrderItem?> adminUpdateOrder(OrderItem order) async {
    try {
      final pb = await getPocketbaseInstance();
      final orderModel = await pb!.collection('orders').update(
        order.id!,
        body: {
          'dateTime': order.dateTime.toIso8601String(),
          'status': order.status,
        },
      );
      return order.copyWith(id: orderModel.id);
    } catch (error) {
      print('❌ Error updating order: $error');
      return null;
    }
  }
}