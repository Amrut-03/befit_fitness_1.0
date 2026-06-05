import 'package:equatable/equatable.dart';

import 'package:fitness_app/features/notifications/domain/entities/notification_entity.dart';

class NotificationState extends Equatable {
  final bool isLoading;

  final List<NotificationEntity> notifications;

  final String? error;

  const NotificationState({
    this.isLoading = false,

    this.notifications = const [],

    this.error,
  });

  factory NotificationState.initial() {
    return const NotificationState();
  }

  NotificationState copyWith({
    bool? isLoading,

    List<NotificationEntity>? notifications,

    String? error,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,

      notifications: notifications ?? this.notifications,

      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, notifications, error];
}
