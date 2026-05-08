import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/ecoles.dart';
import 'package:mhdcooperation/routes/app_routes.dart';

class AllSchoolsController extends GetxController {
  // Données observables
  final RxList<School> schools = <School>[].obs;

  // État de chargement
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSchools();
  }

  Future<void> loadSchools() async {
    try {
      isLoading.value = true;

      // Simulation de chargement des données
      await Future.delayed(const Duration(seconds: 2));

      // Données de démonstration pour les écoles
      schools.assignAll([
        School(
          id: '1',
          name: 'École Polytechnique',
          description: 'École d\'ingénieurs de renom',
          address: 'Yaoundé',
          logoUrl: 'https://via.placeholder.com/100/4CAF50/FFFFFF?text=Poly',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          category: 'Supérieur',
        ),
        School(
          id: '2',
          name: 'Faculté de Médecine',
          description: 'Formation médicale de qualité',
          address: 'Douala',
          logoUrl: 'https://via.placeholder.com/100/2196F3/FFFFFF?text=Med',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          category: 'Supérieur',
        ),
        School(
          id: '3',
          name: 'Faculté de Droit',
          description: 'Excellence en sciences juridiques',
          address: 'Yaoundé',
          logoUrl: 'https://via.placeholder.com/100/FF9800/FFFFFF?text=Droit',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          category: 'Supérieur',
        ),
        School(
          id: '4',
          name: 'École Normale Supérieure',
          description: 'Formation des enseignants',
          address: 'Yaoundé',
          logoUrl: 'https://via.placeholder.com/100/9C27B0/FFFFFF?text=ENS',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          category: 'Supérieur',
        ),
      ]);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      // Gestion d'erreur
    }
  }

  void onSchoolTap(School school) {
    // Navigation vers les détails de l'école
    Get.toNamed(AppRoutes.schoolDetail, arguments: school);
  }
}
