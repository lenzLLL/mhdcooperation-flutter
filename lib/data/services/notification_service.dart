import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/notifications.dart';
import 'package:mhdcooperation/data/services/session_service.dart';

class NotificationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionService _sessionService = Get.find<SessionService>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasLoaded = false.obs;

  Future<NotificationService> init() async {
    final currentUser = _sessionService.currentUser.value;
    if (currentUser != null) {
      await loadNotificationsForUser(currentUser.id);
    }
    return this;
  }

  CollectionReference<Map<String, dynamic>> get _notificationCollection =>
      _firestore.collection('notifications');

  Future<void> loadNotificationsForUser(String userId) async {
    try {
      isLoading.value = true;
      final snapshot = await _notificationCollection
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      final loaded = snapshot.docs
          .map(
            (doc) => NotificationModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
      notifications.assignAll(loaded);
      _updateUnreadCount();
      hasLoaded.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<NotificationModel> createNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'INFO',
    bool sent = true,
    bool isRead = false,
    Map<String, dynamic> meta = const {},
  }) async {
    final now = DateTime.now();
    final docRef = _notificationCollection.doc();

    final data = {
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'sent': sent,
      'meta': meta,
      'created_at': Timestamp.fromDate(now),
    };

    await docRef.set(data);
    final notification = NotificationModel.fromJson({'id': docRef.id, ...data});

    final currentUser = _sessionService.currentUser.value;
    if (currentUser != null && currentUser.id == userId) {
      notifications.insert(0, notification);
      _updateUnreadCount();
    }

    return notification;
  }

  Future<void> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) {
      return;
    }

    await _notificationCollection.doc(notificationId).update({'is_read': true});
    notifications[index] = notifications[index].copyWith(isRead: true);
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications
        .where((notification) => !notification.isRead)
        .length;
  }
}
