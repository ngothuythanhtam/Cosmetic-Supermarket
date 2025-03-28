class User {
  final String id;
  final String email;
  final String username;
  final String? urole;
  final String phone;
  final String? address;
  final String? avatar;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.urole,
    required this.phone,
    this.address,
    this.avatar,
  });

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? urole,
    String? phone,
    String? address,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      urole: urole ?? this.urole,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // Check if required fields are present
    if (json['id'] == null) {
      throw Exception('User ID is missing from response');
    }
    if (json['email'] == null) {
      throw Exception('Email is missing from response');
    }
    if (json['username'] == null) {
      throw Exception('Username is missing from response');
    }
    if (json['phone'] == null) {
      throw Exception('Phone is missing from response');
    }

    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      urole: json['urole']?.toString() ?? 'customer',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'urole': urole,
      'phone': phone,
      'address': address,
      'avatar': avatar,
    };
  }
}
