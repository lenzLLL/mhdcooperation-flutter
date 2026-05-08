import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDossiersController extends GetxController {
  // Données observables
  final RxList<Map<String, dynamic>> dossiers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  // Filtres
  final RxString selectedFilter = 'all'.obs;
  final RxString selectedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadDossiers();
  }

  Future<void> loadDossiers() async {
    try {
      isLoading.value = true;

      // Simulation de chargement des données
      await Future.delayed(const Duration(seconds: 2));

      // Données de démonstration pour les dossiers
      dossiers.assignAll([
        {
          'id': '1',
          'userName': 'Jean Dupont',
          'userEmail': 'jean@example.com',
          'type': 'Concours Polytechnique',
          'status': 'en_cours',
          'dateCreation': DateTime.now().subtract(const Duration(days: 5)),
          'dateModification': DateTime.now().subtract(const Duration(hours: 2)),
          'documents': ['CV', 'Diplôme', 'Certificat'],
          'montant': 25000,
          'echeance': DateTime.now().add(const Duration(days: 10)),
        },
        {
          'id': '2',
          'userName': 'Marie Claire',
          'userEmail': 'marie@example.com',
          'type': 'Passeport/CNI',
          'status': 'valide',
          'dateCreation': DateTime.now().subtract(const Duration(days: 12)),
          'dateModification': DateTime.now().subtract(const Duration(days: 1)),
          'documents': [
            'Photo',
            'Acte de naissance',
            'Certificat de résidence',
          ],
          'montant': 15000,
          'echeance': DateTime.now().add(const Duration(days: 25)),
        },
        {
          'id': '3',
          'userName': 'Pierre Martin',
          'userEmail': 'pierre@example.com',
          'type': 'Inscription Universitaire',
          'status': 'incomplet',
          'dateCreation': DateTime.now().subtract(const Duration(days: 8)),
          'dateModification': DateTime.now().subtract(
            const Duration(hours: 12),
          ),
          'documents': ['Diplôme', 'Certificat médical'],
          'montant': 35000,
          'echeance': DateTime.now().add(const Duration(days: 15)),
        },
        {
          'id': '4',
          'userName': 'Sophie Dubois',
          'userEmail': 'sophie@example.com',
          'type': 'Certification IDE',
          'status': 'rejete',
          'dateCreation': DateTime.now().subtract(const Duration(days: 15)),
          'dateModification': DateTime.now().subtract(const Duration(days: 3)),
          'documents': ['CV', 'Lettre de motivation', 'Attestation'],
          'montant': 20000,
          'echeance': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'id': '5',
          'userName': 'Antoine Leroy',
          'userEmail': 'antoine@example.com',
          'type': 'Rapport de Stage',
          'status': 'valide',
          'dateCreation': DateTime.now().subtract(const Duration(days: 20)),
          'dateModification': DateTime.now().subtract(const Duration(days: 5)),
          'documents': ['Rapport', 'Attestation de stage', 'Évaluation'],
          'montant': 18000,
          'echeance': DateTime.now().add(const Duration(days: 30)),
        },
      ]);
    } catch (e) {
      print('Erreur lors du chargement des dossiers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterDossiers(String filter) {
    selectedFilter.value = filter;
    // TODO: Implémenter le filtrage
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    // TODO: Implémenter le filtrage par statut
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

  bool isExpired(DateTime echeance) {
    return echeance.isBefore(DateTime.now());
  }
}
