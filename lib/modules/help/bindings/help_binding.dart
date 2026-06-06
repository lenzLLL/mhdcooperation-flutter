import 'package:get/get.dart';
import 'package:mhdcooperation/modules/help/controllers/help_controller.dart';

class HelpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpController>(() => HelpController());
  }
}
