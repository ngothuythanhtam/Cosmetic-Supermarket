import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import '../models/product.dart';
import 'pocketbase_client.dart';

class ProductsService {
  String _getFeaturedImageUrl(PocketBase pb, RecordModel productModel) {
    final featuredImageName = productModel.getStringValue('featuredImage');
    return pb.files.getUrl(productModel, featuredImageName).toString();
  }

  Future<Product?> addProduct(Product product) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb?.authStore.record!.id;

      final productModel = await pb!.collection('products').create(
        body: {
          ...product.toJson(),
          'userId': userId,
          'stockQuantity': product.stockQuantity,
          'category': product.category, // Pass the category name directly
        },
        files: [
          if (product.featuredImage != null)
            http.MultipartFile.fromBytes(
              'featuredImage',
              await product.featuredImage!.readAsBytes(),
              filename: product.featuredImage!.uri.pathSegments.last,
            ),
        ],
      );

      return product.copyWith(
        pid: productModel.id,
        imageUrl: _getFeaturedImageUrl(pb, productModel),
      );
    } catch (error) {
      print('❌ Error adding product: $error');
      return null;
    }
  }

  Future<List<Product>> fetchProducts(
      {bool filteredByUser = false, String? category}) async {
    final List<Product> products = [];

    try {
      final pb = await getPocketbaseInstance();
      final userId = pb!.authStore.record!.id;
      final filter = filteredByUser ? "userId='$userId'" : null;
      final categoryFilter = category != null ? "category='$category'" : null;
      final combinedFilter =
          [filter, categoryFilter].where((f) => f != null).join(' && ');

      final productModels = await pb.collection('products').getFullList(
          filter: combinedFilter.isNotEmpty ? combinedFilter : null);

      for (final productModel in productModels) {
        products.add(
          Product.fromJson(
            productModel.toJson()
              ..addAll({'imageUrl': _getFeaturedImageUrl(pb, productModel)}),
          ),
        );
      }
      return products;
    } catch (error) {
      print('❌ Error fetching products: $error');
      return products;
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final pb = await getPocketbaseInstance();
      final productModels = await pb!.collection('products').getFullList();
      final categories = productModels
          .map((model) => model.getStringValue('category'))
          .where(
              (category) => category.isNotEmpty) // Filter out empty categories
          .toSet() // Ensure unique categories
          .toList();
      return categories;
    } catch (error) {
      print('❌ Error fetching categories: $error');
      return [];
    }
  }

  Future<Product?> updateProduct(Product product) async {
    try {
      final pb = await getPocketbaseInstance();
      final productModel = await pb!.collection('products').update(
            product.pid!,
            body: {
              ...product.toJson(),
              'stockQuantity': product.stockQuantity,
            },
            files: product.featuredImage != null
                ? [
                    http.MultipartFile.fromBytes(
                      'featuredImage',
                      await product.featuredImage!.readAsBytes(),
                      filename: product.featuredImage!.uri.pathSegments.last,
                    ),
                  ]
                : [],
          );
      return product.copyWith(
        imageUrl: product.featuredImage != null
            ? _getFeaturedImageUrl(pb, productModel)
            : product.imageUrl,
      );
    } catch (error) {
      print('❌ Error updating product: $error');
      return null;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb!.collection('products').delete(id);
      return true;
    } catch (error) {
      print('❌ Error deleting product: $error');
      return false;
    }
  }
}
