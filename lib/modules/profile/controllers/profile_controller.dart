import 'package:get/get.dart';
import 'package:mhdcooperation/data/services/api_client.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import 'package:mhdcooperation/data/services/auth_service.dart';
import 'package:mhdcooperation/routes/app_routes.dart';

class ProfileController extends GetxController {
  final sessionService = Get.find<SessionService>();

  // État de chargement
  final RxBool isLoading = false.obs;

  // Code promo personnel : {code, percent, used}. Null tant qu'il n'est pas
  // chargé ou si le code de bienvenue est désactivé.
  final Rxn<Map<String, dynamic>> personalPromo = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    loadPersonalPromo();
    // Le contrôleur survit à une déconnexion : on suit le compte connecté.
    ever(sessionService.currentUser, (_) => loadPersonalPromo());
  }

  Future<void> loadPersonalPromo() async {
    if (sessionService.currentUser.value == null) {
      personalPromo.value = null;
      return;
    }
    try {
      final res = await ApiClient().get('/api/users/me/promo');
      personalPromo.value = res['promo'] as Map<String, dynamic>?;
    } catch (_) {
      // Sans réseau, la carte reste simplement masquée : le profil reste utilisable.
    }
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
