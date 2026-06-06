import 'package:cloud_firestore/cloud_firestore.dart';

class DossierMessage {
  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String text;
  final List<String> files;
  final DateTime createdAt;

  DossierMessage({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.text,
    required this.files,
    required this.createdAt,
  });

  factory DossierMessage.fromJson(Map<String, dynamic> json) {
    final files = <String>[];
    if (json['files'] is List) {
      for (final f in json['files']) {
        files.add(f?.toString() ?? '');
      }
    }
    return DossierMessage(
      id: json['id']?.toString() ?? '',
      authorId: json['author_id']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? '',
      authorRole: json['author_role']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      files: files,
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
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
      'author_id': authorId,
      'author_name': authorName,
      'author_role': authorRole,
      'text': text,
      'files': files,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
