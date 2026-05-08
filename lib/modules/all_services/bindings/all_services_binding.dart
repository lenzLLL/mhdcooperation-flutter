import 'package:get/get.dart';
import 'package:mhdcooperation/modules/all_services/controllers/all_services_controller.dart';

class AllServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllServicesController>(() => AllServicesController());
  }
}
