import 'dart:async';

import 'package:fitness_app/features/workout/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_session.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_session_store.dart';

class MemoryStore implements WorkoutSessionStore {
  MemoryStore([this.saved]);
  WorkoutSession? saved;

  @override
  WorkoutSession? read() => saved;

  @override
  Future<void> write(WorkoutSession session) async => saved = session;

  @override
  Future<void> clear() async => saved = null;
}

/// Records saves; [saveBehaviour] can hang (offline) or throw.
class FakeWorkoutRepository implements WorkoutRepository {
  FakeWorkoutRepository({this.history = const []});

  List<WorkoutHistoryEntity> history;
  final saved = <WorkoutHistoryEntity>[];
  Future<void> Function()? saveBehaviour;

  @override
  Stream<List<WorkoutHistoryEntity>> getWorkoutHistory() =>
      Stream.value(history);

  @override
  Future<void> saveWorkoutHistory(WorkoutHistoryEntity workout) async {
    saved.add(workout);
    await saveBehaviour?.call();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ExerciseEntity exercise(String id, {String bodyPart = 'chest'}) =>
    ExerciseEntity(
      id: id,
      name: 'Exercise $id',
      bodyPart: bodyPart,
      target: 't',
      equipment: 'e',
      instructions: const [],
    );
