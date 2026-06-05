import 'package:fitness_app/features/notifications/domain/repositories/notifation_repository.dart';

class ClearNotifications {
  final NotificationRepository repository;

  ClearNotifications(this.repository);

  Future<void> call() {
    return repository.clearNotifications();
  }
}
