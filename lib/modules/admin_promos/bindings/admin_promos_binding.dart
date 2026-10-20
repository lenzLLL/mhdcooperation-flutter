import 'package:get/get.dart';
import 'package:mhdcooperation/modules/admin_promos/controllers/admin_promos_controller.dart';

class AdminPromosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminPromosController>(() => AdminPromosController());
  }
}
