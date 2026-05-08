import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/concours.dart';
import 'package:mhdcooperation/routes/app_routes.dart';

class AllConcoursController extends GetxController {
  // Données observables
  final RxList<Concours> concours = <Concours>[].obs;
  final RxList<Concours> upcomingConcours = <Concours>[].obs;
  final RxList<Concours> pastConcours = <Concours>[].obs;

  // État de chargement
  final RxBool isLoading = true.obs;

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

      // Simulation de chargement des données
      await Future.delayed(const Duration(seconds: 2));

      // Données de démonstration pour les concours
      concours.assignAll([
        Concours(
          id: '1',
          title: 'Concours d\'entrée - Cycle Ingénieur',
          description: 'Concours pour l\'accès au cycle ingénieur',
          schoolId: '1',
          schoolName: 'École Polytechnique',
          photoUrl: 'assets/images/c.jpg',
          startDate: DateTime.now().add(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 35)),
          applicationDeadline: DateTime.now().add(const Duration(days: 15)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          applicationFees: 25000,
          sessionCategory: 'Session de Juin 2026',
        ),
        Concours(
          id: '2',
          title: 'Concours d\'entrée - Première année',
          description: 'Concours pour l\'accès en première année de médecine',
          schoolId: '2',
          schoolName: 'Faculté de Médecine',
          photoUrl: 'assets/images/c.jpg',
          startDate: DateTime.now().add(const Duration(days: 45)),
          endDate: DateTime.now().add(const Duration(days: 50)),
          applicationDeadline: DateTime.now().add(const Duration(days: 20)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          applicationFees: 50000,
          sessionCategory: 'Session de Juillet 2026',
        ),
        Concours(
          id: '3',
          title: 'Concours d\'entrée - Master',
          description: 'Concours pour l\'accès au master en droit',
          schoolId: '3',
          schoolName: 'Faculté de Droit',
          photoUrl: 'assets/images/c.jpg',
          startDate: DateTime.now().add(const Duration(days: 60)),
          endDate: DateTime.now().add(const Duration(days: 65)),
          applicationDeadline: DateTime.now().add(const Duration(days: 25)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          applicationFees: 35000,
          sessionCategory: 'Session d\'Août 2026',
        ),
        Concours(
          id: '4',
          title: 'Concours d\'entrée - Licence',
          description: 'Concours pour l\'accès en licence',
          schoolId: '4',
          schoolName: 'École Normale Supérieure',
          photoUrl: 'https://via.placeholder.com/200/9C27B0/FFFFFF?text=ENS',
          startDate: DateTime.now().add(const Duration(days: 50)),
          endDate: DateTime.now().add(const Duration(days: 55)),
          applicationDeadline: DateTime.now().add(const Duration(days: 18)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          applicationFees: 20000,
          sessionCategory: 'Session de Septembre 2026',
        ),
        // Ajout de concours passés pour démonstration
        Concours(
          id: '5',
          title: 'Concours d\'entrée - BTS 2025',
          description: 'Concours BTS année académique 2024-2025',
          schoolId: '1',
          schoolName: 'École Polytechnique',
          photoUrl: 'https://via.placeholder.com/200/607D8B/FFFFFF?text=BTS',
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().subtract(const Duration(days: 25)),
          applicationDeadline: DateTime.now().subtract(
            const Duration(days: 45),
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now().subtract(const Duration(days: 60)),
          applicationFees: 15000,
          sessionCategory: 'Session de Mars 2025',
        ),
      ]);

      _separateConcours();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      // Gestion d'erreur
    }
  }

  void onConcoursTap(Concours concours) {
    // Navigation vers les détails du concours
    Get.toNamed(AppRoutes.concoursDetail, arguments: concours);
  }
}
