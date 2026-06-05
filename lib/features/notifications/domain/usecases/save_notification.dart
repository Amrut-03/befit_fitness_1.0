import 'package:fitness_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:fitness_app/features/notifications/domain/repositories/notifation_repository.dart';

class SaveNotification {
  final NotificationRepository repository;

  SaveNotification(this.repository);

  Future<void> call(NotificationEntity notification) {
    return repository.saveNotification(notification);
  }
}
