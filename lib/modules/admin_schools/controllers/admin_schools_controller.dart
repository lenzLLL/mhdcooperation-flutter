import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/ecoles.dart';
import 'package:mhdcooperation/data/services/school_service.dart';
import 'dart:io';

class AdminSchoolsController extends GetxController {
  final SchoolService _schoolService = SchoolService();

  // Données observables
  final RxList<School> schools = <School>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Filtres
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSchools();
  }

  Future<void> loadSchools() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final loadedSchools = await _schoolService.getAllSchools();
      schools.assignAll(loadedSchools);
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des écoles: $e';
      print('Error loading schools: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> uploadLogoFile(File file) async {
    return _schoolService.uploadLogoFile(file);
  }

  Future<void> addSchool({
    required String name,
    required String description,
    required String category,
    String? address,
    String? logoUrl,
    File? logoFile,
    List<String> filieres = const [],
    Map<String, double> prixParNiveau = const {},
  }) async {
    try {
      isLoading.value = true;
      await _schoolService.addSchool(
        name: name,
        description: description,
        category: category,
        address: address,
        logoUrl: logoUrl,
        logoFile: logoFile,
        filieres: filieres,
        prixParNiveau: prixParNiveau,
      );
      await loadSchools();
    } catch (e) {
      errorMessage.value = 'Erreur lors de l\'ajout: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSchool({
    required String id,
    required String name,
    required String description,
    required String category,
    String? address,
    String? logoUrl,
    File? logoFile,
    bool clearLogo = false,
    List<String> filieres = const [],
    Map<String, double> prixParNiveau = const {},
  }) async {
    try {
      isLoading.value = true;
      await _schoolService.updateSchool(
        id: id,
        name: name,
        description: description,
        category: category,
        address: address,
        logoUrl: logoUrl,
        logoFile: logoFile,
        clearLogo: clearLogo,
        filieres: filieres,
        prixParNiveau: prixParNiveau,
      );
      await loadSchools();
    } catch (e) {
      errorMessage.value = 'Erreur lors de la modification: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSchool(String id) async {
    try {
      isLoading.value = true;
      await _schoolService.deleteSchool(id);
      await loadSchools();
    } catch (e) {
      errorMessage.value = 'Erreur lors de la suppression: $e';
      print('Error deleting school: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void searchSchools(String query) {
    searchQuery.value = query;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }
}
