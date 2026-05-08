import 'package:get/get.dart';
import '../controllers/admin_transactions_controller.dart';

class AdminTransactionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminTransactionsController>(
      () => AdminTransactionsController(),
    );
  }
}
