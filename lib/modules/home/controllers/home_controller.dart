import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/services.dart';
import 'package:mhdcooperation/data/models/ecoles.dart';
import 'package:mhdcooperation/data/models/concours.dart';
import 'package:mhdcooperation/data/services/school_service.dart';
import 'package:mhdcooperation/data/services/concours_service.dart';

class HomeController extends GetxController {
  // Services
  final SchoolService _schoolService = SchoolService();
  final ConcoursService _concoursService = ConcoursService();

  // Données observables
  final RxList<Services> services = <Services>[].obs;
  final RxList<Concours> concours = <Concours>[].obs;
  final RxList<School> ecoles = <School>[].obs;

  // État de chargement et d'erreur
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Index du carrousel
  final RxInt carouselIndex = 0.obs;

  // Données du carrousel (informations importantes)
  final List<Map<String, String>> carouselItems = [
    {
      'title': 'Bienvenue sur MHD Cooperation',
      'subtitle': 'Votre plateforme de services éducatifs',
      'image': 'assets/images/s1.png',
    },
    {
      'title': 'Services Disponibles',
      'subtitle': 'Découvrez tous nos services éducatifs',
      'image': 'assets/images/s2.png',
    },
    {
      'title': 'Concours Académiques',
      'subtitle': 'Participez aux concours des meilleures écoles',
      'image': 'assets/images/s1.png',
    },
    {
      'title': 'Écoles Partenaires',
      'subtitle': 'Un réseau d\'excellence à votre service',
      'image': 'assets/images/s2.png',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Charger les services (données de démonstration pour l'instant)
      _loadDemoServices();

      // Charger maximum 5 écoles
      final loadedSchools = await _schoolService.getAllSchools();
      ecoles.assignAll(loadedSchools.take(5));

      // Charger les 10 concours à venir les plus proches
      final allConcours = await _concoursService.getAllConcours();
      final now = DateTime.now();
      final upcomingConcours =
          allConcours
              .where((concours) => concours.startDate.isAfter(now))
              .toList()
            ..sort((a, b) => a.startDate.compareTo(b.startDate));
      concours.assignAll(upcomingConcours.take(10));
    } catch (e) {
      hasError.value = true;
      errorMessage.value =
          'Erreur lors du chargement des données. Vérifiez votre connexion internet.';
      if (kDebugMode) {
        print('Error loading data: $e');
        errorMessage.value = 'Erreur: $e';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDemoServices() {
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
        iconUrl: 'https://via.placeholder.com/100/E91E63/FFFFFF?text=R',
      ),
      Services(
        id: '6',
        name: 'Dossiers inscription et préinscription universitaire',
        desc:
            "Vous voulez vous inscrire dans une université et vous ne savez pas comment faire? n'hésitez pas contactez nous",
        iconUrl: 'https://via.placeholder.com/100/607D8B/FFFFFF?text=U',
      ),
    ]);
  }

  void onCarouselChanged(int index) {
    carouselIndex.value = index;
  }

  void onServiceTap(Services service) {
    // Navigation vers les détails du service
    Get.toNamed('/service-details', arguments: service);
  }

  void onConcoursTap(Concours concours) {
    // Navigation vers les détails du concours
    Get.toNamed('/concours-details', arguments: concours);
  }

  void onSchoolTap(School school) {
    // Navigation vers les détails de l'école
    Get.toNamed('/school-details', arguments: school);
  }
}
