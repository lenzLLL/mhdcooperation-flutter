import 'package:get/get.dart';

class AdminMetricsController extends GetxController {
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

  Future<void> loadMetrics() async {
    try {
      isLoading.value = true;

      // Simulation de chargement des données
      await Future.delayed(const Duration(seconds: 2));

      // Métriques générales
      totalUsers.value = 1247;
      totalTransactions.value = 568;
      totalRevenue.value = 4525000; // en FCFA
      activeDossiers.value = 89;

      // Revenus par service
      revenueByService.assignAll([
        {'service': 'Concours', 'revenue': 1850000, 'percentage': 40.8},
        {'service': 'Passeports/CNI', 'revenue': 1250000, 'percentage': 27.6},
        {'service': 'Inscriptions', 'revenue': 890000, 'percentage': 19.7},
        {'service': 'Certifications', 'revenue': 335000, 'percentage': 7.4},
        {'service': 'Autres', 'revenue': 200000, 'percentage': 4.5},
      ]);

      // Croissance des utilisateurs (derniers 6 mois)
      userGrowth.assignAll([
        {'month': 'Oct', 'users': 980, 'transactions': 420},
        {'month': 'Nov', 'users': 1056, 'transactions': 445},
        {'month': 'Dec', 'users': 1123, 'transactions': 478},
        {'month': 'Jan', 'users': 1189, 'transactions': 512},
        {'month': 'Fev', 'users': 1215, 'transactions': 534},
        {'month': 'Mar', 'users': 1247, 'transactions': 568},
      ]);
    } catch (e) {
      print('Erreur lors du chargement des métriques: $e');
    } finally {
      isLoading.value = false;
    }
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
