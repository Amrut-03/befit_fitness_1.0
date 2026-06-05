import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:fitness_app/core/di/injection_container.dart';

import 'package:fitness_app/features/notifications/domain/entities/notification_entity.dart';

import 'package:fitness_app/features/notifications/domain/usecases/save_notification.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();

  NotificationService._();

  /// LIVE UPDATE STREAM
  final StreamController<bool> notificationStreamController =
      StreamController<bool>.broadcast();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// INITIALIZE
  Future<void> initialize() async {
    /// REQUEST PERMISSION
    await _firebaseMessaging.requestPermission(
      alert: true,

      badge: true,

      sound: true,
    );

    /// LOCAL NOTIFICATION INIT
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await localNotificationsPlugin.initialize(settings: initSettings);

    /// FOREGROUND MESSAGE
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title = message.notification?.title ?? '';

      final body = message.notification?.body ?? '';

      /// SHOW LOCAL NOTIFICATION
      await _showNotification(title: title, body: body);

      /// SAVE TO HIVE
      await _saveNotification(title: title, body: body);

      /// UPDATE UI
      notificationStreamController.add(true);
    });
  }

  /// SHOW LOCAL NOTIFICATION
  Future<void> _showNotification({
    required String title,

    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'befit_channel',

      'BeFit Notifications',

      importance: Importance.max,

      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await localNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch,

      title: title,

      body: body,

      notificationDetails: details,
    );
  }

  /// SAVE NOTIFICATION
  Future<void> _saveNotification({
    required String title,

    required String body,
  }) async {
    final saveNotification = sl<SaveNotification>();

    await saveNotification(
      NotificationEntity(title: title, body: body, createdAt: DateTime.now()),
    );
  }

  /// DISPOSE
  void dispose() {
    notificationStreamController.close();
  }
}
