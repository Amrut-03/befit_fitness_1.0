import 'package:fitness_app/features/workout/data/datasources/remote/workout_remote_datasource.dart';

import 'package:fitness_app/features/workout/data/models/workout_history_model.dart';

import 'package:fitness_app/features/workout/domain/entities/exercise_entity.dart';

import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';

import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDatasource remoteDatasource;

  WorkoutRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<ExerciseEntity>> getExercises({
    int limit = 20,

    int offset = 0,

    String? bodyPart,
  }) async {
    return await remoteDatasource.getExercises(
      limit: limit,

      offset: offset,

      bodyPart: bodyPart,
    );
  }

  @override
  Stream<List<WorkoutHistoryEntity>> getWorkoutHistory() {
    return remoteDatasource.getWorkoutHistory().map(
      (models) => models.map((e) => e).toList(),
    );
  }

  @override
  Future<void> saveWorkoutHistory(WorkoutHistoryEntity workout) {
    return remoteDatasource.saveWorkoutHistory(
      WorkoutHistoryModel.fromEntity(workout),
    );
  }
}
