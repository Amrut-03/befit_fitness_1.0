import 'package:hive/hive.dart';

import 'package:fitness_app/features/notifications/data/models/notification_model.dart';

class NotificationLocalDatasource {
  final Box<NotificationModel> notificationBox;

  NotificationLocalDatasource({required this.notificationBox});

  /// SAVE NOTIFICATION
  Future<void> saveNotification(NotificationModel notification) async {
    await notificationBox.add(notification);
  }

  /// GET ALL NOTIFICATIONS
  List<NotificationModel> getNotifications() {
    return notificationBox.values.toList().reversed.toList();
  }

  /// CLEAR NOTIFICATIONS
  Future<void> clearNotifications() async {
    await notificationBox.clear();
  }
}
