import 'package:equatable/equatable.dart';

class WorkoutHistoryEntity extends Equatable {
  final String workoutName;

  final String bodyPart;

  final DateTime completedAt;

  final List<String> exercises;

  const WorkoutHistoryEntity({
    required this.workoutName,

    required this.bodyPart,

    required this.completedAt,

    required this.exercises,
  });

  @override
  List<Object?> get props => [workoutName, bodyPart, completedAt, exercises];
}
