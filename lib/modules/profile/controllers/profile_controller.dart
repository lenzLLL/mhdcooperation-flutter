import 'package:flutter/material.dart';
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

  /// Demande de suppression du compte et des données associées. Le compte n'est
  /// pas effacé sur-le-champ : la demande est enregistrée côté serveur et
  /// traitée par l'équipe sous 30 jours (page web /suppression-compte).
  Future<void> requestAccountDeletion() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer mon compte'),
        content: const Text(
          'Votre compte et vos données (profil, dossiers, pièces déposées) seront '
          'supprimés, sous 30 jours. Seuls les enregistrements de paiement sont '
          'conservés, pour des raisons comptables. Cette action est définitive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('Demander la suppression'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ApiClient().post('/api/suppression-compte', {'source': 'mobile'});
      Get.snackbar(
        'Demande enregistrée',
        'Votre compte sera supprimé sous 30 jours.',
        duration: const Duration(seconds: 4),
      );
    } on ApiException catch (e) {
      Get.snackbar('Erreur', e.message);
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible d\'envoyer la demande. Réessayez.');
    }
  }
}
