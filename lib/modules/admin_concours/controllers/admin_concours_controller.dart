import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/concours.dart';
import 'package:mhdcooperation/data/models/ecoles.dart';
import 'package:mhdcooperation/data/services/concours_service.dart';
import 'dart:io';

class AdminConcoursController extends GetxController {
  final ConcoursService _concoursService = ConcoursService();

  // Données observables
  final RxList<Concours> concoursItems = <Concours>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Filtres
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadConcours();
  }

  Future<List<School>> getSchools() async {
    return _concoursService.getAllSchools();
  }

  Future<void> loadConcours() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final loadedConcours = await _concoursService.getAllConcours();
      concoursItems.assignAll(loadedConcours);
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des concours: $e';
      print('Error loading concours: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addConcours({
    required String title,
    required String description,
    required String schoolId,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? applicationDeadline,
    String? status,
    double? applicationFees,
    String? sessionCategory,
    int? ageLimit,
    File? photoFile,
    File? docFile,
    File? pdfFile,
    String? ville,
  }) async {
    try {
      isLoading.value = true;
      await _concoursService.addConcours(
        title: title,
        description: description,
        schoolId: schoolId,
        startDate: startDate,
        endDate: endDate,
        applicationDeadline: applicationDeadline,
        status: status,
        applicationFees: applicationFees,
        sessionCategory: sessionCategory,
        ageLimit: ageLimit,
        photoFile: photoFile,
        docFile: docFile,
        pdfFile: pdfFile,
        ville: ville,
      );
      await loadConcours();
    } catch (e) {
      errorMessage.value = 'Erreur lors de l\'ajout: $e';
      print('Error adding concours: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateConcours({
    required String id,
    required String title,
    required String description,
    required String schoolId,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? applicationDeadline,
    String? status,
    double? applicationFees,
    String? sessionCategory,
    int? ageLimit,
    File? photoFile,
    File? docFile,
    File? pdfFile,
    String? ville,
  }) async {
    try {
      isLoading.value = true;
      await _concoursService.updateConcours(
        id: id,
        title: title,
        description: description,
        schoolId: schoolId,
        startDate: startDate,
        endDate: endDate,
        applicationDeadline: applicationDeadline,
        status: status,
        applicationFees: applicationFees,
        sessionCategory: sessionCategory,
        ageLimit: ageLimit,
        photoFile: photoFile,
        docFile: docFile,
        pdfFile: pdfFile,
        ville: ville,
      );
      await loadConcours();
    } catch (e) {
      errorMessage.value = 'Erreur lors de la modification: $e';
      print('Error updating concours: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteConcours(String id) async {
    try {
      isLoading.value = true;
      await _concoursService.deleteConcours(id);
      await loadConcours();
    } catch (e) {
      errorMessage.value = 'Erreur lors de la suppression: $e';
      print('Error deleting concours: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void searchConcours(String query) {
    searchQuery.value = query;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }
}
