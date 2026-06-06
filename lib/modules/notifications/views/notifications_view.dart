import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/modules/notifications/controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.refreshNotifications,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        final service = controller.notificationService;
        if (service.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (service.notifications.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Aucune notification pour le moment.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshNotifications,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: service.notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = service.notifications[index];
              return Material(
                color: notification.isRead
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.secondary.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead
                        ? Colors.grey[200]
                        : Theme.of(context).primaryColor,
                    child: Icon(
                      notification.isRead
                          ? Icons.notifications_none
                          : Icons.notifications,
                      color: notification.isRead
                          ? Colors.black54
                          : Colors.white,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: notification.isRead
                          ? Colors.grey[800]
                          : Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(notification.message),
                      const SizedBox(height: 6),
                      Text(
                        notification.createdAt.toLocal().toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: notification.isRead
                      ? const Icon(Icons.check_circle, color: Colors.grey)
                      : const Icon(Icons.circle, color: Colors.blue, size: 12),
                  onTap: () => controller.markAsRead(notification),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
