import 'package:get/get.dart';
import 'package:mhdcooperation/modules/all_concours/controllers/all_concours_controller.dart';

class AllConcoursBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllConcoursController>(() => AllConcoursController());
  }
}
