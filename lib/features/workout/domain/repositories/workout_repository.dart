import 'package:fitness_app/features/workout/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';

abstract class WorkoutRepository {
  Future<List<ExerciseEntity>> getExercises({
    int limit,
    int offset,
    String? bodyPart,
  });
  Future<void> saveWorkoutHistory(WorkoutHistoryEntity workout);
  Stream<List<WorkoutHistoryEntity>> getWorkoutHistory();
}
