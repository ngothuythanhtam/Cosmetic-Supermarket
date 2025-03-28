import 'package:flutter/foundation.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../services/carts_service.dart';

class CartManager with ChangeNotifier {
  final CartsService _cartsService = CartsService();
  final Map<String, CartItem> _items = {};

  int get productCount {
    return _items.length;
  }

  List<CartItem> get products {
    return _items.values.toList();
  }

  Iterable<MapEntry<String, CartItem>> get productEntries {
    return {..._items}.entries;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> fetchCartItems() async {
    final cartItems = await _cartsService.fetchCartItems(filteredByUser: true);
    _items.clear();
    for (final item in cartItems) {
      _items[item.productId] = item;
    }
    notifyListeners();
  }

  Future<void> addItem(Product product, {int quantity = 1}) async {
    try {
      if (product.stockQuantity <= 0) {
        throw Exception('Product is out of stock.');
      }
      int currentQuantity =
          _items.containsKey(product.pid!) ? _items[product.pid!]!.quantity : 0;
      final totalQuantity = currentQuantity + quantity;

      if (totalQuantity > product.stockQuantity) {
        throw Exception(
            'Product is out of stock. Current stock quantity: ${product.stockQuantity}');
      }
      if (_items.containsKey(product.pid!)) {
        final updatedQuantity = _items[product.pid!]!.quantity + quantity;
        final updatedItem =
            _items[product.pid!]!.copyWith(quantity: updatedQuantity);
        await _cartsService.updateCartItem(updatedItem);
        _items[product.pid!] = updatedItem;
      } else {
        final newItem = CartItem(
          productId: product.pid!,
          title: product.title,
          price: product.price,
          quantity: quantity,
          imageUrl: product.imageUrl,
        );
        final addedItem = await _cartsService.addCartItem(newItem);
        if (addedItem != null) {
          _items[product.pid!] = addedItem;
        } else {
          throw Exception('Failed to add product to cart.');
        }
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateItem(CartItem item) async {
    try {
      if (!_items.containsKey(item.productId)) {
        throw Exception(
            'Cart item with product ID ${item.productId} not found.');
      }
      final updatedItem = await _cartsService.updateCartItem(item);
      if (updatedItem != null) {
        _items[item.productId] = updatedItem;
        notifyListeners();
      } else {
        throw Exception('Failed to update cart item.');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> removeItem(String productId) async {
    if (!_items.containsKey(productId)) {
      return;
    }

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => existingCartItem.copyWith(
          quantity: existingCartItem.quantity - 1,
        ),
      );
      await _cartsService.updateCartItem(_items[productId]!);
    } else {
      final success =
          await _cartsService.deleteCartItem(_items[productId]!.id!);
      if (success) {
        _items.remove(productId);
      }
    }

    notifyListeners();
  }

  Future<void> clearItem(String id) async {
    final key = _items.keys.firstWhere(
      (k) => _items[k]!.id == id,
      orElse: () => '',
    );

    if (key.isNotEmpty) {
      final success = await _cartsService.deleteCartItem(id);
      if (success) {
        _items.remove(key);
        await fetchCartItems();
        notifyListeners();
      }
    }
  }

  Future<void> clearAllItems() async {
    for (final id in _items.keys.toList()) {
      await _cartsService.deleteCartItem(id);
    }
    _items.clear();
    notifyListeners();
  }

  Future<void> updateItemQuantity(String productId, int newQuantity) async {
    try {
      if (!_items.containsKey(productId)) {
        return;
      }
      final stockQuantity = await _cartsService.checkStockQuantity(productId);

      if (newQuantity > stockQuantity) {
        throw Exception(
            'Product is out of stock. Current stock quantity: $stockQuantity');
      }
      final updatedItem = _items[productId]!.copyWith(quantity: newQuantity);
      await _cartsService.updateCartItem(updatedItem);
      _items[productId] = updatedItem;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
