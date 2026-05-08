import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Eager init is required here because SplashView does not read `controller`
    // directly, and we still need onReady() to run immediately for navigation.
    Get.put<SplashController>(SplashController());
  }
}
