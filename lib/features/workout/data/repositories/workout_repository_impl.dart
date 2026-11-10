import 'package:fitness_app/features/workout/data/datasources/remote/workout_remote_datasource.dart';
import 'package:fitness_app/features/workout/data/models/workout_history_model.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise_page_entity.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDatasource remoteDatasource;

  WorkoutRepositoryImpl(this.remoteDatasource);

  @override
  Future<ExercisePageEntity> getExercises({
    int limit = 20,
    String? cursor,
    String? bodyPart,
  }) {
    return remoteDatasource.getExercises(
      limit: limit,
      cursor: cursor,
      bodyPart: bodyPart,
    );
  }

  @override
  Stream<List<WorkoutHistoryEntity>> getWorkoutHistory() {
    return remoteDatasource.getWorkoutHistory();
  }

  @override
  Future<void> saveWorkoutHistory(WorkoutHistoryEntity workout) {
    return remoteDatasource.saveWorkoutHistory(
      WorkoutHistoryModel.fromEntity(workout),
    );
  }
}
