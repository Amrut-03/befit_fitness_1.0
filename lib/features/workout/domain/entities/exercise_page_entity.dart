import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise_entity.dart';

/// One page of exercises plus the cursor needed to fetch the next page.
class ExercisePageEntity extends Equatable {
  final List<ExerciseEntity> exercises;

  /// Opaque cursor for the next page, or `null` when there are no more pages.
  final String? nextCursor;

  const ExercisePageEntity({required this.exercises, this.nextCursor});

  bool get hasMore => nextCursor != null;

  @override
  List<Object?> get props => [exercises, nextCursor];
}
