class School {
  final String id;
  final String name;
  final String? address;
  final String? city;
  final String description;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final List<String> filieres;
  final Map<String, double> prixParNiveau;

  /// Prix du rapport de stage par niveau (service « Rapport de stage »).
  final Map<String, double> prixRapportParNiveau;

  /// Frais d'inscription / préinscription universitaire.
  final double? prixInscription;
  final double? prixPreinscription;

  /// Pièces demandées par niveau (dossier BTS/Licence…) et pour le rapport.
  final Map<String, List<String>> docsParNiveau;
  final Map<String, List<String>> docsRapportParNiveau;

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
    this.city,
    required this.description,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.filieres = const [],
    this.prixParNiveau = const {},
    this.prixRapportParNiveau = const {},
    this.prixInscription,
    this.prixPreinscription,
    this.docsParNiveau = const {},
    this.docsRapportParNiveau = const {},
  });

  static Map<String, double> _numMap(dynamic raw) {
    final result = <String, double>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is num) result[key.toString()] = value.toDouble();
      });
    }
    return result;
  }

  static Map<String, List<String>> _stringListMap(dynamic raw) {
    final result = <String, List<String>>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is List) {
          result[key.toString()] = value.map((e) => e.toString()).toList();
        }
      });
    }
    return result;
  }

  static double? _numOrNull(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '');
  }

  factory School.fromJson(Map<String, dynamic> json) {
    List<String> filieres = [];
    if (json['filieres'] is List) {
      filieres = (json['filieres'] as List).whereType<String>().toList();
    }

    return School(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'],
      city: json['city']?.toString(),
      description: json['description'] ?? '',
      logoUrl: json['logo_url'],
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      category: json['category'] ?? '',
      filieres: filieres,
      prixParNiveau: _numMap(json['prix_par_niveau']),
      prixRapportParNiveau: _numMap(json['prix_rapport_par_niveau']),
      prixInscription: _numOrNull(json['prix_inscription']),
      prixPreinscription: _numOrNull(json['prix_preinscription']),
      docsParNiveau: _stringListMap(json['docs_par_niveau']),
      docsRapportParNiveau: _stringListMap(json['docs_rapport_par_niveau']),
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
      'city': city,
      'description': description,
      'logo_url': logoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category': category,
      'filieres': filieres,
      'prix_par_niveau': prixParNiveau,
      'prix_rapport_par_niveau': prixRapportParNiveau,
      'prix_inscription': prixInscription,
      'prix_preinscription': prixPreinscription,
      'docs_par_niveau': docsParNiveau,
      'docs_rapport_par_niveau': docsRapportParNiveau,
    };
  }

  School copyWith({
    String? name,
    String? address,
    String? city,
    String? description,
    String? logoUrl,
    String? category,
    List<String>? filieres,
    Map<String, double>? prixParNiveau,
    Map<String, double>? prixRapportParNiveau,
    double? prixInscription,
    double? prixPreinscription,
    Map<String, List<String>>? docsParNiveau,
    Map<String, List<String>>? docsRapportParNiveau,
  }) {
    return School(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      category: category ?? this.category,
      filieres: filieres ?? this.filieres,
      prixParNiveau: prixParNiveau ?? this.prixParNiveau,
      prixRapportParNiveau: prixRapportParNiveau ?? this.prixRapportParNiveau,
      prixInscription: prixInscription ?? this.prixInscription,
      prixPreinscription: prixPreinscription ?? this.prixPreinscription,
      docsParNiveau: docsParNiveau ?? this.docsParNiveau,
      docsRapportParNiveau: docsRapportParNiveau ?? this.docsRapportParNiveau,
    );
  }
}
