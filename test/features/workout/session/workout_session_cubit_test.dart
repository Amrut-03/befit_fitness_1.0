import 'dart:async';

import 'package:fitness_app/core/observability/app_analytics.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_session.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_workout_history.dart';
import 'package:fitness_app/features/workout/domain/usecases/save_workout_history.dart';
import 'package:fitness_app/features/workout/presentation/cubit/workout_session_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'fakes.dart';

class _Analytics extends Mock implements AppAnalytics {}

void main() {
  late MemoryStore store;
  late FakeWorkoutRepository repo;
  late _Analytics analytics;
  late DateTime now;

  setUp(() {
    store = MemoryStore();
    repo = FakeWorkoutRepository();
    analytics = _Analytics();
    now = DateTime(2026, 11, 10, 18);
    when(
      () => analytics.logWorkoutSaved(
        bodyPart: any(named: 'bodyPart'),
        exerciseCount: any(named: 'exerciseCount'),
      ),
    ).thenAnswer((_) async {});
  });

  WorkoutSessionCubit build({Duration timeout = const Duration(seconds: 5)}) =>
      WorkoutSessionCubit(
        store: store,
        saveWorkoutHistory: SaveWorkoutHistory(repo),
        getWorkoutHistory: GetWorkoutHistory(repo),
        analytics: analytics,
        clock: () => now,
        saveTimeout: timeout,
      );

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('adding the first exercise starts a session and persists it', () async {
    final cubit = build();
    await cubit.addExercise(exercise('1'));

    final s = cubit.state.session!;
    expect(s.startedAt, now);
    expect(s.exercises.single.sets, hasLength(3));
    expect(store.saved, s);

    await cubit.addExercise(exercise('1')); // no duplicates
    expect(cubit.state.session!.exercises, hasLength(1));
    await cubit.close();
  });

  test('prefills sets from history', () async {
    repo.history = [
      WorkoutHistoryEntity(
        workoutName: 'w',
        bodyPart: 'chest',
        completedAt: DateTime(2026, 11, 8),
        exercises: const ['Exercise 1'],
        exerciseLogs: const [
          ExerciseLog(
            name: 'Exercise 1',
            bodyPart: 'chest',
            sets: [SetLog(reps: 5, weightKg: 60)],
          ),
        ],
      ),
    ];
    final cubit = build();
    await settle();

    await cubit.addExercise(exercise('1'));

    expect(cubit.state.session!.exercises.single.sets, const [
      SessionSet(reps: 5, weightKg: 60),
    ]);
    await cubit.close();
  });

  test('restores a session left in the store', () async {
    store.saved = WorkoutSession(startedAt: DateTime(2026, 11, 10, 17));
    final cubit = build();
    expect(cubit.state.session, store.saved);
    await cubit.close();
  });

  test('completing a set starts the rest timer; un-ticking keeps it', () async {
    final cubit = build();
    await cubit.addExercise(exercise('1'));

    await cubit.toggleSet(0, 0);
    var s = cubit.state.session!;
    expect(s.exercises[0].sets[0].done, isTrue);
    expect(s.restEndsAt, now.add(const Duration(seconds: 90)));

    await cubit.toggleSet(0, 0);
    s = cubit.state.session!;
    expect(s.exercises[0].sets[0].done, isFalse);
    expect(s.restEndsAt, now.add(const Duration(seconds: 90)));
    await cubit.close();
  });

  test('adjusting rest moves the running timer and the default', () async {
    final cubit = build();
    await cubit.addExercise(exercise('1'));
    await cubit.toggleSet(0, 0);

    await cubit.adjustRest(15);
    expect(cubit.state.session!.restSeconds, 105);
    expect(
      cubit.state.session!.restEndsAt,
      now.add(const Duration(seconds: 105)),
    );

    await cubit.adjustRest(-200);
    expect(cubit.state.session!.restSeconds, WorkoutSession.minRestSeconds);
    expect(cubit.state.session!.restEndsAt, isNull); // shortened past now

    await cubit.toggleSet(0, 1);
    await cubit.skipRest();
    expect(cubit.state.session!.restEndsAt, isNull);
    await cubit.close();
  });

  test('editing sets: reps, weight, add and remove', () async {
    final cubit = build();
    await cubit.addExercise(exercise('1'));

    await cubit.updateSet(0, 0, reps: 12, weightKg: () => 20);
    await cubit.updateSet(0, 0, reps: 5000); // ignored
    await cubit.addSet(0);
    var sets = cubit.state.session!.exercises[0].sets;
    expect(sets.first, const SessionSet(reps: 12, weightKg: 20));
    expect(sets, hasLength(4));
    expect(sets.last, const SessionSet(reps: 10)); // copies the last set

    await cubit.updateSet(0, 0, weightKg: () => null);
    await cubit.removeSet(0, 3);
    sets = cubit.state.session!.exercises[0].sets;
    expect(sets.first.weightKg, isNull);
    expect(sets, hasLength(3));
    await cubit.close();
  });

  test('finish needs at least one completed set', () async {
    final cubit = build();
    await cubit.addExercise(exercise('1'));

    await cubit.finish();

    expect(cubit.state.message, contains('at least one set'));
    expect(repo.saved, isEmpty);
    expect(cubit.state.isActive, isTrue);
    await cubit.close();
  });

  test(
    'finish saves completed sets, clears the draft, logs analytics',
    () async {
      final cubit = build();
      await cubit.addExercise(exercise('1'));
      await cubit.addExercise(exercise('2', bodyPart: 'back'));
      await cubit.updateSet(0, 0, weightKg: () => 40);
      await cubit.toggleSet(0, 0);
      await cubit.toggleSet(0, 1);
      now = now.add(const Duration(minutes: 42));

      await cubit.finish();

      final saved = repo.saved.single;
      expect(saved.workoutName, 'Chest & Back');
      expect(saved.exercises, ['Exercise 1']); // exercise 2 had no done sets
      expect(saved.exerciseLogs.single.sets, const [
        SetLog(reps: 10, weightKg: 40),
        SetLog(reps: 10),
      ]);
      expect(saved.durationSeconds, 42 * 60);
      expect(cubit.state.session, isNull);
      expect(cubit.state.finished, saved);
      expect(store.saved, isNull);
      verify(
        () => analytics.logWorkoutSaved(bodyPart: 'chest', exerciseCount: 1),
      ).called(1);
      await cubit.close();
    },
  );

  test(
    'offline: a save still pending after the timeout counts as saved',
    () async {
      repo.saveBehaviour = () => Completer<void>().future; // never acks
      final cubit = build(timeout: const Duration(milliseconds: 10));
      await cubit.addExercise(exercise('1'));
      await cubit.toggleSet(0, 0);

      await cubit.finish();

      expect(cubit.state.finished, isNotNull);
      expect(cubit.state.session, isNull);
      await cubit.close();
    },
  );

  test('a failed save keeps the session and shows an error', () async {
    repo.saveBehaviour = () async => throw Exception('denied');
    final cubit = build();
    await cubit.addExercise(exercise('1'));
    await cubit.toggleSet(0, 0);

    await cubit.finish();

    expect(cubit.state.session, isNotNull);
    expect(cubit.state.saving, isFalse);
    expect(cubit.state.message, isNotNull);
    expect(store.saved, isNotNull);
    await cubit.close();
  });

  test('discard clears the session and the draft', () async {
    final cubit = build();
    await cubit.addExercise(exercise('1'));

    await cubit.discard();

    expect(cubit.state.session, isNull);
    expect(store.saved, isNull);
    await cubit.close();
  });
}
