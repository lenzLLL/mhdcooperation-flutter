import 'package:get/get.dart';
import '../controllers/admin_schools_controller.dart';

class AdminSchoolsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminSchoolsController>(() => AdminSchoolsController());
  }
}
