import 'package:fitness_app/core/services/reminder_scheduler.dart';
import 'package:fitness_app/features/notifications/data/datasources/local/notification_settings_local_datasource.dart';
import 'package:fitness_app/features/streak/data/datasources/remote/streak_remote_datasources.dart';
import 'package:fitness_app/features/streak/data/repositories/streak_repository_impl.dart';
import 'package:fitness_app/features/streak/domain/repositories/streak_repository.dart';
import 'package:fitness_app/features/streak/domain/usecases/get_streak.dart';
import 'package:fitness_app/features/streak/domain/usecases/update_streak.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:get_it/get_it.dart';

/// Dependencies for the streak feature.
void registerStreakDependencies(GetIt sl) {
  sl.registerLazySingleton(
    () => StreakRemoteDatasource(firestore: sl(), auth: sl()),
  );

  sl.registerLazySingleton<StreakRepository>(
    () => StreakRepositoryImpl(remoteDatasource: sl()),
  );

  sl.registerLazySingleton(() => UpdateStreak(sl()));

  sl.registerLazySingleton(() => GetStreak(sl()));

  sl.registerFactory(
    () => StreakBloc(
      getStreak: sl(),
      updateStreak: sl(),
      onActivityRecorded: () => sl<ReminderScheduler>().skipStreakReminderToday(
        sl<NotificationSettingsLocalDatasource>().read(),
      ),
    ),
  );
}
