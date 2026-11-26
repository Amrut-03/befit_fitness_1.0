import 'package:equatable/equatable.dart';

/// One set in an in-progress session.
class SessionSet extends Equatable {
  const SessionSet({required this.reps, this.weightKg, this.done = false});

  final int reps;

  /// Null for bodyweight exercises.
  final double? weightKg;
  final bool done;

  SessionSet copyWith({int? reps, double? Function()? weightKg, bool? done}) {
    return SessionSet(
      reps: reps ?? this.reps,
      weightKg: weightKg != null ? weightKg() : this.weightKg,
      done: done ?? this.done,
    );
  }

  @override
  List<Object?> get props => [reps, weightKg, done];
}

class SessionExercise extends Equatable {
  const SessionExercise({
    required this.exerciseId,
    required this.name,
    required this.bodyPart,
    this.gifUrl,
    required this.sets,
  });

  final String exerciseId;
  final String name;
  final String bodyPart;
  final String? gifUrl;
  final List<SessionSet> sets;

  int get doneSets => sets.where((s) => s.done).length;

  SessionExercise copyWith({List<SessionSet>? sets}) => SessionExercise(
    exerciseId: exerciseId,
    name: name,
    bodyPart: bodyPart,
    gifUrl: gifUrl,
    sets: sets ?? this.sets,
  );

  @override
  List<Object?> get props => [exerciseId, name, bodyPart, gifUrl, sets];
}

/// A workout being performed: exercises, their sets, and the rest timer.
///
/// Timers are stored as timestamps, not counters, so they stay correct after
/// the app is backgrounded or restored from storage.
class WorkoutSession extends Equatable {
  const WorkoutSession({
    required this.startedAt,
    this.exercises = const [],
    this.restSeconds = defaultRestSeconds,
    this.restEndsAt,
  });

  static const defaultRestSeconds = 90;
  static const minRestSeconds = 15;
  static const maxRestSeconds = 600;

  final DateTime startedAt;
  final List<SessionExercise> exercises;

  /// The rest length started after each completed set.
  final int restSeconds;

  /// When the current rest ends; null when not resting.
  final DateTime? restEndsAt;

  int get completedSets => exercises.fold(0, (n, e) => n + e.doneSets);

  int get totalSets => exercises.fold(0, (n, e) => n + e.sets.length);

  /// Sum of reps × kg over completed, weighted sets.
  double get volumeKg => exercises.fold(
    0,
    (sum, e) => e.sets
        .where((s) => s.done && s.weightKg != null)
        .fold(sum, (v, s) => v + s.reps * s.weightKg!),
  );

  bool isResting(DateTime now) =>
      restEndsAt != null && restEndsAt!.isAfter(now);

  Duration restRemaining(DateTime now) =>
      isResting(now) ? restEndsAt!.difference(now) : Duration.zero;

  /// The body part with the most exercises, for the history entry.
  String get mainBodyPart {
    if (exercises.isEmpty) return '';
    final counts = <String, int>{};
    for (final e in exercises) {
      counts[e.bodyPart] = (counts[e.bodyPart] ?? 0) + 1;
    }
    return (counts.entries.toList()..sort((a, b) => b.value - a.value))
        .first
        .key;
  }

  /// "Chest & Back", or "Full body" for three or more body parts.
  String get title {
    final parts = <String>{for (final e in exercises) e.bodyPart}.toList();
    String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
    return switch (parts.length) {
      0 => 'Workout',
      1 => '${cap(parts[0])} workout',
      2 => '${cap(parts[0])} & ${cap(parts[1])}',
      _ => 'Full body workout',
    };
  }

  WorkoutSession copyWith({
    List<SessionExercise>? exercises,
    int? restSeconds,
    DateTime? Function()? restEndsAt,
  }) {
    return WorkoutSession(
      startedAt: startedAt,
      exercises: exercises ?? this.exercises,
      restSeconds: restSeconds ?? this.restSeconds,
      restEndsAt: restEndsAt != null ? restEndsAt() : this.restEndsAt,
    );
  }

  @override
  List<Object?> get props => [startedAt, exercises, restSeconds, restEndsAt];
}
