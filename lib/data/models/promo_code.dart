/// Code promo tel que renvoyé par l'API web (/api/admin/promos).
class PromoCode {
  final String code;
  final int percent;
  final bool active;
  final String? description;
  final DateTime? expiresAt;
  final int? maxUses;
  final int uses;
  /// Encaissé (brut, avant commission K-Pay) sur les dossiers payés avec ce code.
  final double revenue;
  /// Total des remises accordées avec ce code.
  final double discountTotal;
  final bool oncePerUser;
  /// Dossiers concernés : 'concours' ou 'service:ID'. Vide = tous.
  final List<String> scope;

  const PromoCode({
    required this.code,
    required this.percent,
    required this.active,
    this.description,
    this.expiresAt,
    this.maxUses,
    required this.uses,
    this.revenue = 0,
    this.discountTotal = 0,
    required this.oncePerUser,
    required this.scope,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      code: json['code']?.toString() ?? '',
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      active: json['active'] != false,
      description: json['description']?.toString(),
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'].toString())?.toLocal() : null,
      maxUses: (json['maxUses'] as num?)?.toInt(),
      uses: (json['uses'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      discountTotal: (json['discountTotal'] as num?)?.toDouble() ?? 0,
      oncePerUser: json['oncePerUser'] == true,
      scope: (json['scope'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  bool get isExpired => expiresAt != null && !expiresAt!.isAfter(DateTime.now());
  bool get isExhausted => maxUses != null && uses >= maxUses!;
}
