import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminTransactionsController extends GetxController {
  // Données observables
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  // Filtres
  final RxString selectedFilter = 'all'.obs;
  final RxString selectedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;

      // Simulation de chargement des données
      await Future.delayed(const Duration(seconds: 2));

      // Données de démonstration pour les transactions
      transactions.assignAll([
        {
          'id': '1',
          'userName': 'Jean Dupont',
          'userEmail': 'jean@example.com',
          'type': 'Paiement concours',
          'amount': 25000,
          'currency': 'FCFA',
          'status': 'completed',
          'date': DateTime.now().subtract(const Duration(hours: 2)),
          'reference': 'TXN-2024-001',
          'service': 'Concours Polytechnique',
        },
        {
          'id': '2',
          'userName': 'Marie Claire',
          'userEmail': 'marie@example.com',
          'type': 'Paiement service',
          'amount': 15000,
          'currency': 'FCFA',
          'status': 'pending',
          'date': DateTime.now().subtract(const Duration(hours: 5)),
          'reference': 'TXN-2024-002',
          'service': 'Dossier Passeport',
        },
        {
          'id': '3',
          'userName': 'Pierre Martin',
          'userEmail': 'pierre@example.com',
          'type': 'Paiement inscription',
          'amount': 35000,
          'currency': 'FCFA',
          'status': 'failed',
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'reference': 'TXN-2024-003',
          'service': 'Inscription Universitaire',
        },
        {
          'id': '4',
          'userName': 'Sophie Dubois',
          'userEmail': 'sophie@example.com',
          'type': 'Paiement concours',
          'amount': 30000,
          'currency': 'FCFA',
          'status': 'completed',
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'reference': 'TXN-2024-004',
          'service': 'Concours Médecine',
        },
        {
          'id': '5',
          'userName': 'Antoine Leroy',
          'userEmail': 'antoine@example.com',
          'type': 'Paiement service',
          'amount': 20000,
          'currency': 'FCFA',
          'status': 'completed',
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'reference': 'TXN-2024-005',
          'service': 'Rapport de Stage',
        },
      ]);
    } catch (e) {
      print('Erreur lors du chargement des transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterTransactions(String filter) {
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Terminé';
      case 'pending':
        return 'En attente';
      case 'failed':
        return 'Échec';
      default:
        return 'Inconnu';
    }
  }
}
