import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/features/workout/data/datasources/local/workout_session_local_datasource.dart';
import 'package:fitness_app/features/workout/data/models/workout_history_model.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_session.dart';
import 'package:fitness_app/features/workout/domain/utils/session_defaults.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

SessionExercise _ex(String name, String part, List<SessionSet> sets) =>
    SessionExercise(exerciseId: name, name: name, bodyPart: part, sets: sets);

void main() {
  final start = DateTime(2026, 11, 10, 18);

  group('WorkoutSession', () {
    final session = WorkoutSession(
      startedAt: start,
      exercises: [
        _ex('Bench', 'chest', const [
          SessionSet(reps: 10, weightKg: 40, done: true),
          SessionSet(reps: 8, weightKg: 45, done: true),
          SessionSet(reps: 8, weightKg: 45), // not done
        ]),
        _ex('Push-up', 'chest', const [SessionSet(reps: 20, done: true)]),
        _ex('Row', 'back', const [SessionSet(reps: 10, weightKg: 30)]),
      ],
    );

    test('counts sets and volume of completed weighted sets only', () {
      expect(session.completedSets, 3);
      expect(session.totalSets, 5);
      expect(session.volumeKg, 10 * 40 + 8 * 45);
    });

    test('title and main body part', () {
      expect(session.title, 'Chest & Back');
      expect(session.mainBodyPart, 'chest');
      expect(WorkoutSession(startedAt: start).title, 'Workout');
      expect(
        WorkoutSession(
          startedAt: start,
          exercises: [
            _ex('a', 'chest', const []),
            _ex('b', 'back', const []),
            _ex('c', 'upper legs', const []),
          ],
        ).title,
        'Full body workout',
      );
    });

    test('rest timer from a timestamp', () {
      final resting = session.copyWith(
        restEndsAt: () => start.add(const Duration(seconds: 90)),
      );
      final at = start.add(const Duration(seconds: 30));
      expect(resting.isResting(at), isTrue);
      expect(resting.restRemaining(at), const Duration(seconds: 60));
      expect(
        resting.isResting(start.add(const Duration(seconds: 90))),
        isFalse,
      );
    });
  });

  group('ExerciseLog.summary', () {
    test('uniform sets', () {
      expect(
        const ExerciseLog(
          name: 'Bench',
          bodyPart: 'chest',
          sets: [
            SetLog(reps: 10, weightKg: 40),
            SetLog(reps: 10, weightKg: 40),
          ],
        ).summary,
        '2 × 10 @ 40 kg',
      );
      expect(
        const ExerciseLog(
          name: 'Push-up',
          bodyPart: 'chest',
          sets: [SetLog(reps: 15), SetLog(reps: 15), SetLog(reps: 15)],
        ).summary,
        '3 × 15',
      );
    });

    test('mixed sets', () {
      expect(
        const ExerciseLog(
          name: 'Bench',
          bodyPart: 'chest',
          sets: [
            SetLog(reps: 10, weightKg: 40),
            SetLog(reps: 8, weightKg: 42.5),
          ],
        ).summary,
        '10×40 kg, 8×42.5 kg',
      );
    });
  });

  group('SessionDefaults', () {
    final history = [
      WorkoutHistoryEntity(
        workoutName: 'new',
        bodyPart: 'chest',
        completedAt: DateTime(2026, 11, 9),
        exercises: const ['Bench'],
        exerciseLogs: const [
          ExerciseLog(
            name: 'Bench',
            bodyPart: 'chest',
            sets: [
              SetLog(reps: 8, weightKg: 50),
              SetLog(reps: 6, weightKg: 55),
            ],
          ),
        ],
      ),
      WorkoutHistoryEntity(
        workoutName: 'old',
        bodyPart: 'chest',
        completedAt: DateTime(2026, 11, 1),
        exercises: const ['Bench'],
        exerciseLogs: const [
          ExerciseLog(
            name: 'Bench',
            bodyPart: 'chest',
            sets: [SetLog(reps: 12, weightKg: 30)],
          ),
        ],
      ),
    ];

    test('prefills from the most recent time, case-insensitively', () {
      expect(SessionDefaults.setsFor('bench', history), const [
        SessionSet(reps: 8, weightKg: 50),
        SessionSet(reps: 6, weightKg: 55),
      ]);
      expect(
        SessionDefaults.lastTimeSummary('Bench', history),
        'Last time: 8×50 kg, 6×55 kg',
      );
    });

    test('3 × 10 without weight for a new exercise', () {
      expect(SessionDefaults.setsFor('Squat', history), const [
        SessionSet(reps: 10),
        SessionSet(reps: 10),
        SessionSet(reps: 10),
      ]);
      expect(SessionDefaults.lastTimeSummary('Squat', history), isNull);
    });
  });

  group('WorkoutHistoryModel JSON', () {
    test('round-trips sets and duration', () {
      final model = WorkoutHistoryModel(
        workoutName: 'Chest workout',
        bodyPart: 'chest',
        completedAt: DateTime(2026, 11, 10, 19),
        exercises: const ['Bench', 'Push-up'],
        exerciseLogs: const [
          ExerciseLog(
            name: 'Bench',
            bodyPart: 'chest',
            sets: [SetLog(reps: 10, weightKg: 40)],
          ),
          ExerciseLog(
            name: 'Push-up',
            bodyPart: 'chest',
            sets: [SetLog(reps: 20)],
          ),
        ],
        durationSeconds: 2700,
      );

      final json = model.toJson();
      expect((json['exerciseLogs'] as List)[1], {
        'name': 'Push-up',
        'bodyPart': 'chest',
        'sets': [
          {'reps': 20},
        ],
      });
      expect(WorkoutHistoryModel.fromJson(json), model);
    });

    test('reads older entries without sets', () {
      final model = WorkoutHistoryModel.fromJson({
        'workoutName': 'Bench',
        'bodyPart': 'chest',
        'completedAt': Timestamp.fromDate(DateTime(2026, 10, 1)),
        'exercises': ['Bench'],
      });
      expect(model.exerciseLogs, isEmpty);
      expect(model.durationSeconds, isNull);
      expect(model.toJson().containsKey('exerciseLogs'), isFalse);
    });
  });

  group('WorkoutSessionLocalDatasource', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('hive_session');
      Hive.init(dir.path);
    });

    tearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    test('round-trips a session and clears it', () async {
      final ds = WorkoutSessionLocalDatasource(await Hive.openBox('s'));
      final session = WorkoutSession(
        startedAt: start,
        restSeconds: 120,
        restEndsAt: start.add(const Duration(minutes: 2)),
        exercises: [
          _ex('Bench', 'chest', const [
            SessionSet(reps: 10, weightKg: 42.5, done: true),
            SessionSet(reps: 8),
          ]),
        ],
      );

      expect(ds.read(), isNull);
      await ds.write(session);
      expect(ds.read(), session);
      await ds.clear();
      expect(ds.read(), isNull);
    });

    test('a corrupt draft reads as no session', () async {
      final box = await Hive.openBox('s');
      await box.put('current', {'startedAt': 'nope'});
      expect(WorkoutSessionLocalDatasource(box).read(), isNull);
    });
  });
}
