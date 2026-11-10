import 'package:fitness_app/features/workout/domain/entities/exercise_page_entity.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';

abstract class WorkoutRepository {
  Future<ExercisePageEntity> getExercises({
    int limit,
    String? cursor,
    String? bodyPart,
  });
  Future<void> saveWorkoutHistory(WorkoutHistoryEntity workout);
  Stream<List<WorkoutHistoryEntity>> getWorkoutHistory();
}
