import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/services/dossier_service.dart';
import 'package:mhdcooperation/data/models/dossier_model.dart';

class AdminDossiersController extends GetxController {
  final DossierService _dossierService = Get.find<DossierService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Données observables
  final RxList<Map<String, dynamic>> dossiers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _allDossiers =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  // Filtres
  final RxString selectedFilter = 'all'.obs;
  final RxString selectedStatus = 'all'.obs;
  final RxString selectedCity = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadDossiers();
  }

  Future<void> loadDossiers() async {
    try {
      isLoading.value = true;
      dossiers.clear();
      _allDossiers.clear();

      final loaded = await _dossierService.loadAllDossiersFromFirestore();

      // Batch-fetch user cities
      final userIds =
          loaded.map((d) => d.userId).where((id) => id.isNotEmpty).toSet();
      final cityMap = await _fetchUserCities(userIds.toList());

      final mapped = loaded
          .map((d) => _mapDossier(d, cityMap[d.userId]))
          .toList();
      _allDossiers.assignAll(mapped);
      _applyFilters();
    } catch (_) {
      _allDossiers.clear();
      dossiers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, String>> _fetchUserCities(List<String> userIds) async {
    final result = <String, String>{};
    if (userIds.isEmpty) return result;
    const chunkSize = 10;
    for (var i = 0; i < userIds.length; i += chunkSize) {
      final chunk = userIds.sublist(
        i,
        (i + chunkSize) > userIds.length ? userIds.length : i + chunkSize,
      );
      try {
        final snap = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final doc in snap.docs) {
          result[doc.id] = doc.data()['city']?.toString() ?? '';
        }
      } catch (_) {}
    }
    return result;
  }

  Map<String, dynamic> _mapDossier(DossierModel dossier, String? city) {
    return {
      'id': dossier.id,
      'userId': dossier.userId,
      'userName': dossier.userName ?? dossier.userId,
      'userEmail': dossier.userEmail ?? '',
      'city': city ?? '',
      'type': dossier.itemTitle?.trim().isNotEmpty == true
          ? dossier.itemTitle
          : dossier.itemType,
      'status': dossier.status,
      'dateCreation': dossier.createdAt,
      'dateModification': dossier.updatedAt,
      'documents': <String>[],
      'montant': dossier.amount?.toInt() ?? 0,
    };
  }

  void filterDossiers(String filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void filterByCity(String city) {
    selectedCity.value = city;
    _applyFilters();
  }

  List<String> getAllCities() {
    final cities = <String>{};
    for (final d in _allDossiers) {
      final city = d['city'] as String?;
      if (city != null && city.isNotEmpty) cities.add(city);
    }
    return ['all', ...cities.toList()..sort()];
  }

  void _applyFilters() {
    final filtered = _allDossiers.where((dossier) {
      if (selectedStatus.value != 'all' &&
          dossier['status']?.toString() != selectedStatus.value) {
        return false;
      }

      if (selectedCity.value != 'all' &&
          dossier['city']?.toString() != selectedCity.value) {
        return false;
      }

      if (selectedFilter.value == 'recent') {
        final createdAt = dossier['dateCreation'] as DateTime;
        return createdAt.isAfter(
          DateTime.now().subtract(const Duration(days: 7)),
        );
      }

      return true;
    }).toList();

    dossiers.assignAll(filtered);
  }

  String formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA';
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'valide':
        return Colors.green;
      case 'en_cours':
        return Colors.blue;
      case 'incomplet':
        return Colors.orange;
      case 'rejete':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'valide':
        return 'Validé';
      case 'en_cours':
        return 'En cours';
      case 'incomplet':
        return 'Incomplet';
      case 'rejete':
        return 'Rejeté';
      default:
        return 'Inconnu';
    }
  }

  int get totalDossiers => _allDossiers.length;

  int get validDossiers => _allDossiers
      .where((dossier) => dossier['status'] == 'valide')
      .length;

  int get inProgressDossiers => _allDossiers
      .where((dossier) => dossier['status'] == 'en_cours')
      .length;

  int get incompleteDossiers => _allDossiers
      .where((dossier) => dossier['status'] == 'incomplet')
      .length;

  bool isExpired(DateTime? echeance) {
    // No expiration logic - return false
    return false;
  }
}
