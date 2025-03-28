import 'package:flutter/foundation.dart';
import '../../../models/product.dart';
import '../../../services/products_service.dart';

class AdminProductsManager with ChangeNotifier {
  final ProductsService _productsService = ProductsService();
  List<Product> _items = [];
  List<String> _categories = [];

  Future<void> adminFetchAllProducts() async {
    print("✅ Fetching orders...");
    final fetchedProducts = await _productsService.fetchProducts();
    if (fetchedProducts.isEmpty) print("❌ No orders found or failed to fetch.");
    _items.clear();
    _items.addAll(fetchedProducts);
    notifyListeners();
  }

  Future<void> fetchProducts({String? category}) async {
    _items = await _productsService.fetchProducts(category: category);
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _categories = await _productsService.fetchCategories();
    notifyListeners();
  }

  int get itemCount {
    return _items.length;
  }

  List<Product> get items {
    return [..._items];
  }

  List<String> get categories {
    return [..._categories];
  }

  Product? findById(String id) {
    try {
      return _items.firstWhere((item) => item.pid == id);
    } catch (error) {
      return null;
    }
  }

  Future<void> addProduct(Product product) async {
    final newProduct = await _productsService.addProduct(product);
    if (newProduct != null) {
      _items.add(newProduct);
      notifyListeners();
    }
  }

Future<void> updateProduct(Product product) async {
    final index = _items.indexWhere((item) => item.pid == product.pid);
    if (index >= 0) {
      final updatedProduct = await _productsService.updateProduct(product);
      if (updatedProduct != null) {
        _items[index] = updatedProduct;
        notifyListeners();
      }
    }
  }

  Future<void> deleteProduct(String pid) async {
    final index = _items.indexWhere((item) => item.pid == pid);
    if (index >= 0 && await _productsService.deleteProduct(pid)) {
      _items.removeAt(index);
      notifyListeners();
    }
  }
}
