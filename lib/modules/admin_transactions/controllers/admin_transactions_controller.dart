import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminTransactionsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _allTransactions =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  // Filtres
  final RxString selectedFilter = 'all'.obs;
  final RxString selectedStatus = 'all'.obs;
  final RxString selectedCity = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _loadPaymentDocuments() async {
    final collectionNames = ['transactions', 'paiement', 'paiemant'];
    final paymentDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

    for (final name in collectionNames) {
      final snapshot = await _firestore.collection(name).get();
      paymentDocs.addAll(snapshot.docs);
    }

    return paymentDocs;
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      transactions.clear();
      _allTransactions.clear();

      final snapshot = await _loadPaymentDocuments();

      final userIds = <String>{};
      final payments = snapshot.map((doc) {
        final data = doc.data();
        final userId = (data['user_id'] ?? data['id_user'] ?? data['userId'])
            ?.toString();
        if (userId != null && userId.isNotEmpty) {
          userIds.add(userId);
        }

        final amountRaw = data['amount'];
        final amount = amountRaw is num
            ? amountRaw.toInt()
            : int.tryParse(amountRaw?.toString() ?? '') ?? 0;
        final paymentDate = _parseTimestamp(data['created_at'] ?? data['date']);
        final typeRaw = data['type']?.toString().toLowerCase() ?? 'service';
        final type = typeRaw == 'concour' || typeRaw == 'concours'
            ? 'Paiement concours'
            : 'Paiement service';

        return {
          'id': doc.id,
          'userId': userId ?? '',
          'reference': data['reference']?.toString() ?? doc.id,
          'type': type,
          'amount': amount,
          'status': data['status']?.toString().toLowerCase() ?? 'completed',
          'date': paymentDate,
          'libelle':
              data['libelle']?.toString() ?? data['label']?.toString() ?? '',
          'paymentPhone': data['payment_phone']?.toString() ?? '',
          'gateway': data['gateway']?.toString() ?? '',
        };
      }).toList();

      final userMap = await _loadUsers(userIds.toList());

      final enriched = payments.map((payment) {
        final userId = payment['userId'] as String;
        final user = userMap[userId];
        return {
          ...payment,
          'userName': user != null
              ? user['name']?.toString() ?? userId
              : userId,
          'userEmail': user != null ? user['email']?.toString() ?? '' : '',
          'userCity': user != null
              ? user['city']?.toString() ?? ''
              : '',
        };
      }).toList();

      enriched.sort((a, b) {
        final dateA = a['date'] as DateTime;
        final dateB = b['date'] as DateTime;
        return dateB.compareTo(dateA);
      });

      _allTransactions.assignAll(enriched);
      _applyFilters();
    } catch (e) {
      print('Erreur lors du chargement des transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, Map<String, dynamic>>> _loadUsers(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return {};

    try {
      final chunks = <List<String>>[];
      const chunkSize = 10;
      for (var i = 0; i < userIds.length; i += chunkSize) {
        chunks.add(
          userIds.sublist(
            i,
            i + chunkSize > userIds.length ? userIds.length : i + chunkSize,
          ),
        );
      }

      final Map<String, Map<String, dynamic>> userMap = {};
      for (final chunk in chunks) {
        final snapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final doc in snapshot.docs) {
          userMap[doc.id] = doc.data();
        }
      }
      return userMap;
    } catch (_) {
      return {};
    }
  }

  DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  void filterTransactions(String filter) {
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
    for (final t in _allTransactions) {
      final city = t['userCity'] as String?;
      if (city != null && city.isNotEmpty) cities.add(city);
    }
    return ['all', ...cities.toList()..sort()];
  }

  void _applyFilters() {
    final filtered = _allTransactions.where((transaction) {
      final date = transaction['date'] as DateTime;
      if (selectedFilter.value == 'today') {
        final now = DateTime.now();
        if (date.year != now.year ||
            date.month != now.month ||
            date.day != now.day) {
          return false;
        }
      } else if (selectedFilter.value == 'week') {
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        if (date.isBefore(weekAgo)) return false;
      } else if (selectedFilter.value == 'month') {
        final now = DateTime.now();
        if (date.year != now.year || date.month != now.month) {
          return false;
        }
      }

      if (selectedStatus.value != 'all' &&
          (transaction['status']?.toString().toLowerCase() ?? '') !=
              selectedStatus.value) {
        return false;
      }

      if (selectedCity.value != 'all' &&
          transaction['userCity']?.toString() != selectedCity.value) {
        return false;
      }

      return true;
    }).toList();

    transactions.assignAll(filtered);
  }

  String formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA';
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
