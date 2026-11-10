import 'package:fitness_app/core/error/result.dart';
import 'package:fitness_app/features/workout/data/datasources/remote/workout_remote_datasource.dart';
import 'package:fitness_app/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise_page_entity.dart';
import 'package:flutter_test/flutter_test.dart';

class _Remote extends Fake implements WorkoutRemoteDatasource {
  int calls = 0;

  @override
  Future<ExercisePageEntity> getExercises({
    int limit = 20,
    String? cursor,
    String? bodyPart,
  }) async {
    calls++;
    return ExercisePageEntity(exercises: const [], nextCursor: 'c$calls');
  }
}

void main() {
  test('caches pages per body part/cursor until the TTL expires', () async {
    var now = DateTime(2026, 11, 10, 9);
    final remote = _Remote();
    final repo = WorkoutRepositoryImpl(remote, now: () => now);

    await repo.getExercises(bodyPart: 'chest');
    final cached = await repo.getExercises(bodyPart: 'chest');
    expect(cached, isA<Ok<ExercisePageEntity>>());
    expect(remote.calls, 1);

    await repo.getExercises(bodyPart: 'back');
    await repo.getExercises(bodyPart: 'chest', cursor: 'c1');
    expect(remote.calls, 3);

    now = now.add(const Duration(hours: 2));
    await repo.getExercises(bodyPart: 'chest');
    expect(remote.calls, 4);
  });
}
