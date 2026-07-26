/// Suivi individuel d'une pièce du dossier (statut, fichier, motif de rejet).
class DossierDocument {
  final String name;

  /// pending | uploaded | validated | rejected
  final String status;
  final String? fileUrl;
  final String? rejectionReason;
  final DateTime? uploadedAt;
  final DateTime? reviewedAt;

  const DossierDocument({
    required this.name,
    this.status = 'pending',
    this.fileUrl,
    this.rejectionReason,
    this.uploadedAt,
    this.reviewedAt,
  });

  factory DossierDocument.fromJson(Map<String, dynamic> json) {
    return DossierDocument(
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      fileUrl: json['file_url']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      uploadedAt: DossierModel._parseNullableDate(json['uploaded_at']),
      reviewedAt: DossierModel._parseNullableDate(json['reviewed_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'file_url': fileUrl,
      'rejection_reason': rejectionReason,
      'uploaded_at': uploadedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }

  static const Object _unset = Object();

  /// `rejectionReason: null` efface réellement le motif (validation d'une
  /// pièce précédemment rejetée) — un copyWith naïf le conserverait.
  DossierDocument copyWith({
    String? status,
    String? fileUrl,
    DateTime? uploadedAt,
    DateTime? reviewedAt,
    Object? rejectionReason = _unset,
  }) {
    return DossierDocument(
      name: name,
      status: status ?? this.status,
      fileUrl: fileUrl ?? this.fileUrl,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: identical(rejectionReason, _unset)
          ? this.rejectionReason
          : rejectionReason as String?,
    );
  }
}

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
  final String? ville;
  final String? quartier;
  final List<String>? requiredDocuments;
  final List<DossierDocument> documentsTracking;
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
    this.ville,
    this.quartier,
    this.requiredDocuments,
    this.documentsTracking = const [],
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
      ville: json['ville']?.toString(),
      quartier: json['quartier']?.toString(),
      requiredDocuments: (json['required_documents'] is List)
          ? (json['required_documents'] as List).map((e) => e.toString()).toList()
          : null,
      documentsTracking: (json['documents_tracking'] is List)
          ? (json['documents_tracking'] as List)
              .whereType<Map>()
              .map((e) => DossierDocument.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    return _parseNullableDate(value) ?? DateTime.now();
  }

  static DateTime? _parseNullableDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is Map && value.containsKey('_seconds')) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value['_seconds'] as int) * 1000 +
            ((value['_nanoseconds'] as int) ~/ 1000000),
      );
    }
    // Timestamp Firestore (duck typing pour éviter l'import cloud_firestore ici).
    try {
      final dynamic v = value;
      final DateTime? asDate = v.toDate();
      return asDate;
    } catch (_) {
      return null;
    }
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
      'ville': ville,
      'quartier': quartier,
      'required_documents': requiredDocuments,
      'documents_tracking': documentsTracking.map((d) => d.toJson()).toList(),
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
    String? ville,
    String? quartier,
    List<String>? requiredDocuments,
    List<DossierDocument>? documentsTracking,
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
      ville: ville ?? this.ville,
      quartier: quartier ?? this.quartier,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      documentsTracking: documentsTracking ?? this.documentsTracking,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
