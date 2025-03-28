import 'cart_item.dart';
import 'user.dart';

class OrderItem {
  final String? id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  final String status;
  final String? userId;
  final User? user; 

  int get productCount => products.length;

  OrderItem({
    this.id,
    required this.amount,
    required this.products,
    DateTime? dateTime,
    this.status = 'confirmed',
    this.userId,
    this.user, 
  }) : dateTime = dateTime ?? DateTime.now();

  OrderItem copyWith({
    String? id,
    double? amount,
    List<CartItem>? products,
    DateTime? dateTime,
    String? status,
    String? userId,
    User? user, 
  }) {
    return OrderItem(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      products: products ?? this.products,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
      'products': products.map((p) => p.toJson()).toList(),
      'status': status,
      'userId': userId,
      'user': user?.toJson(), 
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      amount: json['amount'].toDouble(),
      dateTime: DateTime.parse(json['dateTime']),
      products: (json['products'] as List<dynamic>)
          .map((p) => CartItem.fromJson(p))
          .toList(),
      status: json['status'] ?? 'confirmed',
      userId: json['userId'],
      user: json['user'] != null
          ? User.fromJson(json['user'])
          : null, 
    );
  }
}