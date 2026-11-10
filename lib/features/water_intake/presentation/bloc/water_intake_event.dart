part of 'water_intake_bloc.dart';

sealed class WaterIntakeEvent extends Equatable {
  const WaterIntakeEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the goal and history and starts listening to today.
class WaterIntakeStarted extends WaterIntakeEvent {
  const WaterIntakeStarted();
}

/// Reloads history, and moves to the new day if midnight has passed.
class WaterIntakeRefreshed extends WaterIntakeEvent {
  const WaterIntakeRefreshed();
}

class WaterAdded extends WaterIntakeEvent {
  const WaterAdded(this.ml);
  final int ml;

  @override
  List<Object?> get props => [ml];
}

class WaterEntryRemoved extends WaterIntakeEvent {
  const WaterEntryRemoved(this.entry);
  final WaterEntry entry;

  @override
  List<Object?> get props => [entry];
}

class WaterGoalUpdated extends WaterIntakeEvent {
  const WaterGoalUpdated(this.ml);
  final int ml;

  @override
  List<Object?> get props => [ml];
}

class _WaterDayChanged extends WaterIntakeEvent {
  const _WaterDayChanged(this.day);
  final WaterDay day;

  @override
  List<Object?> get props => [day];
}

class _WaterStreamFailed extends WaterIntakeEvent {
  const _WaterStreamFailed(this.error);
  final Object error;

  @override
  List<Object?> get props => [error];
}
