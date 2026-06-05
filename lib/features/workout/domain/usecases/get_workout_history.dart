import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';

import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';

class GetWorkoutHistory {
  final WorkoutRepository repository;

  GetWorkoutHistory(this.repository);

  Stream<List<WorkoutHistoryEntity>> call() {
    return repository.getWorkoutHistory();
  }
}
