import 'package:fitness_app/core/error/result.dart';
import 'package:fitness_app/features/workout/data/datasources/remote/workout_remote_datasource.dart';
import 'package:fitness_app/features/workout/data/models/workout_history_model.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise_page_entity.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDatasource remoteDatasource;

  /// Exercise pages are public, non-user data, so a short in-memory cache
  /// avoids refetching when the user goes back and forth between body parts.
  final Duration cacheTtl;
  final DateTime Function() _now;
  final _cache = <String, ({DateTime at, ExercisePageEntity page})>{};

  WorkoutRepositoryImpl(
    this.remoteDatasource, {
    this.cacheTtl = const Duration(hours: 1),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  @override
  Future<Result<ExercisePageEntity>> getExercises({
    int limit = 20,
    String? cursor,
    String? bodyPart,
  }) async {
    final key = '${bodyPart ?? '*'}|${cursor ?? ''}|$limit';
    final hit = _cache[key];
    if (hit != null && _now().difference(hit.at) < cacheTtl) {
      return Ok(hit.page);
    }

    return Result.guard(() async {
      final page = await remoteDatasource.getExercises(
        limit: limit,
        cursor: cursor,
        bodyPart: bodyPart,
      );
      _cache[key] = (at: _now(), page: page);
      return page;
    });
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
