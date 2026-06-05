import 'package:fitness_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 5)
class NotificationModel extends NotificationEntity {
  @HiveField(0)
  final String notificationTitle;

  @HiveField(1)
  final String notificationBody;

  @HiveField(2)
  final DateTime notificationCreatedAt;

  NotificationModel({
    required this.notificationTitle,

    required this.notificationBody,

    required this.notificationCreatedAt,
  }) : super(
         title: notificationTitle,

         body: notificationBody,

         createdAt: notificationCreatedAt,
       );

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      notificationTitle: entity.title,

      notificationBody: entity.body,

      notificationCreatedAt: entity.createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationTitle: json['title'] ?? '',

      notificationBody: json['body'] ?? '',

      notificationCreatedAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,

      'body': body,

      'createdAt': createdAt.toIso8601String(),
    };
  }
}
