import 'package:get/get.dart';
import '../controllers/dossier_detail_controller.dart';

class DossierDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DossierDetailController>(() => DossierDetailController());
  }
}
