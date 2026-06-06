import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/concours.dart';
import 'package:mhdcooperation/data/services/concours_service.dart';
import 'package:mhdcooperation/routes/app_routes.dart';

class AllConcoursController extends GetxController {
  // Services
  final ConcoursService _concoursService = ConcoursService();

  // Données observables
  final RxList<Concours> concours = <Concours>[].obs;
  final RxList<Concours> upcomingConcours = <Concours>[].obs;
  final RxList<Concours> pastConcours = <Concours>[].obs;

  // État de chargement et d'erreur
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Index du tab sélectionné
  final RxInt selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadConcours();
  }

  void _separateConcours() {
    final now = DateTime.now();
    upcomingConcours.assignAll(
      concours
          .where(
            (c) =>
                c.applicationDeadline != null &&
                c.applicationDeadline!.isAfter(now),
          )
          .toList(),
    );
    pastConcours.assignAll(
      concours
          .where(
            (c) =>
                c.applicationDeadline == null ||
                c.applicationDeadline!.isBefore(now),
          )
          .toList(),
    );
  }

  Future<void> loadConcours() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Charger tous les concours depuis Firebase
      final loadedConcours = await _concoursService.getAllConcours();
      concours.assignAll(loadedConcours);

      // Séparer les concours en cours et passés
      _separateConcours();
    } catch (e) {
      hasError.value = true;
      errorMessage.value =
          'Erreur lors du chargement des concours. Vérifiez votre connexion internet.';
      if (kDebugMode) {
        print('Error loading concours: $e');
        errorMessage.value = 'Erreur: $e';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onConcoursTap(Concours concours) {
    // Navigation vers les détails du concours
    Get.toNamed(AppRoutes.concoursDetail, arguments: concours);
  }
}
