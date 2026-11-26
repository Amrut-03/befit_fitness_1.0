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

  /// "3 × 10 @ 40 kg" from the last time [exerciseName] was logged with sets,
  /// or null. The UI adds the localized "Last time:" label.
  static String? lastTimeSummary(
    String exerciseName,
    List<WorkoutHistoryEntity> history,
  ) {
    final key = exerciseName.trim().toLowerCase();
    for (final workout in history) {
      for (final log in workout.exerciseLogs) {
        if (log.name.trim().toLowerCase() == key && log.sets.isNotEmpty) {
          return log.summary;
        }
      }
    }
    return null;
  }
}
