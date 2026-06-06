import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/concours.dart';
import 'package:mhdcooperation/data/models/ecoles.dart';
import 'package:mhdcooperation/data/services/school_service.dart';

class SchoolDetailController extends GetxController {
  final SchoolService _schoolService = SchoolService();

  late School school;
  final concoursList = <Concours>[].obs;
  final upcomingConcours = <Concours>[].obs;
  final pastConcours = <Concours>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    school = Get.arguments as School;
    fetchConcours();
  }

  Future<void> fetchConcours() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final concours = await _schoolService.getConcoursBySchool(school.id);
      concoursList.value = concours;
      _categorizeConcours(concours);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Erreur lors du chargement des concours: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _categorizeConcours(List<Concours> concours) {
    final now = DateTime.now();
    upcomingConcours.value = concours
        .where((c) => c.startDate.isAfter(now))
        .toList();
    pastConcours.value = concours
        .where(
          (c) => c.startDate.isBefore(now) || c.startDate.isAtSameMomentAs(now),
        )
        .toList();
  }
}
