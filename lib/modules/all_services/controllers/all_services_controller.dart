import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/services.dart';
import 'package:mhdcooperation/routes/app_routes.dart';

class AllServicesController extends GetxController {
  // Données observables
  final RxList<Services> services = <Services>[].obs;

  // État de chargement
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      isLoading.value = true;

      // Simulation de chargement des données
      await Future.delayed(const Duration(seconds: 2));

      // Données de démonstration pour les services
      services.assignAll([
        Services(
          id: '1',
          name: 'Dossiers Concours et Recrutements',
          desc:
              'Nous mettons à votre disposition la liste de tous les concours disponibles dans le territoire du Cameroun',
          iconUrl: 'https://via.placeholder.com/100/4CAF50/FFFFFF?text=I',
        ),
        Services(
          id: '2',
          name: 'Dossiers BTS, Licence, Bachelor, Master et HND',
          desc:
              "Constituez vos dossiers d examen facilement et rapidement grace à notre équipe expérimenté et dynamique",
          iconUrl: 'https://via.placeholder.com/100/2196F3/FFFFFF?text=C',
        ),
        Services(
          id: '3',
          name: 'Dossiers Passeport/CNI',
          desc:
              'Constituez vos dossiers de passeport ou de cni facilement et rapidement grace à notre équipe expérimenté et dynamique',
          iconUrl: 'https://via.placeholder.com/100/FF9800/FFFFFF?text=O',
        ),
        Services(
          id: '4',
          name: 'Dossiers certification IDE',
          desc:
              'Constituez vos dossiers de certification IDE facilement et rapidement grace à notre équipe expérimenté et dynamique',
          iconUrl: 'https://via.placeholder.com/100/9C27B0/FFFFFF?text=P',
        ),
        Services(
          id: '5',
          name: 'Rapport de stage',
          desc:
              'En cas de difficulté dans vos rapports de stage faites appel à notre équipe pour vous assister dans votre travail.',
          iconUrl: 'https://via.placeholder.com/100/9C27B0/FFFFFF?text=P',
        ),
        Services(
          id: '6',
          name: 'Dossiers inscription et préinscription universitaire',
          desc:
              "Vous voulez vous inscrire dans une université et vous ne savez pas comment faire? n'hésitez pas contactez nous",
        ),
      ]);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      // Gestion d'erreur
    }
  }

  void onServiceTap(Services service) {
    // Navigation vers les détails du service
    Get.toNamed(AppRoutes.serviceDetail, arguments: service);
  }
}
