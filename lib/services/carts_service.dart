import '../models/cart_item.dart';
import 'pocketbase_client.dart';

class CartsService {
  Future<String> _fetchProductImage(String productId) async {
    try {
      final pb = await getPocketbaseInstance();
      final productModel = await pb!.collection('products').getOne(productId);
      final featuredImageName = productModel.getStringValue('featuredImage');

      return pb.files.getUrl(productModel, featuredImageName).toString();
    } catch (error) {
      return '';
    }
  }

  Future<int> checkStockQuantity(String productId) async {
    try {
      final pb = await getPocketbaseInstance();
      final productRecord = await pb!.collection('products').getOne(productId);
      final stockQuantity = productRecord.data['stockQuantity'] ?? 0;
      return stockQuantity;
    } catch (error) {
      throw Exception('Failed to fetch stock quantity: $error');
    }
  }

  Future<CartItem?> addCartItem(CartItem cartItem) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb!.authStore.record?.id;
      final productRecord =
          await pb.collection('products').getOne(cartItem.productId);
      final stockQuantity = productRecord.data['stockQuantity'] ?? 0;
      final existingItems = await pb.collection('carts').getFullList(
            filter:
                "userId='$userId' && productId='${cartItem.productId}' && status='pending'",
          );
      int currentQuantityInCart = 0;

      if (existingItems.isNotEmpty) {
        final existingItem = existingItems.first;
        currentQuantityInCart = existingItem.getIntValue('quantity');
      }
      final totalQuantity = currentQuantityInCart + cartItem.quantity;
      if (totalQuantity > stockQuantity) {
        throw Exception(
            'Product is out of stock. Current stock quantity: $stockQuantity');
      }
      if (existingItems.isNotEmpty) {
        final existingItem = existingItems.first;
        final updatedItem = await pb.collection('carts').update(
          existingItem.id,
          body: {
            'quantity': totalQuantity,
          },
        );
        return CartItem.fromJson(updatedItem.toJson());
      } else {
        final cartModel = await pb.collection('carts').create(
          body: {
            ...cartItem.toJson(),
            'userId': userId,
            'status': 'pending',
          },
        );
        return cartItem.copyWith(id: cartModel.id);
      }
    } catch (error) {
      throw Exception('Failed to add cart item: $error');
    }
  }

  Future<List<CartItem>> fetchCartItems({bool filteredByUser = false}) async {
    final List<CartItem> cartItems = [];

    try {
      final pb = await getPocketbaseInstance();
      final userId = pb!.authStore.record!.id;
      print('🔴 Fetching cart items for userId: $userId');
      String filter;
      if (filteredByUser) {
        filter = "userId='$userId' && status='pending'";
      } else {
        filter = "status='pending'";
      }
      print('🔴 Filter: $filter');
      final cartModels =
          await pb.collection('carts').getFullList(filter: filter);
      print('🔴 Fetched ${cartModels.length} cart models');
      for (final cartModel in cartModels) {
        final cartData = cartModel.toJson();
        final productId = cartData['productId'];
        final imageUrl = await _fetchProductImage(productId);
        cartItems.add(
          CartItem.fromJson(cartData).copyWith(imageUrl: imageUrl),
        );
      }
      return cartItems;
    } catch (error) {
      print('🔴 Error fetching cart items: $error');
      return cartItems;
    }
  }

  Future<CartItem?> updateCartItem(CartItem cartItem) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb!.authStore.record?.id;
      if (userId == null) {
        throw Exception('User not authenticated.');
      }

      final productRecord =
          await pb.collection('products').getOne(cartItem.productId);
      final stockQuantity = productRecord.data['stockQuantity'] ?? 0;
      if (cartItem.quantity > stockQuantity) {
        throw Exception(
            'Product is out of stock. Current stock quantity: $stockQuantity');
      }
      final cartModel = await pb.collection('carts').update(
        cartItem.id!,
        body: {
          'quantity': cartItem.quantity,
          'userId': userId,
        },
      );
      return cartItem.copyWith(id: cartModel.id);
    } catch (error) {
      throw Exception('Failed to update cart item: $error');
    }
  }

  Future<bool> deleteCartItem(String id) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb!.collection('carts').delete(id);
      return true;
    } catch (error) {
      return false;
    }
  }
}
