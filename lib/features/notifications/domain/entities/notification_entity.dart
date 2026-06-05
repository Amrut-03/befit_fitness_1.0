import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String title;

  final String body;

  final DateTime createdAt;

  const NotificationEntity({
    required this.title,

    required this.body,

    required this.createdAt,
  });

  @override
  List<Object?> get props => [title, body, createdAt];
}
