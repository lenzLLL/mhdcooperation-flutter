import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/dossier_message.dart';
import 'package:mhdcooperation/data/models/dossier_model.dart';
import 'package:mhdcooperation/data/services/session_service.dart';

class DossierDetailController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final SessionService _session = Get.find<SessionService>();

  late final TextEditingController messageController;
  final Rxn<DossierModel> dossier = Rxn<DossierModel>();
  final RxList<DossierMessage> messages = <DossierMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxList<String> attachedFiles = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    messageController = TextEditingController();
    final args = Get.arguments;

    // Handle both DossierModel and dossierId argument
    if (args is DossierModel) {
      dossier.value = args;
      loadMessages();
    } else if (args is Map && args['dossierId'] != null) {
      // Load dossier from Firestore using ID
      _loadDossierById(args['dossierId'] as String);
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  CollectionReference<Map<String, dynamic>> _messagesCollection(
    String dossierId,
  ) => _firestore.collection('dossiers').doc(dossierId).collection('messages');

  Future<void> _loadDossierById(String dossierId) async {
    try {
      isLoading.value = true;
      final doc = await _firestore.collection('dossiers').doc(dossierId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final dossierModel = DossierModel.fromJson({
            'id': dossierId,
            ...data,
          });
          dossier.value = dossierModel;
          await loadMessages();
        }
      }
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          title: 'Erreur',
          message: 'Impossible de charger le dossier',
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages() async {
    final d = dossier.value;
    if (d == null) return;
    isLoading.value = true;
    try {
      final snapshot = await _messagesCollection(
        d.id,
      ).orderBy('created_at', descending: true).get();
      final loaded = snapshot.docs
          .map((doc) => DossierMessage.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
      messages.assignAll(loaded);
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<String>> _uploadFiles(List<PlatformFile> files) async {
    final d = dossier.value;
    if (d == null) return [];
    isUploading.value = true;
    final uploadedUrls = <String>[];
    try {
      for (final f in files) {
        final file = File(f.path!);
        final ref = _storage.ref(
          'dossiers/${d.id}/${DateTime.now().millisecondsSinceEpoch}_${f.name}',
        );
        final uploadTask = await ref.putFile(file);
        final url = await uploadTask.ref.getDownloadURL();
        uploadedUrls.add(url);
      }
    } finally {
      isUploading.value = false;
    }
    return uploadedUrls;
  }

  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.pickFiles(allowMultiple: true);
      if (result != null && result.files.isNotEmpty) {
        final urls = await _uploadFiles(result.files);
        attachedFiles.addAll(urls);
      }
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          title: 'Erreur',
          message: 'Impossible d\'importer le fichier',
        ),
      );
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    final files = List<String>.from(attachedFiles);

    if (text.isEmpty && files.isEmpty) return;

    final d = dossier.value;
    if (d == null) return;
    final user = _session.currentUser.value;
    if (user == null) return;

    try {
      final isAdmin =
          user.role.toUpperCase() == 'ADMIN' ||
          user.role.toUpperCase() == 'SADMIN';
      final data = {
        'author_id': user.id,
        'author_name': isAdmin ? 'Administration' : user.name,
        'author_role': isAdmin ? 'Admin' : user.role,
        'text': text,
        'files': files,
        'created_at': FieldValue.serverTimestamp(),
      };

      final docRef = await _messagesCollection(d.id).add(data);
      final created = await docRef.get();
      final newMsg = DossierMessage.fromJson({
        'id': docRef.id,
        ...created.data()!,
      });

      messages.insert(0, newMsg);
      messageController.clear();
      attachedFiles.clear();

      // update dossier's updated_at + qui a écrit (pour les Cloud Functions)
      await _firestore.collection('dossiers').doc(d.id).update({
        'updated_at': FieldValue.serverTimestamp(),
        'last_updated_by_role': user.role.toUpperCase(),
      });
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          title: 'Erreur',
          message: 'Impossible d\'envoyer le message',
        ),
      );
    }
  }

  Future<void> updateDossierStatus(String status) async {
    final d = dossier.value;
    if (d == null) return;

    try {
      final currentUser = _session.currentUser.value;
      await _firestore.collection('dossiers').doc(d.id).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
        'last_updated_by_role': currentUser?.role.toUpperCase() ?? 'ADMIN',
      });
      dossier.value = d.copyWith(status: status);
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          title: 'Erreur',
          message: 'Impossible de mettre à jour le statut',
        ),
      );
    }
  }
}
