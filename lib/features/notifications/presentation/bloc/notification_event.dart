import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// LOAD NOTIFICATIONS
class LoadNotificationsEvent extends NotificationEvent {}

/// CLEAR NOTIFICATIONS
class ClearNotificationsEvent extends NotificationEvent {}
