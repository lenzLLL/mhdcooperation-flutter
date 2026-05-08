class School {
  final String id;
  final String name;
  final String? address;
  final String description;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;

  School({
    required this.id,
    required this.name,
    this.address,
    required this.description,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'],
      description: json['description'] ?? '',
      logoUrl: json['logo_url'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'logo_url': logoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category': category,
    };
  }

  School copyWith({
    String? name,
    String? address,
    String? description,
    String? logoUrl,
    String? category,
  }) {
    return School(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      category: category ?? this.category,
    );
  }
}
