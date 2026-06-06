import 'package:get/get.dart';
import 'package:mhdcooperation/modules/terms/controllers/terms_controller.dart';

class TermsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermsController>(() => TermsController());
  }
}
