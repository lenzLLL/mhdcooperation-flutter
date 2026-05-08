import 'package:get/get.dart';
import 'package:mhdcooperation/modules/all_schools/controllers/all_schools_controller.dart';

class AllSchoolsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllSchoolsController>(() => AllSchoolsController());
  }
}
