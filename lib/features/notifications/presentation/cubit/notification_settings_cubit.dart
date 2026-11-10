import 'package:fitness_app/core/services/reminder_scheduler.dart';
import 'package:fitness_app/features/notifications/data/datasources/local/notification_settings_local_datasource.dart';
import 'package:fitness_app/features/notifications/domain/entities/notification_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationSettingsState {
  final NotificationSettings settings;

  /// The user denied notification permission, so reminders can't show.
  final bool permissionDenied;

  const NotificationSettingsState({
    required this.settings,
    this.permissionDenied = false,
  });
}

/// Persists reminder settings and reschedules reminders on every change.
class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  NotificationSettingsCubit({
    required this.storage,
    required this.scheduler,
    required this.requestPermission,
  }) : super(NotificationSettingsState(settings: storage.read()));

  final NotificationSettingsLocalDatasource storage;
  final ReminderScheduler scheduler;
  final Future<bool> Function() requestPermission;

  Future<void> update(NotificationSettings settings) async {
    emit(NotificationSettingsState(settings: settings));
    await storage.write(settings);

    if (settings.anyEnabled && !await requestPermission()) {
      emit(
        NotificationSettingsState(settings: settings, permissionDenied: true),
      );
      return;
    }
    await scheduler.apply(settings);
  }
}
