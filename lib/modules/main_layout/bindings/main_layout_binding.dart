import 'package:get/get.dart';
import '../../home/bindings/home_binding.dart';
import '../controllers/main_layout_controller.dart';

class MainLayoutBinding extends Bindings {
  @override
  void dependencies() {
    // Main layout controller
    Get.lazyPut<MainLayoutController>(() => MainLayoutController());

    // All tab bindings
    HomeBinding().dependencies();
  }
}
