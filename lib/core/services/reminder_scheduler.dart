import 'package:fitness_app/core/services/notification_service.dart';
import 'package:fitness_app/features/notifications/domain/entities/notification_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Schedules the daily local reminders from [NotificationSettings].
///
/// Uses inexact alarms, so no SCHEDULE_EXACT_ALARM permission is needed
/// (Play restricts it). Reminders may fire a few minutes late.
class ReminderScheduler {
  ReminderScheduler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const workoutId = 1001;
  static const streakId = 1002;
  static const mealIds = [1003, 1004];
  static const waterIds = [1010, 1011, 1012, 1013, 1014];

  static const _streakTime = (hour: 20, minute: 0);
  static const _mealTimes = [(hour: 13, minute: 0), (hour: 19, minute: 30)];
  static const _waterTimes = [
    (hour: 10, minute: 0),
    (hour: 12, minute: 0),
    (hour: 14, minute: 0),
    (hour: 16, minute: 0),
    (hour: 18, minute: 0),
  ];

  static const allIds = [workoutId, streakId, ...mealIds, ...waterIds];

  /// The next occurrence of [hour]:[minute] in [location], after [now].
  /// [skipToday] starts tomorrow even if today's time hasn't passed.
  static tz.TZDateTime nextInstanceOf(
    int hour,
    int minute, {
    required tz.TZDateTime now,
    bool skipToday = false,
  }) {
    var at = tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (skipToday || !at.isAfter(now)) {
      at = tz.TZDateTime(
        now.location,
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      );
    }
    return at;
  }

  /// Cancels BeFit's reminders and schedules the enabled ones.
  Future<void> apply(NotificationSettings s) async {
    await cancelAll();
    final now = tz.TZDateTime.now(tz.local);

    if (s.workoutReminder) {
      await _daily(
        workoutId,
        s.workoutHour,
        s.workoutMinute,
        now,
        '💪 Time to move',
        'Your workout is waiting. A short session still counts!',
      );
    }
    if (s.streakReminder) {
      await _scheduleStreak(now);
    }
    if (s.mealReminder) {
      for (var i = 0; i < mealIds.length; i++) {
        await _daily(
          mealIds[i],
          _mealTimes[i].hour,
          _mealTimes[i].minute,
          now,
          '🍽️ Log your meal',
          'Tick off your meal to stay on track with your plan.',
        );
      }
    }
    if (s.waterReminder) {
      for (var i = 0; i < waterIds.length; i++) {
        await _daily(
          waterIds[i],
          _waterTimes[i].hour,
          _waterTimes[i].minute,
          now,
          '💧 Hydration check',
          'Time for a glass of water.',
        );
      }
    }
  }

  /// Called when today's activity is recorded: the "streak at risk" reminder
  /// isn't needed today, so it restarts from tomorrow.
  Future<void> skipStreakReminderToday(NotificationSettings s) async {
    if (!s.streakReminder) return;
    await _plugin.cancel(id: streakId);
    await _scheduleStreak(tz.TZDateTime.now(tz.local), skipToday: true);
  }

  Future<void> cancelAll() async {
    for (final id in allIds) {
      await _plugin.cancel(id: id);
    }
  }

  Future<void> _scheduleStreak(tz.TZDateTime now, {bool skipToday = false}) {
    return _daily(
      streakId,
      _streakTime.hour,
      _streakTime.minute,
      now,
      '🔥 Streak at risk',
      'Log a workout or meal today to keep your streak alive.',
      skipToday: skipToday,
    );
  }

  Future<void> _daily(
    int id,
    int hour,
    int minute,
    tz.TZDateTime now,
    String title,
    String body, {
    bool skipToday = false,
  }) {
    return _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: nextInstanceOf(
        hour,
        minute,
        now: now,
        skipToday: skipToday,
      ),
      notificationDetails: NotificationService.details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Repeat daily at this time.
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
