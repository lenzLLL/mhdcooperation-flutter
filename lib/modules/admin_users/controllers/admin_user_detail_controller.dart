import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/dossier_model.dart';
import 'package:mhdcooperation/data/services/dossier_service.dart';

class AdminUserDetailController extends GetxController {
  final String userId;
  final DossierService _dossierService = Get.find<DossierService>();

  final RxList<DossierModel> dossiers = <DossierModel>[].obs;
  final RxBool isLoading = true.obs;

  AdminUserDetailController({required this.userId});

  @override
  void onInit() {
    super.onInit();
    loadUserDossiers();
  }

  Future<void> loadUserDossiers() async {
    try {
      isLoading.value = true;
      dossiers.clear();
      final results = await _dossierService.loadDossiersForUser(userId);
      dossiers.assignAll(results);
    } catch (e) {
      print('Erreur lors du chargement des dossiers utilisateur: $e');
      dossiers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String formatAmount(double? amount) {
    if (amount == null) return 'N/A';
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }

  String getDossierLabel(DossierModel dossier) {
    if (dossier.itemTitle != null && dossier.itemTitle!.isNotEmpty) {
      return dossier.itemTitle!;
    }
    return dossier.itemType == 'concours' ? 'Concours' : 'Service';
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'valide':
        return 'Validé';
      case 'en_cours':
        return 'En cours';
      case 'incomplet':
        return 'Incomplet';
      case 'rejete':
        return 'Rejeté';
      case 'paid':
        return 'Payé';
      case 'pending':
        return 'En attente';
      default:
        return status;
    }
  }

  String getTypeText(DossierModel dossier) {
    return dossier.itemType.toLowerCase() == 'concours'
        ? 'Concours'
        : 'Service';
  }

  bool isExpired(DossierModel dossier) {
    return dossier.updatedAt.isBefore(DateTime.now());
  }
}
