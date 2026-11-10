import 'package:fitness_app/core/services/reminder_scheduler.dart';
import 'package:fitness_app/core/session/session_notifier.dart';
import 'package:fitness_app/features/notifications/data/datasources/local/notification_settings_local_datasource.dart';

/// Keeps scheduled reminders in step with the session: they're applied when
/// a user is ready, which is also when permission is first requested, and
/// cancelled on logout.
class ReminderSync {
  ReminderSync({
    required this.session,
    required this.storage,
    required this.scheduler,
    required this.requestPermission,
  });

  final SessionNotifier session;
  final NotificationSettingsLocalDatasource storage;
  final ReminderScheduler scheduler;
  final Future<bool> Function() requestPermission;

  SessionStatus? _last;

  void start() {
    session.addListener(_onSessionChanged);
    _onSessionChanged();
  }

  Future<void> _onSessionChanged() async {
    final status = session.status;
    if (status == _last) return;
    _last = status;

    try {
      if (status == SessionStatus.ready) {
        final settings = storage.read();
        if (settings.anyEnabled && await requestPermission()) {
          await scheduler.apply(settings);
        }
      } else if (status == SessionStatus.signedOut) {
        await scheduler.cancelAll();
      }
    } catch (_) {
      // Reminders are best effort and must never break startup.
    }
  }
}
