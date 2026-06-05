import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';

class WorkoutHistoryModel extends WorkoutHistoryEntity {
  const WorkoutHistoryModel({
    required super.workoutName,

    required super.bodyPart,

    required super.completedAt,

    required super.exercises,
  });

  factory WorkoutHistoryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryModel(
      workoutName: json['workoutName'] ?? '',

      bodyPart: json['bodyPart'] ?? '',

      completedAt: (json['completedAt'] as Timestamp).toDate(),

      exercises: List<String>.from(json['exercises'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workoutName': workoutName,

      'bodyPart': bodyPart,

      'completedAt': Timestamp.fromDate(completedAt),

      'exercises': exercises,
    };
  }

  factory WorkoutHistoryModel.fromEntity(WorkoutHistoryEntity entity) {
    return WorkoutHistoryModel(
      workoutName: entity.workoutName,

      bodyPart: entity.bodyPart,

      completedAt: entity.completedAt,

      exercises: entity.exercises,
    );
  }
}
