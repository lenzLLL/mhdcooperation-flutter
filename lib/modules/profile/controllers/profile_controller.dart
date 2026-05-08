import 'package:get/get.dart';
import 'package:mhdcooperation/data/services/session_service.dart';

class ProfileController extends GetxController {
  final sessionService = Get.find<SessionService>();

  // État de chargement
  final RxBool isLoading = false.obs;

  void logout() {
    // Logique de déconnexion
    sessionService.clearSession();
    Get.offAllNamed('/login');
  }

  void navigateToSettings() {
    // Navigation vers les paramètres
    // Get.toNamed('/settings');
  }

  void navigateToHelp() {
    // Navigation vers l'aide
    // Get.toNamed('/help');
  }

  void navigateToAbout() {
    // Navigation vers à propos
    // Get.toNamed('/about');
  }
}
