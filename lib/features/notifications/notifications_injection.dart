import 'package:fitness_app/core/di/storage_module.dart';
import 'package:fitness_app/core/services/notification_service.dart';
import 'package:fitness_app/core/services/reminder_scheduler.dart';
import 'package:fitness_app/core/services/reminder_sync.dart';
import 'package:fitness_app/features/notifications/data/datasources/local/notification_local_datasources.dart';
import 'package:fitness_app/features/notifications/data/datasources/local/notification_settings_local_datasource.dart';
import 'package:fitness_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:fitness_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:fitness_app/features/notifications/domain/usecases/clear_notification.dart';
import 'package:fitness_app/features/notifications/domain/usecases/get_notification.dart';
import 'package:fitness_app/features/notifications/domain/usecases/save_notification.dart';
import 'package:fitness_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:fitness_app/features/notifications/presentation/cubit/notification_settings_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

/// Dependencies for the notifications feature.
void registerNotificationsDependencies(GetIt sl) {
  // Notifications & reminders
  sl.registerLazySingleton(
    () => NotificationSettingsLocalDatasource(
      sl<Box>(instanceName: StorageModule.notificationSettings),
    ),
  );
  sl.registerLazySingleton(
    () => ReminderScheduler(
      NotificationService.instance.localNotificationsPlugin,
    ),
  );
  sl.registerFactory(
    () => NotificationSettingsCubit(
      storage: sl(),
      scheduler: sl(),
      requestPermission: NotificationService.instance.requestPermission,
    ),
  );
  sl.registerLazySingleton(
    () => ReminderSync(
      session: sl(),
      storage: sl(),
      scheduler: sl(),
      requestPermission: NotificationService.instance.requestPermission,
    ),
  );

  /// LOCAL DATASOURCE
  sl.registerLazySingleton(
    () => NotificationLocalDatasource(notificationBox: sl()),
  );

  /// REPOSITORY
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(localDatasource: sl()),
  );

  /// USECASES
  sl.registerLazySingleton(() => SaveNotification(sl()));

  sl.registerLazySingleton(() => GetNotifications(sl()));

  sl.registerLazySingleton(() => ClearNotifications(sl()));

  /// BLOC
  sl.registerFactory(
    () => NotificationBloc(getNotifications: sl(), clearNotifications: sl()),
  );
}
