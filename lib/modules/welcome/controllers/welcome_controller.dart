import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class WelcomeController extends GetxController {
  void navigateToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  void navigateToRegister() {
    Get.toNamed(AppRoutes.register);
  }
}
