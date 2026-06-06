class Concours {
  final String id;
  final String title;
  final String description;
  final String schoolId;
  final String? schoolName;
  final String? schoolLogoUrl;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? applicationDeadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // e.g., 'active', 'closed', etc.
  final double? applicationFees;
  final String? sessionCategory;
  final String? photoUrl;
  final String? docUrl;
  final int? ageLimit;
  final String? pdfUrl;
  final String? ville;

  Concours({
    required this.id,
    required this.title,
    required this.description,
    required this.schoolId,
    this.schoolName,
    this.schoolLogoUrl,
    required this.startDate,
    required this.endDate,
    this.applicationDeadline,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'active',
    this.applicationFees,
    this.sessionCategory,
    this.photoUrl,
    this.docUrl,
    this.ageLimit,
    this.pdfUrl,
    this.ville,
  });

  factory Concours.fromJson(Map<String, dynamic> json) {
    return Concours(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      schoolId: json['school_id'] ?? '',
      schoolName: json['school_name'],
      schoolLogoUrl: json['school_logo_url'],
      startDate: DateTime.parse(
        json['start_date'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['end_date'] ?? DateTime.now().toIso8601String(),
      ),
      applicationDeadline: json['application_deadline'] != null
          ? DateTime.parse(json['application_deadline'])
          : null,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'active',
      applicationFees: json['application_fees'] != null
          ? double.tryParse(json['application_fees'].toString())
          : null,
      sessionCategory: json['session_category'],
      photoUrl: json['photo_url'],
      docUrl: json['doc_url'],
      ageLimit: json['age_limit'] != null
          ? int.tryParse(json['age_limit'].toString())
          : null,
      pdfUrl: json['pdf_url'],
      ville: json['ville'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'school_id': schoolId,
      'school_name': schoolName,
      'school_logo_url': schoolLogoUrl,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'application_deadline': applicationDeadline?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
      'application_fees': applicationFees,
      'session_category': sessionCategory,
      'photo_url': photoUrl,
      'doc_url': docUrl,
      'age_limit': ageLimit,
      'pdf_url': pdfUrl,
      'ville': ville,
    };
  }

  Concours copyWith({
    String? title,
    String? description,
    String? schoolId,
    String? schoolName,
    String? schoolLogoUrl,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? applicationDeadline,
    String? status,
    double? applicationFees,
    String? sessionCategory,
    String? photoUrl,
    String? docUrl,
    int? ageLimit,
    String? pdfUrl,
  }) {
    return Concours(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      schoolLogoUrl: schoolLogoUrl ?? this.schoolLogoUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status ?? this.status,
      applicationFees: applicationFees ?? this.applicationFees,
      sessionCategory: sessionCategory ?? this.sessionCategory,
      photoUrl: photoUrl ?? this.photoUrl,
      docUrl: docUrl ?? this.docUrl,
      ageLimit: ageLimit ?? this.ageLimit,
      pdfUrl: pdfUrl ?? this.pdfUrl,
    );
  }
}
