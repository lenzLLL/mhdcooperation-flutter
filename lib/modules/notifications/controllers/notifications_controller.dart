import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/notifications.dart';
import 'package:mhdcooperation/data/services/notification_service.dart';
import 'package:mhdcooperation/data/services/session_service.dart';

class NotificationsController extends GetxController {
  final NotificationService notificationService =
      Get.find<NotificationService>();
  final SessionService sessionService = Get.find<SessionService>();

  @override
  void onInit() {
    super.onInit();
    final userId = sessionService.currentUser.value?.id;
    if (userId != null) {
      notificationService.loadNotificationsForUser(userId);
    }
  }

  void markAsRead(NotificationModel notification) {
    if (!notification.isRead) {
      notificationService.markAsRead(notification.id);
    }
  }

  Future<void> refreshNotifications() async {
    final userId = sessionService.currentUser.value?.id;
    if (userId != null) {
      await notificationService.loadNotificationsForUser(userId);
    }
  }
}
