import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/services/session_service.dart';
import 'package:mhdcooperation/routes/app_routes.dart';

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  debugPrint('[FCM Background] ${message.notification?.title}');
}

class PushNotificationService extends GetxService {
  static const _channelId = 'mhd_high_importance';
  static const _channelName = 'Notifications MHD Cooperation';

  final _fcm = FirebaseMessaging.instance;
  final _localNotifs = FlutterLocalNotificationsPlugin();
  final _firestore = FirebaseFirestore.instance;

  RemoteMessage? _pendingInitialMessage;

  Future<PushNotificationService> init() async {
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    await _localNotifs
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          importance: Importance.high,
          playSound: true,
        ));

    await _localNotifs.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) _navigateFromPayload(response.payload!);
      },
    );

    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_navigate);
    _fcm.onTokenRefresh.listen(_onTokenRefresh);

    _pendingInitialMessage = await _fcm.getInitialMessage();

    // Si l'utilisateur est déjà connecté, sauvegarder le token FCM
    final session = Get.find<SessionService>();
    if (session.isAuthenticated.value && session.currentUser.value != null) {
      await saveTokenForCurrentUser();
      await subscribeToTopics(session.currentUser.value?.city);
    }

    return this;
  }

  // Appeler depuis SplashController après navigation vers home
  void handlePendingMessage() {
    if (_pendingInitialMessage != null) {
      _navigate(_pendingInitialMessage!);
      _pendingInitialMessage = null;
    }
  }

  Future<void> saveTokenForCurrentUser() async {
    try {
      final userId = Get.find<SessionService>().currentUser.value?.id;
      if (userId == null) return;
      final token = await _fcm.getToken();
      if (token == null) return;
      await _firestore.collection('users').doc(userId).update({
        'fcm_token': token,
        'fcm_token_updated_at': FieldValue.serverTimestamp(),
      });
      debugPrint('[FCM] Token saved for user $userId');
    } catch (e) {
      debugPrint('[FCM] saveTokenForCurrentUser error: $e');
    }
  }

  Future<void> clearToken() async {
    try {
      final userId = Get.find<SessionService>().currentUser.value?.id;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .update({'fcm_token': FieldValue.delete()});
      }
      await _fcm.deleteToken();
    } catch (e) {
      debugPrint('[FCM] clearToken error: $e');
    }
  }

  Future<void> subscribeToTopics(String? userCity) async {
    try {
      await _fcm.subscribeToTopic('all_users');
      await _fcm.subscribeToTopic('concours');
      if (userCity != null && userCity.isNotEmpty) {
        final safeTopic = userCity
            .toLowerCase()
            .replaceAll(' ', '_')
            .replaceAll(RegExp(r'[^a-z0-9_-]'), '');
        if (safeTopic.isNotEmpty) {
          await _fcm.subscribeToTopic('ville_$safeTopic');
        }
      }
      debugPrint('[FCM] Topics subscribed');
    } catch (e) {
      debugPrint('[FCM] subscribeToTopics error: $e');
    }
  }

  Future<void> unsubscribeFromTopics() async {
    try {
      await _fcm.unsubscribeFromTopic('all_users');
      await _fcm.unsubscribeFromTopic('concours');
    } catch (e) {
      debugPrint('[FCM] unsubscribeFromTopics error: $e');
    }
  }

  Future<void> _onTokenRefresh(String token) async {
    try {
      final userId = Get.find<SessionService>().currentUser.value?.id;
      if (userId == null) return;
      await _firestore.collection('users').doc(userId).update({
        'fcm_token': token,
        'fcm_token_updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[FCM] onTokenRefresh error: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _localNotifs.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: _encodePayload(message.data),
    );
  }

  void _navigate(RemoteMessage message) {
    _navigateFromPayload(_encodePayload(message.data));
  }

  String _encodePayload(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;
    if (type == null) return '';
    return id != null && id.isNotEmpty ? '$type|$id' : type;
  }

  void _navigateFromPayload(String payload) {
    if (payload.isEmpty) return;
    final parts = payload.split('|');
    final type = parts[0];
    final id = parts.length > 1 ? parts[1] : '';

    switch (type) {
      case 'concours':
        if (id.isNotEmpty) Get.toNamed(AppRoutes.concoursDetail, arguments: id);
        break;
      case 'dossier':
        Get.toNamed(AppRoutes.userDossiers);
        break;
      case 'notification':
        Get.toNamed(AppRoutes.notifications);
        break;
      default:
        Get.toNamed(AppRoutes.home);
    }
  }
}
