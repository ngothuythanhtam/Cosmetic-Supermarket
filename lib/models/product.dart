import 'dart:io';

class Product {
  final String? pid;
  final String title;
  final String description;
  final double price;
  final File? featuredImage;
  final String imageUrl;
  final bool isFavorite;
  final int stockQuantity;
  final String category;
  final bool locked;

  Product({
    this.pid,
    required this.title,
    required this.description,
    required this.price,
    this.featuredImage,
    this.imageUrl = '',
    this.isFavorite = false,
    required this.stockQuantity,
    required this.category,
    this.locked = false,
  });

  Product copyWith({
    String? pid,
    String? title,
    String? description,
    double? price,
    File? featuredImage,
    String? imageUrl,
    bool? isFavorite,
    int? stockQuantity,
    String? category,
    bool? locked,
  }) {
    return Product(
      pid: pid ?? this.pid,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      featuredImage: featuredImage ?? this.featuredImage,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      category: category ?? this.category,
      locked: locked ?? this.locked,
    );
  }

  bool hasFeaturedImage() {
    return featuredImage != null || imageUrl.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'isFavorite': isFavorite,
      'stockQuantity': stockQuantity,
      'category': category,
      'locked': locked,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      pid: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0),
      isFavorite: json['isFavorite'] ?? false,
      imageUrl: json['imageUrl'] ?? '',
      stockQuantity: json['stockQuantity'] ?? 0,
      category: json['category'] ?? '',
      locked: json['locked'] ?? false,
    );
  }
}
