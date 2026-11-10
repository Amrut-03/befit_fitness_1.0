part of 'water_intake_bloc.dart';

enum WaterStatus { initial, loading, ready, failure }

class WaterIntakeState extends Equatable {
  const WaterIntakeState({
    this.status = WaterStatus.initial,
    this.today,
    this.goalMl = WaterGoal.fallbackMl,
    this.recommendedGoalMl = WaterGoal.fallbackMl,
    this.history = const [],
    this.message,
  });

  final WaterStatus status;

  /// Today's log, always measured against the current [goalMl].
  final WaterDay? today;

  final int goalMl;
  final int recommendedGoalMl;

  /// The last 7 days as loaded (today's entry may be stale; use [week]).
  final List<WaterDay> history;

  /// A one-off error to show in a snackbar (e.g. a failed write).
  final String? message;

  int get totalMl => today?.totalMl ?? 0;

  double get progress => today?.progress ?? 0;

  /// The last 7 days with today's live numbers.
  List<WaterDay> get week {
    final t = today;
    if (t == null || history.isEmpty) return history;
    return [
      for (final d in history)
        if (d.day == t.day) t else d,
    ];
  }

  WaterIntakeState copyWith({
    WaterStatus? status,
    WaterDay? today,
    int? goalMl,
    int? recommendedGoalMl,
    List<WaterDay>? history,
    String? message,
  }) {
    return WaterIntakeState(
      status: status ?? this.status,
      today: today ?? this.today,
      goalMl: goalMl ?? this.goalMl,
      recommendedGoalMl: recommendedGoalMl ?? this.recommendedGoalMl,
      history: history ?? this.history,
      // Messages are one-off: cleared unless set again.
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    today,
    goalMl,
    recommendedGoalMl,
    history,
    message,
  ];
}
