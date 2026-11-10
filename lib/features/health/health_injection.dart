import 'package:fitness_app/core/health/health_platform_service.dart';
import 'package:fitness_app/features/health/data/repositories/health_repository_impl.dart';
import 'package:fitness_app/features/health/data/services/pedometer_service.dart';
import 'package:fitness_app/features/health/domain/repositories/health_repository.dart';
import 'package:fitness_app/features/health/domain/usecases/connect_health_platform.dart';
import 'package:fitness_app/features/health/domain/usecases/get_health_data.dart';
import 'package:fitness_app/features/health/domain/usecases/get_health_platform_status.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/get_user_profile.dart';
import 'package:get_it/get_it.dart';

/// Dependencies for the health feature.
void registerHealthDependencies(GetIt sl) {
  sl.registerLazySingleton(() => PedometerService());

  sl.registerLazySingleton<HealthRepository>(
    () => HealthRepositoryImpl(
      sl(),
      sl<GetUserProfile>(),
      sl<HealthPlatformService>(),
    ),
  );

  sl.registerFactory(
    () => HealthBloc(
      getHealthData: sl(),
      getPlatformStatus: sl(),
      connectPlatform: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetHealthData(sl()));
  sl.registerLazySingleton(() => GetHealthPlatformStatus(sl()));
  sl.registerLazySingleton(() => ConnectHealthPlatform(sl()));
}
