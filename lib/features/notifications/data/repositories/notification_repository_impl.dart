import 'package:fitness_app/features/notifications/data/datasources/local/notification_local_datasources.dart';
import 'package:fitness_app/features/notifications/data/models/notification_model.dart';

import 'package:fitness_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:fitness_app/features/notifications/domain/repositories/notifation_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDatasource localDatasource;

  NotificationRepositoryImpl({required this.localDatasource});

  @override
  Future<void> saveNotification(NotificationEntity notification) async {
    final model = NotificationModel.fromEntity(notification);

    await localDatasource.saveNotification(model);
  }

  @override
  List<NotificationEntity> getNotifications() {
    return localDatasource.getNotifications();
  }

  @override
  Future<void> clearNotifications() async {
    await localDatasource.clearNotifications();
  }
}
