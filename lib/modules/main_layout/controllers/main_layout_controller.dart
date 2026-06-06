import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/modules/all_concours/controllers/all_concours_controller.dart';
import 'package:mhdcooperation/modules/all_services/controllers/all_services_controller.dart';
import 'package:mhdcooperation/modules/all_schools/controllers/all_schools_controller.dart';
import 'package:mhdcooperation/modules/profile/controllers/profile_controller.dart';
import 'package:mhdcooperation/routes/app_routes.dart';
import 'package:mhdcooperation/data/services/auth_service.dart';

class MainLayoutController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Contrôleurs pour les autres pages
  late final AllServicesController allServicesController;
  late final AllSchoolsController allSchoolsController;
  late final AllConcoursController allConcoursController;
  late final ProfileController profileController;

  @override
  void onInit() {
    super.onInit();
    // Initialiser les contrôleurs
    allServicesController = Get.put(AllServicesController());
    allSchoolsController = Get.put(AllSchoolsController());
    allConcoursController = Get.put(AllConcoursController());
    profileController = Get.put(ProfileController());
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  Future<void> logout() async {
    try {
      final authService = Get.find<AuthService>();
      await authService.signOut();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          title: 'Erreur',
          message: 'Erreur lors de la déconnexion',
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
