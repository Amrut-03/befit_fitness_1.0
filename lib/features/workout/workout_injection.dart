import 'package:fitness_app/features/workout/data/datasources/remote/workout_remote_datasource.dart';
import 'package:fitness_app/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_exercises.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_workout_history.dart';
import 'package:fitness_app/features/workout/domain/usecases/save_workout_history.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:get_it/get_it.dart';

/// Dependencies for the workout feature.
void registerWorkoutDependencies(GetIt sl) {
  sl.registerLazySingleton(
    () => WorkoutRemoteDatasource(firestore: sl(), auth: sl(), api: sl()),
  );

  sl.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetExercises(sl()));

  sl.registerLazySingleton(() => GetWorkoutHistory(sl()));

  sl.registerLazySingleton(() => SaveWorkoutHistory(sl()));

  sl.registerFactory(
    () => WorkoutBloc(
      getExercises: sl(),
      saveWorkoutHistory: sl(),
      getWorkoutHistory: sl(),
      analytics: sl(),
    ),
  );
}
