import 'package:get/get.dart';
import '../controllers/admin_metrics_controller.dart';

class AdminMetricsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminMetricsController>(() => AdminMetricsController());
  }
}
