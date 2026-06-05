import 'package:fitness_app/features/notifications/domain/usecases/clear_notification.dart';
import 'package:fitness_app/features/notifications/domain/usecases/get_notification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotifications getNotifications;

  final ClearNotifications clearNotifications;

  NotificationBloc({
    required this.getNotifications,

    required this.clearNotifications,
  }) : super(NotificationState.initial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);

    on<ClearNotificationsEvent>(_onClearNotifications);
  }

  /// LOAD NOTIFICATIONS
  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,

    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final notifications = getNotifications();

      emit(state.copyWith(isLoading: false, notifications: notifications));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// CLEAR NOTIFICATIONS
  Future<void> _onClearNotifications(
    ClearNotificationsEvent event,

    Emitter<NotificationState> emit,
  ) async {
    try {
      await clearNotifications();

      emit(state.copyWith(notifications: []));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
