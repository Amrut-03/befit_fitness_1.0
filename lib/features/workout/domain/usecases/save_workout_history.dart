import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';

class SaveWorkoutHistory {
  final WorkoutRepository repository;

  SaveWorkoutHistory(this.repository);

  Future<void> call(WorkoutHistoryEntity workout) {
    return repository.saveWorkoutHistory(workout);
  }
}
