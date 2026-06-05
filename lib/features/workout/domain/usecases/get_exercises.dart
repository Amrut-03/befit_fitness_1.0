import 'package:fitness_app/features/workout/domain/entities/exercise_entity.dart';

import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';

class GetExercises {
  final WorkoutRepository repository;

  GetExercises(this.repository);

  Future<List<ExerciseEntity>> call({
    int limit = 20,

    int offset = 0,

    String? bodyPart,
  }) async {
    return await repository.getExercises(
      limit: limit,

      offset: offset,

      bodyPart: bodyPart,
    );
  }
}
