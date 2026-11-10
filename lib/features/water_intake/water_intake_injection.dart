import 'package:fitness_app/core/observability/app_analytics.dart';
import 'package:fitness_app/core/services/reminder_scheduler.dart';
import 'package:fitness_app/features/notifications/data/datasources/local/notification_settings_local_datasource.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/get_user_profile.dart';
import 'package:get_it/get_it.dart';

import 'data/datasources/water_intake_remote_datasource.dart';
import 'data/repositories/water_intake_repository_impl.dart';
import 'data/services/scheduled_hydration_reminders.dart';
import 'domain/repositories/hydration_reminders.dart';
import 'domain/repositories/water_intake_repository.dart';
import 'domain/usecases/water_usecases.dart';
import 'presentation/bloc/water_intake_bloc.dart';

/// Dependencies for the water intake feature.
void registerWaterIntakeDependencies(GetIt sl) {
  sl.registerLazySingleton(
    () => WaterIntakeRemoteDatasource(firestore: sl(), auth: sl()),
  );

  sl.registerLazySingleton<WaterIntakeRepository>(
    () => WaterIntakeRepositoryImpl(sl(), sl<GetUserProfile>()),
  );

  sl.registerLazySingleton<HydrationReminders>(
    () => ScheduledHydrationReminders(
      sl<ReminderScheduler>(),
      sl<NotificationSettingsLocalDatasource>(),
    ),
  );

  sl.registerLazySingleton(() => WatchWaterDay(sl()));
  sl.registerLazySingleton(() => GetWaterHistory(sl()));
  sl.registerLazySingleton(() => AddWater(sl()));
  sl.registerLazySingleton(() => RemoveWater(sl()));
  sl.registerLazySingleton(() => GetWaterGoal(sl()));
  sl.registerLazySingleton(() => GetRecommendedWaterGoal(sl()));
  sl.registerLazySingleton(() => SetWaterGoal(sl()));

  sl.registerFactory(
    () => WaterIntakeBloc(
      watchDay: sl(),
      getHistory: sl(),
      addWater: sl(),
      removeWater: sl(),
      getGoal: sl(),
      getRecommendedGoal: sl(),
      setGoal: sl(),
      reminders: sl(),
      analytics: sl<AppAnalytics>(),
    ),
  );
}
