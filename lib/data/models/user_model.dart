/// User Model - Maps to backend User entity
class UserModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? pictureUrl;
  final String role;
  final String? email;
  final String? city;

  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.pictureUrl,
    this.role = 'USER',
    this.email,
    this.city,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      pictureUrl: json['picture_url'],
      role: json['role'] ?? 'USER',
      email: json['email'],
      city: json['city'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'picture_url': pictureUrl,
      'role': role,
      'email': email,
      'city': city,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isSuperAdmin => role == 'SADMIN';
  bool get isAdmin => role == 'ADMIN';

  UserModel copyWith({
    String? name,
    String? pictureUrl,
    String? email,
    String? city,
    String? phoneNumber,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      role: role,
      email: email ?? this.email,
      city: city ?? this.city,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Lightweight church reference embedded in User
