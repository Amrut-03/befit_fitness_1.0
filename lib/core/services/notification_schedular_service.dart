import 'package:fitness_app/core/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationIds {
  static const int streakReminder = 1001;
  static const int mealReminder = 1002;
  static const int waterReminder = 1003;
  static const int dailySummary = 1004;
}

class NotificationSchedulerService {
  NotificationSchedulerService._();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();

      // flutter_timezone v5 returns TimezoneInfo
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (_) {
      // fallback
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }
  }

  /// TEST NOTIFICATION (1 MINUTE)
  static Future<void> scheduleTestNotification() async {
    print("Entered scheduleTestNotification");

    final now = tz.TZDateTime.now(tz.local);

    print("Current time: $now");

    // final now = tz.TZDateTime.now(
    //   tz.local,
    // );

    final scheduledDate = now.add(const Duration(minutes: 1));

    await NotificationService.instance.localNotificationsPlugin.zonedSchedule(
      id: NotificationIds.streakReminder,
      title: '🔥 Streak at Risk',
      body: 'Test notification. Complete a workout today.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'befit_channel',
          'BeFit Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    print("Scheduling for: $scheduledDate");
  }

  /// REAL 7 PM DAILY STREAK REMINDER
  static Future<void> scheduleStreakReminder() async {
    final now = tz.TZDateTime.now(tz.local);

    // var scheduledDate =
    //     tz.TZDateTime(
    //   tz.local,
    //   now.year,
    //   now.month,
    //   now.day,
    //   19,
    //   0,
    // );
    var scheduledDate = now.add(const Duration(minutes: 1));

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await NotificationService.instance.localNotificationsPlugin.zonedSchedule(
      id: NotificationIds.streakReminder,
      title: '🔥 Streak at Risk',
      body: 'Complete a workout today to maintain your streak.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'befit_channel',
          'BeFit Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("Streak reminder scheduled for: $scheduledDate");
  }

  static Future<void> cancelStreakReminder() async {
    await NotificationService.instance.localNotificationsPlugin.cancel(
      id: NotificationIds.streakReminder,
    );
  }

  static Future<void> resetStreakReminder() async {
    await cancelStreakReminder();
    await scheduleStreakReminder();
  }
}
