import 'package:fitness_app/core/services/reminder_scheduler.dart';
import 'package:fitness_app/features/notifications/data/datasources/local/notification_settings_local_datasource.dart';

import '../../domain/repositories/hydration_reminders.dart';

/// [HydrationReminders] on top of the app's [ReminderScheduler]. Respects
/// the user's "Water Reminder" toggle.
class ScheduledHydrationReminders implements HydrationReminders {
  ScheduledHydrationReminders(this._scheduler, this._settings);

  final ReminderScheduler _scheduler;
  final NotificationSettingsLocalDatasource _settings;

  @override
  Future<void> goalReachedToday() =>
      _scheduler.skipWaterRemindersToday(_settings.read());

  @override
  Future<void> goalNotReachedToday() =>
      _scheduler.restoreWaterReminders(_settings.read());
}
