import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/values/app_value.dart';
import '../models/dossier_model.dart';
import 'notification_service.dart';
import 'storage_service.dart';

class DossierService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DossierService> init() async {
    return this;
  }

  CollectionReference<Map<String, dynamic>> get _dossierCollection =>
      _firestore.collection('dossiers');

  Future<List<DossierModel>> loadDossiers() async {
    final raw = await _storage.getString(AppValues.keyDossiers);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((item) => DossierModel.fromJson(item))
            .toList();
      }
    } catch (_) {
      // Ignore invalid JSON and return empty list
    }

    return [];
  }

  static const int pageSize = 15;

  Future<({List<DossierModel> items, QueryDocumentSnapshot<Map<String, dynamic>>? lastDoc})> loadDossiersPage(
    String userId, {
    QueryDocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _dossierCollection
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(pageSize);
      if (startAfter != null) query = query.startAfterDocument(startAfter);
      final snapshot = await query.get();
      final items = snapshot.docs
          .map((doc) => DossierModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
      return (items: items, lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null);
    } on FirebaseException catch (_) {
      Query<Map<String, dynamic>> query = _dossierCollection
          .where('user_id', isEqualTo: userId)
          .limit(pageSize);
      final snapshot = await query.get();
      final items = snapshot.docs
          .map((doc) => DossierModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return (items: items, lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null);
    }
  }

  Future<List<DossierModel>> loadDossiersForUser(String userId) async {
    try {
      final snapshot = await _dossierCollection
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DossierModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint(
        'Firestore query failed: ${e.message}. Retrying without orderBy.',
      );
      final snapshot = await _dossierCollection
          .where('user_id', isEqualTo: userId)
          .get();
      final dossiers = snapshot.docs
          .map((doc) => DossierModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
      dossiers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return dossiers;
    }
  }

  Future<List<DossierModel>> loadAllDossiersFromFirestore() async {
    final snapshot = await _dossierCollection
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => DossierModel.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  Future<void> _saveDossiers(List<DossierModel> dossiers) async {
    final raw = jsonEncode(dossiers.map((d) => d.toJson()).toList());
    await _storage.saveString(AppValues.keyDossiers, raw);
  }

  Future<void> addDossier(DossierModel dossier) async {
    final dossiers = await loadDossiers();
    dossiers.add(dossier);
    await _saveDossiers(dossiers);
  }

  Future<DossierModel> createDossier({
    required String userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? serviceId,
    String? concoursId,
    String? itemTitle,
    String? itemType,
    required double amount,
    required String gateway,
    String status = 'en_cours',
    String? messages,
    String? links,
    String? ville,
    String? quartier,
    List<String>? requiredDocuments,
  }) async {
    final now = DateTime.now();
    final docRef = _dossierCollection.doc();
    final dossier = DossierModel(
      id: docRef.id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      serviceId: serviceId,
      concoursId: concoursId,
      itemTitle: itemTitle,
      itemType: itemType ?? 'service',
      dateDeDepot: now,
      amount: amount,
      gateway: gateway,
      status: status,
      messages: messages,
      links: links,
      ville: ville,
      quartier: quartier,
      requiredDocuments: requiredDocuments,
      createdAt: now,
      updatedAt: now,
    );

    final data = dossier.toJson();
    data['date_de_depot'] = Timestamp.fromDate(now);
    data['created_at'] = FieldValue.serverTimestamp();
    data['updated_at'] = FieldValue.serverTimestamp();
    // Initialize per-document tracking from required docs list
    if (requiredDocuments != null && requiredDocuments.isNotEmpty) {
      data['documents_tracking'] = requiredDocuments
          .map((name) => DossierDocument(name: name).toJson())
          .toList();
    }

    await docRef.set(data);
    await addDossier(dossier);

    if (Get.isRegistered<NotificationService>()) {
      final notificationService = Get.find<NotificationService>();
      final itemLabel = itemTitle ?? 'votre dossier';
      await notificationService.createNotification(
        userId: userId,
        title: 'Dossier créé',
        message:
            'Votre dossier pour $itemLabel a bien été créé et est maintenant en cours.',
        type: 'DOSSIER',
        sent: true,
      );
    }

    return dossier;
  }

  // ─── Per-document tracking ────────────────────────────────────────────────

  Future<List<DossierDocument>> _fetchDocumentsTracking(String dossierId) async {
    final snap = await _dossierCollection.doc(dossierId).get();
    final raw = snap.data()?['documents_tracking'] as List<dynamic>? ?? [];
    return raw
        .map((e) => DossierDocument.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _saveDocumentsTracking(
      String dossierId, List<DossierDocument> docs) async {
    await _dossierCollection.doc(dossierId).update({
      'documents_tracking': docs.map((d) => d.toJson()).toList(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// User uploads a file for one required document.
  Future<String> uploadDocumentFile(
      String dossierId, String docName, File file) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last.split('\\').last}';
    final ref = FirebaseStorage.instance
        .ref('dossiers/$dossierId/docs/$fileName');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    final docs = await _fetchDocumentsTracking(dossierId);
    final idx = docs.indexWhere((d) => d.name == docName);
    if (idx >= 0) {
      docs[idx] = docs[idx].copyWith(
        status: 'uploaded',
        fileUrl: url,
        uploadedAt: DateTime.now(),
        rejectionReason: null,
      );
    } else {
      docs.add(DossierDocument(
        name: docName,
        status: 'uploaded',
        fileUrl: url,
        uploadedAt: DateTime.now(),
      ));
    }
    await _saveDocumentsTracking(dossierId, docs);
    return url;
  }

  /// Admin validates one document.
  Future<void> validateDocument(String dossierId, String docName) async {
    final docs = await _fetchDocumentsTracking(dossierId);
    final idx = docs.indexWhere((d) => d.name == docName);
    if (idx >= 0) {
      docs[idx] = docs[idx].copyWith(
        status: 'validated',
        reviewedAt: DateTime.now(),
        rejectionReason: null,
      );
    }
    await _saveDocumentsTracking(dossierId, docs);
    _autoUpdateDossierStatus(dossierId, docs);
  }

  /// Admin rejects one document with a reason.
  Future<void> rejectDocument(
      String dossierId, String docName, String reason) async {
    final docs = await _fetchDocumentsTracking(dossierId);
    final idx = docs.indexWhere((d) => d.name == docName);
    if (idx >= 0) {
      docs[idx] = docs[idx].copyWith(
        status: 'rejected',
        rejectionReason: reason,
        reviewedAt: DateTime.now(),
      );
    }
    await _saveDocumentsTracking(dossierId, docs);
    _autoUpdateDossierStatus(dossierId, docs);
  }

  /// Auto-compute global dossier status from document statuses.
  void _autoUpdateDossierStatus(
      String dossierId, List<DossierDocument> docs) {
    if (docs.isEmpty) return;
    String newStatus;
    if (docs.every((d) => d.status == 'validated')) {
      newStatus = 'valide';
    } else if (docs.any((d) => d.status == 'rejected')) {
      newStatus = 'incomplet';
    } else {
      newStatus = 'en_cours';
    }
    _dossierCollection.doc(dossierId).update({
      'status': newStatus,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
