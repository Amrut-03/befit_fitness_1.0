import 'package:fitness_app/core/di/storage_module.dart';
import 'package:fitness_app/features/health_metrics/data/datasources/local/health_metrics_local_datasource.dart';
import 'package:fitness_app/features/health_metrics/data/datasources/remote/health_metrics_remote_datasource.dart';
import 'package:fitness_app/features/health_metrics/data/repositories/health_metric_repository_impl.dart';
import 'package:fitness_app/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:fitness_app/features/health_metrics/domain/usecases/delete_health_metrics.dart';
import 'package:fitness_app/features/health_metrics/domain/usecases/get_health_metrics.dart';
import 'package:fitness_app/features/health_metrics/domain/usecases/save_health_metrics.dart';
import 'package:fitness_app/features/health_metrics/presentation/bloc/health_metric_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

/// Dependencies for the health metrics feature.
void registerHealthMetricsDependencies(GetIt sl) {
  sl.registerLazySingleton<HealthMetricsLocalDataSource>(
    () => HealthMetricsLocalDataSourceImpl(
      sl<Box>(instanceName: StorageModule.healthMetrics),
    ),
  );

  sl.registerLazySingleton<HealthMetricsRemoteDataSource>(
    () => HealthMetricsRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<HealthMetricsRepository>(
    () => HealthMetricRepositoryImpl(sl(), sl(), sl()),
  );

  sl.registerLazySingleton(() => GetHealthMetrics(sl()));

  sl.registerLazySingleton(() => SaveHealthMetric(sl()));

  sl.registerLazySingleton(() => DeleteHealthMetric(sl()));

  sl.registerFactory(() => HealthMetricsBloc(sl(), sl(), sl()));
}
