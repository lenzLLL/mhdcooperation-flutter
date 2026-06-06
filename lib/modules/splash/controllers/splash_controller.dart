import 'package:get/get.dart';
import '../../../data/services/push_notification_service.dart';
import '../../../data/services/session_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateBasedOnAuth();
  }

  void _navigateBasedOnAuth() {
    Future.delayed(const Duration(seconds: 3), () {
      final sessionService = Get.find<SessionService>();

      // If user is authenticated, go to home, otherwise go to onboarding
      if (sessionService.isAuthenticated.value &&
          sessionService.currentUser.value != null) {
        Get.offNamed(AppRoutes.home);
        Future.delayed(const Duration(milliseconds: 500), () {
          try {
            Get.find<PushNotificationService>().handlePendingMessage();
          } catch (_) {}
        });
      } else {
        Get.offNamed(AppRoutes.onboarding);
      }
    });
  }
}
