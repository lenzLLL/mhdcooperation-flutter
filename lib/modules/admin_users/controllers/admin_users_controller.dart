import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminUsersController extends GetxController {
  // Données observables
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  // Filtres
  final RxString selectedFilter = 'all'.obs;
  final RxString selectedRole = 'all'.obs;
  final RxString selectedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;

      // Simulation de chargement des données
      await Future.delayed(const Duration(seconds: 2));

      // Données de démonstration pour les utilisateurs
      users.assignAll([
        {
          'id': '1',
          'name': 'Jean Dupont',
          'email': 'jean@example.com',
          'phone': '+237 6XX XXX XXX',
          'role': 'user',
          'status': 'active',
          'registrationDate': DateTime.now().subtract(const Duration(days: 45)),
          'lastLogin': DateTime.now().subtract(const Duration(hours: 2)),
          'totalTransactions': 12,
          'totalSpent': 285000,
          'profilePicture': null,
        },
        {
          'id': '2',
          'name': 'Marie Claire',
          'email': 'marie@example.com',
          'phone': '+237 6XX XXX XXX',
          'role': 'user',
          'status': 'active',
          'registrationDate': DateTime.now().subtract(const Duration(days: 32)),
          'lastLogin': DateTime.now().subtract(const Duration(days: 1)),
          'totalTransactions': 8,
          'totalSpent': 195000,
          'profilePicture': null,
        },
        {
          'id': '3',
          'name': 'Pierre Martin',
          'email': 'pierre@example.com',
          'phone': '+237 6XX XXX XXX',
          'role': 'admin',
          'status': 'active',
          'registrationDate': DateTime.now().subtract(
            const Duration(days: 120),
          ),
          'lastLogin': DateTime.now().subtract(const Duration(hours: 1)),
          'totalTransactions': 0,
          'totalSpent': 0,
          'profilePicture': null,
        },
        {
          'id': '4',
          'name': 'Sophie Dubois',
          'email': 'sophie@example.com',
          'phone': '+237 6XX XXX XXX',
          'role': 'user',
          'status': 'inactive',
          'registrationDate': DateTime.now().subtract(const Duration(days: 15)),
          'lastLogin': DateTime.now().subtract(const Duration(days: 7)),
          'totalTransactions': 3,
          'totalSpent': 75000,
          'profilePicture': null,
        },
        {
          'id': '5',
          'name': 'Antoine Leroy',
          'email': 'antoine@example.com',
          'phone': '+237 6XX XXX XXX',
          'role': 'user',
          'status': 'active',
          'registrationDate': DateTime.now().subtract(const Duration(days: 67)),
          'lastLogin': DateTime.now().subtract(const Duration(hours: 12)),
          'totalTransactions': 15,
          'totalSpent': 420000,
          'profilePicture': null,
        },
        {
          'id': '6',
          'name': 'Admin Principal',
          'email': 'admin@mhdcooperation.com',
          'phone': '+237 6XX XXX XXX',
          'role': 'superadmin',
          'status': 'active',
          'registrationDate': DateTime.now().subtract(
            const Duration(days: 365),
          ),
          'lastLogin': DateTime.now().subtract(const Duration(minutes: 30)),
          'totalTransactions': 0,
          'totalSpent': 0,
          'profilePicture': null,
        },
      ]);
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterUsers(String filter) {
    selectedFilter.value = filter;
    // TODO: Implémenter le filtrage
  }

  void filterByRole(String role) {
    selectedRole.value = role;
    // TODO: Implémenter le filtrage par rôle
  }

  void toggleUserStatus(String userId) {
    final userIndex = users.indexWhere((user) => user['id'] == userId);
    if (userIndex != -1) {
      final currentStatus = users[userIndex]['status'];
      users[userIndex]['status'] = currentStatus == 'active'
          ? 'inactive'
          : 'active';
      users.refresh();
    }
  }

  void changeUserRole(String userId, String newRole) {
    final userIndex = users.indexWhere((user) => user['id'] == userId);
    if (userIndex != -1) {
      users[userIndex]['role'] = newRole;
      users.refresh();
    }
  }

  String formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA';
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String getRoleText(String role) {
    switch (role) {
      case 'user':
        return 'Utilisateur';
      case 'admin':
        return 'Administrateur';
      case 'superadmin':
        return 'Super Admin';
      default:
        return 'Inconnu';
    }
  }

  Color getRoleColor(String role) {
    switch (role) {
      case 'user':
        return Colors.blue;
      case 'admin':
        return Colors.orange;
      case 'superadmin':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Actif';
      case 'inactive':
        return 'Inactif';
      default:
        return 'Inconnu';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int getActiveUsersCount() {
    return users.where((user) => user['status'] == 'active').length;
  }

  int getInactiveUsersCount() {
    return users.where((user) => user['status'] == 'inactive').length;
  }

  int getAdminUsersCount() {
    return users.where((user) => user['role'] != 'user').length;
  }
}
