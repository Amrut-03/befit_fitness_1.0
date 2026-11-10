import 'package:fitness_app/core/services/reminder_scheduler.dart';
import 'package:fitness_app/features/notifications/domain/entities/notification_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class _Plugin extends Fake implements FlutterLocalNotificationsPlugin {
  final scheduled = <int, tz.TZDateTime>{};

  @override
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? title,
    String? body,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    scheduled[id] = scheduledDate;
  }

  @override
  Future<void> cancel({required int id, String? tag}) async =>
      scheduled.remove(id);
}

void main() {
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

  late _Plugin plugin;
  late ReminderScheduler scheduler;

  setUp(() {
    plugin = _Plugin();
    scheduler = ReminderScheduler(plugin);
  });

  bool isTomorrowOrLater(tz.TZDateTime t) {
    final now = tz.TZDateTime.now(tz.local);
    final tomorrow = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1);
    return !t.isBefore(tomorrow);
  }

  test(
    'skipWaterRemindersToday moves every water reminder to tomorrow',
    () async {
      await scheduler.skipWaterRemindersToday(const NotificationSettings());

      expect(
        plugin.scheduled.keys,
        unorderedEquals(ReminderScheduler.waterIds),
      );
      expect(plugin.scheduled.values.every(isTomorrowOrLater), isTrue);
    },
  );

  test('restoreWaterReminders reschedules from now', () async {
    await scheduler.skipWaterRemindersToday(const NotificationSettings());
    await scheduler.restoreWaterReminders(const NotificationSettings());

    final now = tz.TZDateTime.now(tz.local);
    expect(plugin.scheduled.keys, unorderedEquals(ReminderScheduler.waterIds));
    // Any slot still ahead today is back on today.
    for (final t in plugin.scheduled.values) {
      final todayAt = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        t.hour,
        t.minute,
      );
      expect(t, todayAt.isAfter(now) ? todayAt : isNot(todayAt));
    }
  });

  test('does nothing when water reminders are off', () async {
    const off = NotificationSettings(waterReminder: false);
    await scheduler.skipWaterRemindersToday(off);
    await scheduler.restoreWaterReminders(off);

    expect(plugin.scheduled, isEmpty);
  });
}
