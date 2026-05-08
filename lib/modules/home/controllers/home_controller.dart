import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/services.dart';
import 'package:mhdcooperation/data/models/ecoles.dart';
import 'package:mhdcooperation/data/models/concours.dart';

class HomeController extends GetxController {
  // Données observables
  final RxList<Services> services = <Services>[].obs;
  final RxList<Concours> concours = <Concours>[].obs;
  final RxList<School> ecoles = <School>[].obs;

  // État de chargement
  final RxBool isLoading = true.obs;

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
          id: '4',
          name: 'Rapport de stage',
          desc:
              'En cas de difficulté dans vos rapports de stage faites appel à notre équipe pour vous assister dans votre travail.',
          iconUrl: 'https://via.placeholder.com/100/9C27B0/FFFFFF?text=P',
        ),
        Services(
          id: '4',
          name: 'Dossiers inscription et préinscription universitaire',
          desc:
              "Vous voulez vous inscrire dans une université et vous ne savez pas comment faire? n'hésitez pas contactez nous",
          iconUrl: 'https://via.placeholder.com/100/9C27B0/FFFFFF?text=P',
        ),
      ]);

      // Données de démonstration pour les concours
      concours.assignAll([
        Concours(
          id: '1',
          title: 'Concours Polytechnique 2024',
          description: 'Concours d\'entrée à l\'École Polytechnique',
          schoolId: '1',
          schoolName: 'École Polytechnique',
          startDate: DateTime(2026, 7, 7),
          endDate: DateTime.now().add(const Duration(days: 30)),
          applicationDeadline: DateTime.now().add(
            const Duration(days: 66, hours: 17, minutes: 53),
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          applicationFees: 38000,
          sessionCategory: 'Scientifique',
          photoUrl: 'assets/images/c.jpg',
        ),
        Concours(
          id: '2',
          title: 'Concours Médecine 2024',
          description: 'Concours d\'entrée en faculté de médecine',
          schoolId: '2',
          schoolName: 'Faculté de Médecine',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 45)),
          applicationDeadline: DateTime.now().add(const Duration(days: 20)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          applicationFees: 75000,
          sessionCategory: 'Médical',
          photoUrl: 'assets/images/c.jpg',
        ),
        Concours(
          id: '3',
          title: 'Concours Droit 2024',
          description: 'Concours d\'entrée en faculté de droit',
          schoolId: '3',
          schoolName: 'Faculté de Droit',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 60)),
          applicationDeadline: DateTime.now().add(const Duration(days: 25)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          applicationFees: 30000,
          sessionCategory: 'Juridique',
          photoUrl: 'assets/images/c.jpg',
        ),
      ]);

      // Données de démonstration pour les écoles
      ecoles.assignAll([
        School(
          id: '1',
          name: 'École Polytechnique',
          address: 'BP 8390 Yaoundé',
          description: 'École d\'ingénieurs d\'excellence au Cameroun',
          logoUrl:
              'https://via.placeholder.com/100x100/4CAF50/FFFFFF?text=Polytechnique',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          category: 'Ingénierie',
        ),
        School(
          id: '2',
          name: 'Faculté de Médecine',
          address: 'BP 1364 Yaoundé',
          description: 'Formation médicale de qualité supérieure',
          logoUrl:
              'https://via.placeholder.com/100x100/2196F3/FFFFFF?text=Medecine',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          category: 'Médecine',
        ),
        School(
          id: '3',
          name: 'Faculté de Droit',
          address: 'BP 812 Yaoundé',
          description: 'Excellence en sciences juridiques',
          logoUrl:
              'https://via.placeholder.com/100x100/FF9800/FFFFFF?text=Droit',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          category: 'Droit',
        ),
        School(
          id: '4',
          name: 'École Normale Supérieure',
          address: 'BP 47 Yaoundé',
          description: 'Formation des enseignants d\'élite',
          logoUrl: 'https://via.placeholder.com/100x100/9C27B0/FFFFFF?text=ENS',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          category: 'Éducation',
        ),
      ]);
    } catch (e) {
      // Log error in production app
      debugPrint('Erreur lors du chargement des données: $e');
    } finally {
      isLoading.value = false;
    }
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
