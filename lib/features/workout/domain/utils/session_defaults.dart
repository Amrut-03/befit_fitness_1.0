import '../entities/workout_history_entity.dart';
import '../entities/workout_session.dart';

abstract final class SessionDefaults {
  static const sets = 3;
  static const reps = 10;

  /// The sets to start an exercise with: what was done last time (from
  /// [history], newest first), or 3 × 10 without weight.
  static List<SessionSet> setsFor(
    String exerciseName,
    List<WorkoutHistoryEntity> history,
  ) {
    final key = exerciseName.trim().toLowerCase();
    for (final workout in history) {
      for (final log in workout.exerciseLogs) {
        if (log.name.trim().toLowerCase() == key && log.sets.isNotEmpty) {
          return [
            for (final s in log.sets)
              SessionSet(reps: s.reps, weightKg: s.weightKg),
          ];
        }
      }
    }
    return List.filled(sets, const SessionSet(reps: reps));
  }

  /// "Last time: 3 × 10 @ 40 kg", or null if never logged with sets.
  static String? lastTimeSummary(
    String exerciseName,
    List<WorkoutHistoryEntity> history,
  ) {
    final key = exerciseName.trim().toLowerCase();
    for (final workout in history) {
      for (final log in workout.exerciseLogs) {
        if (log.name.trim().toLowerCase() == key && log.sets.isNotEmpty) {
          return 'Last time: ${log.summary}';
        }
      }
    }
    return null;
  }
}
