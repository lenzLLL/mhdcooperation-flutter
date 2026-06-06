import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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
      createdAt: now,
      updatedAt: now,
    );

    final data = dossier.toJson();
    data['date_de_depot'] = Timestamp.fromDate(now);
    data['created_at'] = FieldValue.serverTimestamp();
    data['updated_at'] = FieldValue.serverTimestamp();

    await docRef.set(data);
    await addDossier(dossier);

    final transactionData = <String, dynamic>{
      'user_id': userId,
      'type':
          itemType?.toLowerCase() == 'concours' ||
              itemType?.toLowerCase() == 'concour'
          ? 'concours'
          : 'service',
      'amount': amount,
      'status': 'completed',
      'created_at': FieldValue.serverTimestamp(),
      'gateway': gateway,
      'payment_phone': userPhone,
      'libelle': itemTitle ?? '',
      'service_id': serviceId,
      'concours_id': concoursId,
      'dossier_id': docRef.id,
    };
    await _firestore.collection('transactions').add(transactionData);

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
}
