import 'package:get/get.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import 'package:mhdcooperation/data/services/auth_service.dart';
import 'package:mhdcooperation/routes/app_routes.dart';

class ProfileController extends GetxController {
  final sessionService = Get.find<SessionService>();

  // État de chargement
  final RxBool isLoading = false.obs;

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

  void navigateToSettings() {
    // Navigation vers les paramètres
    // Get.toNamed('/settings');
  }

  void navigateToHelp() {
    Get.toNamed(AppRoutes.help);
  }

  void navigateToAbout() {
    Get.toNamed(AppRoutes.about);
  }

  void navigateToNotifications() {
    Get.toNamed(AppRoutes.notifications);
  }

  void navigateToUserDossiers() {
    Get.toNamed(AppRoutes.userDossiers);
  }

  void navigateToPrivacy() {
    Get.toNamed(AppRoutes.privacy);
  }

  void navigateToTerms() {
    Get.toNamed(AppRoutes.terms);
  }

  void navigateToEditProfile() {
    Get.toNamed(AppRoutes.editProfile);
  }
}
