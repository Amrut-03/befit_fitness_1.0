import 'dart:io';

import 'package:fitness_app/core/services/notification_service.dart';
import 'package:fitness_app/core/services/reminder_scheduler.dart';
import 'package:fitness_app/features/notifications/data/datasources/local/notification_settings_local_datasource.dart';
import 'package:fitness_app/features/notifications/domain/entities/notification_settings.dart';
import 'package:fitness_app/features/notifications/presentation/cubit/notification_settings_cubit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class _Plugin extends Fake implements FlutterLocalNotificationsPlugin {
  final scheduled = <int, tz.TZDateTime>{};
  final cancelled = <int>[];

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
    expect(androidScheduleMode, AndroidScheduleMode.inexactAllowWhileIdle);
    expect(matchDateTimeComponents, DateTimeComponents.time);
    scheduled[id] = scheduledDate;
  }

  @override
  Future<void> cancel({required int id, String? tag}) async {
    cancelled.add(id);
    scheduled.remove(id);
  }
}

void main() {
  // Before the test tree is declared: group bodies call tz.getLocation.
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

  group('ReminderScheduler.nextInstanceOf', () {
    final loc = tz.getLocation('Asia/Kolkata');

    test('later today if the time has not passed', () {
      final now = tz.TZDateTime(loc, 2026, 11, 10, 6, 0);
      expect(
        ReminderScheduler.nextInstanceOf(7, 0, now: now),
        tz.TZDateTime(loc, 2026, 11, 10, 7, 0),
      );
    });

    test('tomorrow if the time has passed (or is now)', () {
      final now = tz.TZDateTime(loc, 2026, 11, 10, 7, 0);
      expect(
        ReminderScheduler.nextInstanceOf(7, 0, now: now),
        tz.TZDateTime(loc, 2026, 11, 11, 7, 0),
      );
    });

    test('skipToday always starts tomorrow, across month end', () {
      final now = tz.TZDateTime(loc, 2026, 11, 30, 9, 0);
      expect(
        ReminderScheduler.nextInstanceOf(20, 0, now: now, skipToday: true),
        tz.TZDateTime(loc, 2026, 12, 1, 20, 0),
      );
    });
  });

  test('NotificationService.nextId fits in a 32-bit int', () {
    final id = NotificationService.nextId(DateTime(2026, 11, 10));
    expect(id, lessThan(0x7fffffff));
    expect(id, greaterThanOrEqualTo(0));
  });

  group('ReminderScheduler.apply', () {
    test('schedules only enabled reminders', () async {
      final plugin = _Plugin();
      await ReminderScheduler(plugin).apply(
        const NotificationSettings(
          workoutReminder: true,
          workoutHour: 6,
          workoutMinute: 30,
          waterReminder: false,
          mealReminder: true,
          streakReminder: false,
        ),
      );
      expect(plugin.scheduled.keys.toSet(), {
        ReminderScheduler.workoutId,
        ...ReminderScheduler.mealIds,
      });
      final w = plugin.scheduled[ReminderScheduler.workoutId]!;
      expect((w.hour, w.minute), (6, 30));
    });

    test(
      'skipStreakReminderToday moves the streak reminder to tomorrow',
      () async {
        final plugin = _Plugin();
        await ReminderScheduler(
          plugin,
        ).skipStreakReminderToday(const NotificationSettings());
        final at = plugin.scheduled[ReminderScheduler.streakId]!;
        final today = tz.TZDateTime.now(tz.local);
        expect(
          at.isAfter(DateTime(today.year, today.month, today.day + 1)),
          isTrue,
        );
      },
    );
  });

  group('NotificationSettingsCubit', () {
    late Directory dir;
    late NotificationSettingsLocalDatasource storage;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('hive_notif');
      Hive.init(dir.path);
      storage = NotificationSettingsLocalDatasource(
        await Hive.openBox('s_${DateTime.now().microsecondsSinceEpoch}'),
      );
    });

    tearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    test('persists changes and reschedules', () async {
      final plugin = _Plugin();
      final cubit = NotificationSettingsCubit(
        storage: storage,
        scheduler: ReminderScheduler(plugin),
        requestPermission: () async => true,
      );
      await cubit.update(
        const NotificationSettings(waterReminder: false, workoutHour: 8),
      );

      expect(storage.read().waterReminder, isFalse);
      expect(storage.read().workoutHour, 8);
      expect(
        plugin.scheduled,
        isNot(contains(ReminderScheduler.waterIds.first)),
      );
      expect(plugin.scheduled, contains(ReminderScheduler.workoutId));
    });

    test('permission denied: saved, but nothing scheduled', () async {
      final plugin = _Plugin();
      final cubit = NotificationSettingsCubit(
        storage: storage,
        scheduler: ReminderScheduler(plugin),
        requestPermission: () async => false,
      );
      await cubit.update(const NotificationSettings(mealReminder: true));

      expect(cubit.state.permissionDenied, isTrue);
      expect(storage.read().mealReminder, isTrue);
      expect(plugin.scheduled, isEmpty);
    });
  });
}
