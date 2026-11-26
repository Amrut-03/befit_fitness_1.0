import 'package:fitness_app/core/error/result.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise_page_entity.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';

class GetExercises {
  final WorkoutRepository repository;

  GetExercises(this.repository);

  Future<Result<ExercisePageEntity>> call({
    int limit = 20,
    String? cursor,
    String? bodyPart,
  }) {
    return repository.getExercises(
      limit: limit,
      cursor: cursor,
      bodyPart: bodyPart,
    );
  }
}
