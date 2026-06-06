import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminMetricsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Données observables pour les métriques
  final RxInt totalUsers = 0.obs;
  final RxInt totalTransactions = 0.obs;
  final RxInt totalRevenue = 0.obs;
  final RxInt activeDossiers = 0.obs;
  final RxList<Map<String, dynamic>> revenueByService =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> userGrowth = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadMetrics();
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

  Future<void> loadMetrics() async {
    try {
      isLoading.value = true;

      final paymentDocs = await _loadPaymentDocuments();

      totalTransactions.value = paymentDocs.length;

      final paymentAmounts = paymentDocs.map((doc) {
        final amountRaw = doc.data()['amount'];
        if (amountRaw is num) {
          return amountRaw.toInt();
        }
        return int.tryParse(amountRaw?.toString() ?? '') ?? 0;
      }).toList();
      totalRevenue.value = paymentAmounts.fold(
        0,
        (sum, amount) => sum + amount,
      );

      final userIds = paymentDocs
          .map(
            (doc) =>
                doc.data()['user_id']?.toString() ??
                doc.data()['id_user']?.toString() ??
                '',
          )
          .where((id) => id.isNotEmpty)
          .toSet();
      totalUsers.value = userIds.length;

      final serviceSums = <String, int>{};
      for (final doc in paymentDocs) {
        final typeRaw =
            doc.data()['type']?.toString().toLowerCase() ?? 'service';
        final serviceKey = typeRaw == 'concour' || typeRaw == 'concours'
            ? 'Concours'
            : 'Service';
        final amountRaw = doc.data()['amount'];
        final amount = amountRaw is num
            ? amountRaw.toInt()
            : int.tryParse(amountRaw?.toString() ?? '') ?? 0;
        serviceSums[serviceKey] = (serviceSums[serviceKey] ?? 0) + amount;
      }

      final totalRevenueValue = totalRevenue.value;
      revenueByService.assignAll(
        serviceSums.entries.map((entry) {
          final percentage = totalRevenueValue > 0
              ? (entry.value / totalRevenueValue) * 100
              : 0.0;
          return {
            'service': entry.key,
            'revenue': entry.value,
            'percentage': percentage,
          };
        }).toList(),
      );

      final now = DateTime.now();
      final lastSixMonths = List.generate(6, (index) {
        final month = DateTime(now.year, now.month - 5 + index, 1);
        return month;
      });

      final monthCounts = <String, int>{};
      final transactionCounts = <String, int>{};
      for (final month in lastSixMonths) {
        final key = _monthLabel(month);
        monthCounts[key] = 0;
        transactionCounts[key] = 0;
      }

      for (final doc in paymentDocs) {
        final date = _parseTimestamp(
          doc.data()['created_at'] ?? doc.data()['date'],
        );
        final label = _monthLabel(DateTime(date.year, date.month, 1));
        if (monthCounts.containsKey(label)) {
          transactionCounts[label] = transactionCounts[label]! + 1;
        }
      }

      userGrowth.assignAll(
        lastSixMonths.map((month) {
          final label = _monthLabel(month);
          return {
            'month': label,
            'users': totalUsers.value,
            'transactions': transactionCounts[label] ?? 0,
          };
        }).toList(),
      );

      final dossiersSnapshot = await _firestore.collection('dossiers').get();
      activeDossiers.value = dossiersSnapshot.docs.where((doc) {
        final status = doc.data()['status']?.toString().toLowerCase() ?? '';
        return status != 'termine' && status != 'terminé';
      }).length;
    } catch (e) {
      print('Erreur lors du chargement des métriques: $e');
      totalUsers.value = 0;
      totalTransactions.value = 0;
      totalRevenue.value = 0;
      activeDossiers.value = 0;
      revenueByService.clear();
      userGrowth.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String _monthLabel(DateTime date) {
    const monthNames = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${monthNames[date.month - 1]} ${date.year.toString().substring(2)}';
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

  String formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k FCFA';
    }
    return '$amount FCFA';
  }

  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}k';
    }
    return number.toString();
  }

  double getGrowthPercentage() {
    if (userGrowth.length < 2) return 0.0;
    final current = userGrowth.last['users'];
    final previous = userGrowth[userGrowth.length - 2]['users'];
    return ((current - previous) / previous) * 100;
  }

  double getTransactionGrowthPercentage() {
    if (userGrowth.length < 2) return 0.0;
    final current = userGrowth.last['transactions'];
    final previous = userGrowth[userGrowth.length - 2]['transactions'];
    return ((current - previous) / previous) * 100;
  }
}
