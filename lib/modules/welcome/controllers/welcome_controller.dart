import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/session_service.dart';

class WelcomeController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _redirectIfAuthenticated();
  }

  void _redirectIfAuthenticated() {
    final sessionService = Get.find<SessionService>();
    if (sessionService.isAuthenticated.value &&
        sessionService.currentUser.value != null) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void navigateToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  void navigateToRegister() {
    Get.toNamed(AppRoutes.register);
  }
}
