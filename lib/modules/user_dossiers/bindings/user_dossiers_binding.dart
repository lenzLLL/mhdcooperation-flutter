import 'package:get/get.dart';
import '../controllers/user_dossiers_controller.dart';

class UserDossiersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserDossiersController>(() => UserDossiersController());
  }
}
