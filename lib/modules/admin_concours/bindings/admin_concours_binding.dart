import 'package:get/get.dart';
import '../controllers/admin_concours_controller.dart';

class AdminConcoursBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminConcoursController>(() => AdminConcoursController());
  }
}
