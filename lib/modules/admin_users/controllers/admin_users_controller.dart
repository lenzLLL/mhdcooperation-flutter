import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminUsersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Données observables
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _allUsers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  // Filtres
  final RxString selectedFilter = 'all'.obs;
  final RxString selectedRole = 'all'.obs;
  final RxString selectedCity = 'all'.obs;

  // Statistiques globales
  int get totalUsersCount => _allUsers.length;
  int get activeUsersCount => _allUsers.where((user) => user['status'] == 'active').length;
  int get inactiveUsersCount => _allUsers.where((user) => user['status'] == 'inactive').length;
  int get adminUsersCount => _allUsers
      .where((user) => user['role'] == 'admin' || user['role'] == 'sadmin')
      .length;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      users.clear();
      _allUsers.clear();

      final snapshot = await _firestore.collection('users').get();
      final loaded = snapshot.docs.map(_mapUser).toList();

      _allUsers.assignAll(loaded);
      _applyFilters();
    } catch (e) {
      // Jamais de données factices : un échec doit se voir comme un échec.
      users.clear();
      _allUsers.clear();
      Get.snackbar(
        'Erreur',
        'Impossible de charger les utilisateurs. Vérifiez votre connexion.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _mapUser(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final normalizedRole = data['role']?.toString().toLowerCase() ?? 'user';
    // `disabled` (bool) est le champ partagé avec la version web ; on garde le
    // repli sur l'ancien champ `status` pour les documents historiques.
    final bool isDisabled =
        data['disabled'] == true ||
        data['status']?.toString().toLowerCase() == 'inactive';
    return {
      'id': doc.id,
      'name': data['name']?.toString() ?? '',
      'email': data['email']?.toString() ?? '',
      'phone':
          data['phone_number']?.toString() ?? data['phone']?.toString() ?? '',
      'role': normalizedRole,
      'status': isDisabled ? 'inactive' : 'active',
      'registrationDate': _parseDateTime(
        data['created_at'] ?? data['createdAt'],
      ),
      'lastLogin': _parseDateTime(
        data['updated_at'] ?? data['last_login'] ?? data['lastLogin'],
      ),
      'totalTransactions': data['total_transactions'] is num
          ? (data['total_transactions'] as num).toInt()
          : int.tryParse(data['total_transactions']?.toString() ?? '') ?? 0,
      'totalSpent': data['total_spent'] is num
          ? (data['total_spent'] as num).toInt()
          : int.tryParse(data['total_spent']?.toString() ?? '') ?? 0,
      'profilePicture':
          data['picture_url']?.toString() ??
          data['profile_picture']?.toString(),
      'city': data['city']?.toString() ?? 'Non spécifié',
    };
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is Map<String, dynamic> && value.containsKey('_seconds')) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value['_seconds'] as int) * 1000 +
            ((value['_nanoseconds'] as int) ~/ 1000000),
      );
    }
    return DateTime.now();
  }

  void filterUsers(String filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  void filterByRole(String role) {
    selectedRole.value = role;
    _applyFilters();
  }

  void filterByCity(String city) {
    selectedCity.value = city;
    _applyFilters();
  }

  void _applyFilters() {
    final filtered = _allUsers.where((user) {
      if (selectedFilter.value == 'active' && user['status'] != 'active') {
        return false;
      }
      if (selectedFilter.value == 'inactive' && user['status'] != 'inactive') {
        return false;
      }

      if (selectedRole.value != 'all' && user['role'] != selectedRole.value) {
        return false;
      }

      if (selectedCity.value != 'all' && user['city'] != selectedCity.value) {
        return false;
      }

      if (selectedFilter.value == 'recent') {
        final createdAt = user['registrationDate'] as DateTime;
        return createdAt.isAfter(
          DateTime.now().subtract(const Duration(days: 7)),
        );
      }

      return true;
    }).toList();

    users.assignAll(filtered);
  }

  /// Met à jour le doc localement dans les DEUX listes (filtrée + complète),
  /// sinon les statistiques restent calculées sur des données périmées.
  void _patchLocal(String userId, Map<String, dynamic> patch) {
    for (final list in [users, _allUsers]) {
      final index = list.indexWhere((user) => user['id'] == userId);
      if (index != -1) {
        list[index] = {...list[index], ...patch};
      }
    }
    users.refresh();
    _allUsers.refresh();
  }

  Future<void> toggleUserStatus(String userId) async {
    final userIndex = users.indexWhere((user) => user['id'] == userId);
    if (userIndex == -1) return;
    final bool disable = users[userIndex]['status'] == 'active';
    try {
      // Persistance réelle : `disabled` est le champ lu par la version web,
      // `status` reste écrit pour les anciens lecteurs.
      await _firestore.collection('users').doc(userId).update({
        'disabled': disable,
        'status': disable ? 'inactive' : 'active',
        'updated_at': FieldValue.serverTimestamp(),
      });
      _patchLocal(userId, {'status': disable ? 'inactive' : 'active'});
    } catch (e) {
      Get.snackbar(
        'Erreur',
        "Le changement de statut n'a pas pu être enregistré.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> changeUserRole(String userId, String newRole) async {
    try {
      // Rôle écrit en MAJUSCULES : convention du modèle (USER/ADMIN/SADMIN),
      // également celle qu'écrit la version web.
      await _firestore.collection('users').doc(userId).update({
        'role': newRole.toUpperCase(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      _patchLocal(userId, {'role': newRole.toLowerCase()});
    } catch (e) {
      Get.snackbar(
        'Erreur',
        "Le changement de rôle n'a pas pu être enregistré.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA';
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return 'Utilisateur';
      case 'admin':
        return 'Administrateur';
      case 'sadmin':
      case 'superadmin':
        return 'Super Admin';
      default:
        return 'Inconnu';
    }
  }

  Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return Colors.blue;
      case 'admin':
        return Colors.orange;
      case 'sadmin':
      case 'superadmin':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Actif';
      case 'inactive':
        return 'Inactif';
      default:
        return 'Inconnu';
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
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

  List<String> getAllCities() {
    final cities = <String>{};
    for (final user in _allUsers) {
      final city = user['city'] as String?;
      if (city != null && city.isNotEmpty && city != 'Non spécifié') {
        cities.add(city);
      }
    }
    return ['all', ...cities.toList()..sort()];
  }
}
