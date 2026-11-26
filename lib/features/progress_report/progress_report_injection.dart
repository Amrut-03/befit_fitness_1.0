import 'package:get_it/get_it.dart';

import 'data/repositories/weekly_report_repository_impl.dart';
import 'domain/repositories/weekly_report_repository.dart';
import 'domain/usecases/get_weekly_report.dart';
import 'presentation/bloc/weekly_report_bloc.dart';

/// Dependencies for the weekly progress report. Reads other features
/// through their use cases, so register this after them.
void registerProgressReportDependencies(GetIt sl) {
  sl.registerLazySingleton<WeeklyReportRepository>(
    () => WeeklyReportRepositoryImpl(
      getHealthMetrics: sl(),
      getNutritionLog: sl(),
      getDietHistory: sl(),
      getUserProfile: sl(),
      getWorkoutHistory: sl(),
      getWaterRange: sl(),
      getWaterGoal: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetWeeklyReport(sl()));
  sl.registerFactory(() => WeeklyReportBloc(getWeeklyReport: sl()));
}
