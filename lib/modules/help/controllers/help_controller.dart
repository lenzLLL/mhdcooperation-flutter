import 'package:get/get.dart';

class HelpController extends GetxController {
  // État de chargement pour les futures fonctionnalités
  final RxBool isLoading = false.obs;

  // Méthodes pour gérer les interactions futures
  void sendMessage(String name, String email, String message) {
    // Logique d'envoi du message
    // Pour l'instant, juste un feedback utilisateur
    Get.showSnackbar(
      const GetSnackBar(
        title: 'Message envoyé',
        message: 'Nous vous répondrons dans les plus brefs délais.',
        duration: Duration(seconds: 2),
      ),
    );
  }
}
