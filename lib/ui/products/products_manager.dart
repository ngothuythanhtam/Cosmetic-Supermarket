import '../../models/product.dart';
import 'package:flutter/foundation.dart';
import '../../services/products_service.dart';

class ProductsManager with ChangeNotifier {
  final ProductsService _productsService = ProductsService();
  List<Product> _items = [];

  int get itemCount {
    return _items.length;
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product? findById(String id) {
    try {
      return _items.firstWhere((item) => item.pid == id);
    } catch (error) {
      return null;
    }
  }
  Future<void> updateProduct(Product product) async {
    final index = _items.indexWhere((item) => item.pid == product.pid);
    if (index >= 0) {
      final updatedProduct = await _productsService.updateProduct(product);
      if (updatedProduct != null) {
        _items[index] = updatedProduct;
      }
      notifyListeners();
    }
  }

  Future<void> fetchProducts() async {
    _items = await _productsService.fetchProducts();
    notifyListeners();
  }

  Future<void> fetchUserProducts() async {
    _items = await _productsService.fetchProducts(
      filteredByUser: true,
    );
    notifyListeners();
  }
}
