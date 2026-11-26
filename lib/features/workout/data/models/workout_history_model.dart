import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';

class WorkoutHistoryModel extends WorkoutHistoryEntity {
  const WorkoutHistoryModel({
    required super.workoutName,
    required super.bodyPart,
    required super.completedAt,
    required super.exercises,
    super.exerciseLogs,
    super.durationSeconds,
  });

  factory WorkoutHistoryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryModel(
      workoutName: json['workoutName'] ?? '',
      bodyPart: json['bodyPart'] ?? '',
      completedAt: (json['completedAt'] as Timestamp).toDate(),
      exercises: List<String>.from(json['exercises'] ?? []),
      exerciseLogs: [
        for (final raw in (json['exerciseLogs'] as List?) ?? const [])
          if (raw is Map) _logFromJson(raw),
      ],
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
    );
  }

  static ExerciseLog _logFromJson(Map raw) => ExerciseLog(
    name: raw['name']?.toString() ?? '',
    bodyPart: raw['bodyPart']?.toString() ?? '',
    sets: [
      for (final s in (raw['sets'] as List?) ?? const [])
        if (s is Map && s['reps'] is num)
          SetLog(
            reps: (s['reps'] as num).toInt(),
            weightKg: (s['weightKg'] as num?)?.toDouble(),
          ),
    ],
  );

  Map<String, dynamic> toJson() {
    return {
      'workoutName': workoutName,
      'bodyPart': bodyPart,
      'completedAt': Timestamp.fromDate(completedAt),
      'exercises': exercises,
      if (exerciseLogs.isNotEmpty)
        'exerciseLogs': [
          for (final e in exerciseLogs)
            {
              'name': e.name,
              'bodyPart': e.bodyPart,
              'sets': [
                for (final s in e.sets)
                  {'reps': s.reps, 'weightKg': ?s.weightKg},
              ],
            },
        ],
      'durationSeconds': ?durationSeconds,
    };
  }

  factory WorkoutHistoryModel.fromEntity(WorkoutHistoryEntity entity) {
    return WorkoutHistoryModel(
      workoutName: entity.workoutName,
      bodyPart: entity.bodyPart,
      completedAt: entity.completedAt,
      exercises: entity.exercises,
      exerciseLogs: entity.exerciseLogs,
      durationSeconds: entity.durationSeconds,
    );
  }
}
