import 'package:get/get.dart';
import '../controllers/admin_dossiers_controller.dart';

class AdminDossiersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminDossiersController>(() => AdminDossiersController());
  }
}
