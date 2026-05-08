class DossierModel {
  final String id;
  final String userId;
  final String? serviceId;
  final String? concoursId;
  final DateTime dateDeDepot;
  final double? amount;
  final String? gateway;
  final String status;
  final String? messages;
  final String? links;
  final DateTime createdAt;
  final DateTime updatedAt;

  DossierModel({
    required this.id,
    required this.userId,
    this.serviceId,
    this.concoursId,
    required this.dateDeDepot,
    this.amount,
    this.gateway,
    required this.status,
    this.messages,
    this.links,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DossierModel.fromJson(Map<String, dynamic> json) {
    return DossierModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? '',
      serviceId: json['service_id'],
      concoursId: json['concours_id'],
      dateDeDepot: DateTime.parse(
        json['date_de_depot'] ?? DateTime.now().toIso8601String(),
      ),
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString())
          : null,
      gateway: json['gateway'],
      status: json['status'] ?? 'pending',
      messages: json['messages'],
      links: json['links'],
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
      'user_id': userId,
      'service_id': serviceId,
      'concours_id': concoursId,
      'date_de_depot': dateDeDepot.toIso8601String(),
      'amount': amount,
      'gateway': gateway,
      'status': status,
      'messages': messages,
      'links': links,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DossierModel copyWith({
    String? userId,
    String? serviceId,
    String? concoursId,
    DateTime? dateDeDepot,
    double? amount,
    String? gateway,
    String? status,
    String? messages,
    String? links,
  }) {
    return DossierModel(
      id: id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      concoursId: concoursId ?? this.concoursId,
      dateDeDepot: dateDeDepot ?? this.dateDeDepot,
      amount: amount ?? this.amount,
      gateway: gateway ?? this.gateway,
      status: status ?? this.status,
      messages: messages ?? this.messages,
      links: links ?? this.links,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
