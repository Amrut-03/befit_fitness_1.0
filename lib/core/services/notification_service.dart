import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitness_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:fitness_app/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Handles FCM messages while the app is in the background or terminated.
///
/// It runs in a separate isolate, so it can't share the main isolate's Hive
/// boxes. It appends to a small "pending" box, which the main isolate drains
/// into the in-app notification list on startup and resume.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  final box = await Hive.openBox(NotificationService.pendingBoxName);
  await box.add(NotificationService.encodeMessage(message));
  await box.close();
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const pendingBoxName = 'notifications_pending';

  static const channel = AndroidNotificationChannel(
    'befit_channel',
    'BeFit Notifications',
    description: 'Reminders and updates from BeFit',
    importance: Importance.high,
  );

  static const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'befit_channel',
      'BeFit Notifications',
      channelDescription: 'Reminders and updates from BeFit',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Fires whenever the in-app notification list changes.
  final StreamController<bool> notificationStreamController =
      StreamController<bool>.broadcast();

  final FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  late Future<void> Function(NotificationEntity) _saveNotification;

  /// Call once from `main()` after Firebase, Hive and DI are ready.
  /// [saveNotification] stores a received message in the in-app list.
  Future<void> initialize({
    required Future<void> Function(NotificationEntity) saveNotification,
  }) async {
    if (_initialized) return;
    _initialized = true;
    _saveNotification = saveNotification;

    await _initTimeZone();

    await localNotificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is requested later, after sign-in, not on first launch.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    await localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((_) => drainPending());

    await drainPending();
  }

  /// `zonedSchedule` needs the device's real time zone.
  Future<void> _initTimeZone() async {
    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }
  }

  /// Requests notification permission: iOS, and Android 13+
  /// (POST_NOTIFICATIONS). Returns whether notifications are allowed.
  Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// A notification id that fits Android's 32-bit int. The raw
  /// `millisecondsSinceEpoch` overflows it and crashes.
  static int nextId([DateTime? now]) =>
      (now ?? DateTime.now()).millisecondsSinceEpoch.remainder(0x7fffffff);

  static Map<String, dynamic> encodeMessage(RemoteMessage m) => {
    'title': m.notification?.title ?? m.data['title'] ?? '',
    'body': m.notification?.body ?? m.data['body'] ?? '',
    'createdAt': (m.sentTime ?? DateTime.now()).millisecondsSinceEpoch,
  };

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final data = encodeMessage(message);
    final title = data['title'] as String;
    final body = data['body'] as String;
    if (title.isEmpty && body.isEmpty) return;

    // FCM doesn't display notifications while the app is in the foreground.
    await localNotificationsPlugin.show(
      id: nextId(),
      title: title,
      body: body,
      notificationDetails: details,
    );
    await _save(title, body, DateTime.now());
    notificationStreamController.add(true);
  }

  /// Moves messages received in the background into the in-app list.
  Future<void> drainPending() async {
    try {
      final box = await Hive.openBox(pendingBoxName);
      final items = box.values.whereType<Map>().toList();
      await box.clear();
      await box.close();

      for (final item in items) {
        await _save(
          item['title']?.toString() ?? '',
          item['body']?.toString() ?? '',
          DateTime.fromMillisecondsSinceEpoch(item['createdAt'] as int),
        );
      }
      if (items.isNotEmpty) notificationStreamController.add(true);
    } catch (e) {
      debugPrint('drainPending failed: $e');
    }
  }

  Future<void> _save(String title, String body, DateTime at) {
    return _saveNotification(
      NotificationEntity(title: title, body: body, createdAt: at),
    );
  }
}
