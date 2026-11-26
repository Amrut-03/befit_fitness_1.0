import 'package:fitness_app/features/notifications/domain/entities/notification_settings.dart';
import 'package:hive/hive.dart';

/// Reminder preferences are per device, so they aren't cleared on logout.
/// Reminders are cancelled on logout and re-applied on sign-in instead.
class NotificationSettingsLocalDatasource {
  NotificationSettingsLocalDatasource(this.box);

  final Box<dynamic> box;
  static const _key = 'settings';

  NotificationSettings read() {
    final raw = box.get(_key);
    return raw is Map
        ? NotificationSettings.fromMap(raw)
        : const NotificationSettings();
  }

  Future<void> write(NotificationSettings settings) =>
      box.put(_key, settings.toMap());
}
