import 'package:fitness_app/core/di/storage_module.dart';
import 'package:fitness_app/features/health_calculator/data/datasources/local/health_calculator_local_datasource.dart';
import 'package:fitness_app/features/health_calculator/data/repositories/health_calculator_repository_impl.dart';
import 'package:fitness_app/features/health_calculator/domain/repositories/health_calculator_repository.dart';
import 'package:fitness_app/features/health_calculator/domain/usecases/calculate_bmi.dart';
import 'package:fitness_app/features/health_calculator/domain/usecases/calculate_calories.dart';
import 'package:fitness_app/features/health_calculator/domain/usecases/calculate_protein.dart';
import 'package:fitness_app/features/health_calculator/domain/usecases/calculate_water_intake.dart';
import 'package:fitness_app/features/health_calculator/presentation/bloc/health_calculator_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

/// Dependencies for the health calculator feature.
void registerHealthCalculatorDependencies(GetIt sl) {
  /// LOCAL DATASOURCE

  sl.registerLazySingleton<HealthCalculatorLocalDatasource>(
    () => HealthCalculatorLocalDatasourceImpl(
      sl<Box>(instanceName: StorageModule.calculator),
    ),
  );

  /// REPOSITORY

  sl.registerLazySingleton<HealthCalculatorRepository>(
    () => HealthCalculatorRepositoryImpl(sl()),
  );

  /// USECASES

  sl.registerLazySingleton(() => CalculateBMI(sl()));

  sl.registerLazySingleton(() => CalculateWaterIntake(sl()));

  sl.registerLazySingleton(() => CalculateProtein(sl()));

  sl.registerLazySingleton(() => CalculateCalories(sl()));

  /// BLOC

  sl.registerFactory(() => HealthCalculatorBloc(sl(), sl(), sl(), sl()));
}
