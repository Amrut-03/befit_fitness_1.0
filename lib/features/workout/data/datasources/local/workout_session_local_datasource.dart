import 'package:hive/hive.dart';

import '../../../domain/entities/workout_session.dart';
import '../../../domain/repositories/workout_session_store.dart';

/// [WorkoutSessionStore] in a user-scoped Hive box (cleared on logout).
class WorkoutSessionLocalDatasource implements WorkoutSessionStore {
  WorkoutSessionLocalDatasource(this._box);

  final Box _box;
  static const _key = 'current';

  @override
  WorkoutSession? read() {
    try {
      final raw = _box.get(_key);
      return raw is Map ? fromMap(raw) : null;
    } catch (_) {
      // A corrupt draft shouldn't block starting a new workout.
      return null;
    }
  }

  @override
  Future<void> write(WorkoutSession session) => _box.put(_key, toMap(session));

  @override
  Future<void> clear() => _box.delete(_key);

  static Map<String, dynamic> toMap(WorkoutSession s) => {
    'startedAt': s.startedAt.millisecondsSinceEpoch,
    'restSeconds': s.restSeconds,
    'restEndsAt': s.restEndsAt?.millisecondsSinceEpoch,
    'exercises': [
      for (final e in s.exercises)
        {
          'exerciseId': e.exerciseId,
          'name': e.name,
          'bodyPart': e.bodyPart,
          'gifUrl': e.gifUrl,
          'sets': [
            for (final set in e.sets)
              {'reps': set.reps, 'weightKg': set.weightKg, 'done': set.done},
          ],
        },
    ],
  };

  static WorkoutSession fromMap(Map raw) {
    DateTime? at(Object? ms) =>
        ms is int ? DateTime.fromMillisecondsSinceEpoch(ms) : null;

    return WorkoutSession(
      startedAt: at(raw['startedAt'])!,
      restSeconds:
          (raw['restSeconds'] as int?) ?? WorkoutSession.defaultRestSeconds,
      restEndsAt: at(raw['restEndsAt']),
      exercises: [
        for (final e in (raw['exercises'] as List? ?? const []).cast<Map>())
          SessionExercise(
            exerciseId: e['exerciseId'] as String,
            name: e['name'] as String,
            bodyPart: e['bodyPart'] as String? ?? '',
            gifUrl: e['gifUrl'] as String?,
            sets: [
              for (final s in (e['sets'] as List? ?? const []).cast<Map>())
                SessionSet(
                  reps: s['reps'] as int,
                  weightKg: (s['weightKg'] as num?)?.toDouble(),
                  done: s['done'] as bool? ?? false,
                ),
            ],
          ),
      ],
    );
  }
}
