import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/ecoles.dart';
import 'package:mhdcooperation/data/services/school_service.dart';
import 'package:mhdcooperation/routes/app_routes.dart';

class AllSchoolsController extends GetxController {
  // Services
  final SchoolService _schoolService = SchoolService();

  // Données observables
  final RxList<School> schools = <School>[].obs;

  // État de chargement et d'erreur
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSchools();
  }

  Future<void> loadSchools() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Charger toutes les écoles depuis Firebase
      final loadedSchools = await _schoolService.getAllSchools();
      schools.assignAll(loadedSchools);

    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des écoles. Vérifiez votre connexion internet.';
      if (kDebugMode) {
        print('Error loading schools: $e');
        errorMessage.value = 'Erreur: $e';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onSchoolTap(School school) {
    // Navigation vers les détails de l'école
    Get.toNamed(AppRoutes.schoolDetail, arguments: school);
  }
}
