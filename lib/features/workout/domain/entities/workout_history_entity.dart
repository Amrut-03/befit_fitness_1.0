import 'package:equatable/equatable.dart';

/// A completed set as saved in history.
class SetLog extends Equatable {
  const SetLog({required this.reps, this.weightKg});

  final int reps;
  final double? weightKg;

  @override
  List<Object?> get props => [reps, weightKg];
}

/// What was done for one exercise in a saved session.
class ExerciseLog extends Equatable {
  const ExerciseLog({
    required this.name,
    required this.bodyPart,
    required this.sets,
  });

  final String name;
  final String bodyPart;
  final List<SetLog> sets;

  /// "3 × 10 @ 40 kg", or "10, 8, 6 reps" when sets differ.
  String get summary {
    if (sets.isEmpty) return '';
    final reps = sets.map((s) => s.reps).toSet();
    final weights = sets.map((s) => s.weightKg).toSet();
    String kg(double w) =>
        '${w == w.roundToDouble() ? w.toInt() : w.toStringAsFixed(1)} kg';
    if (reps.length == 1 && weights.length == 1) {
      final w = weights.first;
      return '${sets.length} × ${reps.first}${w == null ? '' : ' @ ${kg(w)}'}';
    }
    return sets
        .map(
          (s) =>
              s.weightKg == null ? '${s.reps}' : '${s.reps}×${kg(s.weightKg!)}',
        )
        .join(', ');
  }

  @override
  List<Object?> get props => [name, bodyPart, sets];
}

class WorkoutHistoryEntity extends Equatable {
  final String workoutName;

  final String bodyPart;

  final DateTime completedAt;

  /// Exercise names. Kept for older entries and simple lists.
  final List<String> exercises;

  /// Sets per exercise; empty for quick-logged workouts and older entries.
  final List<ExerciseLog> exerciseLogs;

  /// Session length; null for quick-logged workouts and older entries.
  final int? durationSeconds;

  const WorkoutHistoryEntity({
    required this.workoutName,
    required this.bodyPart,
    required this.completedAt,
    required this.exercises,
    this.exerciseLogs = const [],
    this.durationSeconds,
  });

  int get totalSets => exerciseLogs.fold(0, (n, e) => n + e.sets.length);

  double get volumeKg => exerciseLogs.fold(
    0,
    (sum, e) => e.sets
        .where((s) => s.weightKg != null)
        .fold(sum, (v, s) => v + s.reps * s.weightKg!),
  );

  @override
  List<Object?> get props => [
    workoutName,
    bodyPart,
    completedAt,
    exercises,
    exerciseLogs,
    durationSeconds,
  ];
}
