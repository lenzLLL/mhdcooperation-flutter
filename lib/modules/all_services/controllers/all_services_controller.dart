import 'package:get/get.dart';
import 'package:mhdcooperation/data/constants/services_catalog.dart';
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
    // Catalogue statique partagé (source unique, voir services_catalog.dart) :
    // pas de faux délai de chargement pour des données locales.
    services.assignAll(servicesCatalog);
    isLoading.value = false;
  }

  void onServiceTap(Services service) {
    // Navigation vers les détails du service
    Get.toNamed(AppRoutes.serviceDetail, arguments: service);
  }
}
