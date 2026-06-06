class School {
  final String id;
  final String name;
  final String? address;
  final String description;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final List<String> filieres;
  final Map<String, double> prixParNiveau;

  static const List<String> niveauxDisponibles = [
    'BTS',
    'Licence',
    'Bachelor',
    'Master',
    'HND',
  ];

  School({
    required this.id,
    required this.name,
    this.address,
    required this.description,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.filieres = const [],
    this.prixParNiveau = const {},
  });

  factory School.fromJson(Map<String, dynamic> json) {
    List<String> filieres = [];
    if (json['filieres'] is List) {
      filieres = (json['filieres'] as List).whereType<String>().toList();
    }

    Map<String, double> prixParNiveau = {};
    if (json['prix_par_niveau'] is Map) {
      (json['prix_par_niveau'] as Map).forEach((key, value) {
        if (value is num) {
          prixParNiveau[key.toString()] = value.toDouble();
        }
      });
    }

    return School(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'],
      description: json['description'] ?? '',
      logoUrl: json['logo_url'],
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      category: json['category'] ?? '',
      filieres: filieres,
      prixParNiveau: prixParNiveau,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is Map && value.containsKey('_seconds')) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value['_seconds'] as int) * 1000 +
            ((value['_nanoseconds'] as int? ?? 0) ~/ 1000000),
      );
    }
    return DateTime.now();
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
      'filieres': filieres,
      'prix_par_niveau': prixParNiveau,
    };
  }

  School copyWith({
    String? name,
    String? address,
    String? description,
    String? logoUrl,
    String? category,
    List<String>? filieres,
    Map<String, double>? prixParNiveau,
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
      filieres: filieres ?? this.filieres,
      prixParNiveau: prixParNiveau ?? this.prixParNiveau,
    );
  }
}
