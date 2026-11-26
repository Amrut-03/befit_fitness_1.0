import 'package:fitness_app/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<void> saveNotification(NotificationEntity notification);

  List<NotificationEntity> getNotifications();

  Future<void> clearNotifications();
}
