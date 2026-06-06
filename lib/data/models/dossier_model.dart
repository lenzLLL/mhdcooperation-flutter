class DossierModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? serviceId;
  final String? concoursId;
  final String? itemTitle;
  final String itemType;
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
    this.userName,
    this.userEmail,
    this.userPhone,
    this.serviceId,
    this.concoursId,
    this.itemTitle,
    required this.itemType,
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
      userName: json['user_name'],
      userEmail: json['user_email'],
      userPhone: json['user_phone'],
      itemTitle: json['item_title'] ?? json['title'],
      itemType: json['item_type'] ??
          (json['concours_id'] != null && json['concours_id'].toString().isNotEmpty
              ? 'concours'
              : 'service'),
      dateDeDepot: _parseDate(json['date_de_depot']),
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString())
          : null,
      gateway: json['gateway'],
      status: json['status'] ?? 'pending',
      messages: json['messages'],
      links: json['links'],
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is Map && value.containsKey('_seconds')) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value['_seconds'] as int) * 1000 +
            ((value['_nanoseconds'] as int) ~/ 1000000),
      );
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'service_id': serviceId,
      'concours_id': concoursId,
      'item_title': itemTitle,
      'item_type': itemType,
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
    String? userName,
    String? userEmail,
    String? userPhone,
    String? serviceId,
    String? concoursId,
    String? itemTitle,
    String? itemType,
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
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      serviceId: serviceId ?? this.serviceId,
      concoursId: concoursId ?? this.concoursId,
      itemTitle: itemTitle ?? this.itemTitle,
      itemType: itemType ?? this.itemType,
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
