import 'package:fitness_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:fitness_app/features/notifications/domain/repositories/notifation_repository.dart';

class GetNotifications {
  final NotificationRepository repository;

  GetNotifications(this.repository);

  List<NotificationEntity> call() {
    return repository.getNotifications();
  }
}
