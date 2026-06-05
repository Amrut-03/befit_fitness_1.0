import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadExercisesEvent extends WorkoutEvent {
  final bool loadMore;

  final String? bodyPart;

  const LoadExercisesEvent({this.loadMore = false, this.bodyPart});

  @override
  List<Object?> get props => [loadMore, bodyPart];
}

class LoadWorkoutHistory extends WorkoutEvent {}

class WorkoutHistoryUpdated extends WorkoutEvent {
  final List<WorkoutHistoryEntity> history;

  const WorkoutHistoryUpdated(this.history);

  @override
  List<Object?> get props => [history];
}

class SaveWorkoutHistoryEvent extends WorkoutEvent {
  final String workoutName;

  final String bodyPart;

  final List<String> exercises;

  const SaveWorkoutHistoryEvent({
    required this.workoutName,

    required this.bodyPart,

    required this.exercises,
  });

  @override
  List<Object?> get props => [workoutName, bodyPart, exercises];
}

class SearchExercisesEvent extends WorkoutEvent {
  final String query;

  const SearchExercisesEvent(this.query);

  @override
  List<Object?> get props => [query];
}
