import 'package:get/get.dart';
import 'package:mhdcooperation/modules/school_detail/controllers/school_detail_controller.dart';

class SchoolDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SchoolDetailController>(() => SchoolDetailController());
  }
}
