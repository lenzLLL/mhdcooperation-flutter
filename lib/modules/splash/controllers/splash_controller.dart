import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToOnboarding();
  }

  void _navigateToOnboarding() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed(AppRoutes.onboarding);
    });
  }

  /// Initialize app and determine navigation
}
