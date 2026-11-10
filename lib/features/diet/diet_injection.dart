import 'package:fitness_app/features/diet/data/datasources/remote/diet_remote_datasource.dart';
import 'package:fitness_app/features/diet/data/repositories/diet_repository_impl.dart';
import 'package:fitness_app/features/diet/domain/repositories/diet_repository.dart';
import 'package:fitness_app/features/diet/domain/usecases/delete_diet_plan.dart';
import 'package:fitness_app/features/diet/domain/usecases/get_diet_history.dart';
import 'package:fitness_app/features/diet/domain/usecases/get_diet_plans.dart';
import 'package:fitness_app/features/diet/domain/usecases/save_diet_history.dart';
import 'package:fitness_app/features/diet/domain/usecases/save_diet_plan.dart';
import 'package:fitness_app/features/diet/domain/usecases/set_active_diet_plan.dart';
import 'package:fitness_app/features/diet/domain/usecases/update_meal_status.dart';
import 'package:fitness_app/features/diet/presentation/bloc/diet_bloc.dart';
import 'package:get_it/get_it.dart';

/// Dependencies for the diet feature.
void registerDietDependencies(GetIt sl) {
  sl.registerFactory(
    () => DietBloc(
      getDietPlans: sl(),
      saveDietPlan: sl(),
      deleteDietPlan: sl(),
      updateMealStatus: sl(),
      setActiveDietPlan: sl(),
      getDietHistory: sl(),
      saveDietHistory: sl(),
      analytics: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetDietPlans(sl()));
  sl.registerLazySingleton(() => SaveDietPlan(sl()));
  sl.registerLazySingleton(() => DeleteDietPlan(sl()));
  sl.registerLazySingleton(() => UpdateMealStatus(sl()));
  sl.registerLazySingleton(() => SetActiveDietPlan(sl()));
  sl.registerLazySingleton(() => GetDietHistory(sl()));
  sl.registerLazySingleton(() => SaveDietHistory(sl()));

  sl.registerLazySingleton<DietRepository>(() => DietRepositoryImpl(sl()));

  sl.registerLazySingleton(
    () => DietRemoteDataSource(firestore: sl(), auth: sl()),
  );
}
