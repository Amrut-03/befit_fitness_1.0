import 'package:equatable/equatable.dart';

/// Monday 00:00 to Sunday, local time.
class WeekRange extends Equatable {
  const WeekRange._(this.start);

  /// The week containing [date].
  factory WeekRange.of(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return WeekRange._(DateTime(d.year, d.month, d.day - (d.weekday - 1)));
  }

  final DateTime start;

  /// Sunday (local midnight).
  DateTime get end => DateTime(start.year, start.month, start.day + 6);

  List<DateTime> get days => [
    for (var i = 0; i < 7; i++)
      DateTime(start.year, start.month, start.day + i),
  ];

  WeekRange shift(int weeks) =>
      WeekRange._(DateTime(start.year, start.month, start.day + 7 * weeks));

  bool contains(DateTime t) {
    final d = DateTime(t.year, t.month, t.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  @override
  List<Object?> get props => [start];
}

class WeeklyWeight extends Equatable {
  const WeeklyWeight({required this.weekStart, required this.avgKg});

  final DateTime weekStart;
  final double avgKg;

  @override
  List<Object?> get props => [weekStart, avgKg];
}

class MacroGoals extends Equatable {
  const MacroGoals({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
  });

  final double protein;
  final double carbs;
  final double fat;
  final double calories;

  bool get isSet => protein > 0 && carbs > 0 && fat > 0;

  @override
  List<Object?> get props => [protein, carbs, fat, calories];
}

/// Eaten totals for one day of the week.
class MacroDay extends Equatable {
  const MacroDay({
    required this.day,
    this.logged = false,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.calories = 0,
  });

  final DateTime day;

  /// False when nothing was logged (not the same as eating nothing).
  final bool logged;
  final double protein;
  final double carbs;
  final double fat;
  final double calories;

  @override
  List<Object?> get props => [day, logged, protein, carbs, fat, calories];
}

class WeeklyReport extends Equatable {
  const WeeklyReport({
    required this.week,
    required this.daysElapsed,
    this.weightTrend = const [],
    this.weightChangeKg,
    this.latestWeightKg,
    this.macroDays = const [],
    this.goals,
    this.adherencePct,
    this.workouts = 0,
    this.workoutSets = 0,
    this.workoutMinutes = 0,
    this.waterDaysMet = 0,
  });

  final WeekRange week;

  /// 1–7: days of the week so far (7 for past weeks).
  final int daysElapsed;

  /// Weekly average weight, oldest first, ending at [week]; weeks without a
  /// weigh-in are left out.
  final List<WeeklyWeight> weightTrend;

  /// This week's average minus last week's; null without both.
  final double? weightChangeKg;
  final double? latestWeightKg;

  /// Monday to Sunday.
  final List<MacroDay> macroDays;
  final MacroGoals? goals;

  /// 0–100 over logged days; null when nothing was logged or no goals.
  final double? adherencePct;

  final int workouts;
  final int workoutSets;
  final int workoutMinutes;
  final int waterDaysMet;

  int get loggedDays => macroDays.where((d) => d.logged).length;

  @override
  List<Object?> get props => [
    week,
    daysElapsed,
    weightTrend,
    weightChangeKg,
    latestWeightKg,
    macroDays,
    goals,
    adherencePct,
    workouts,
    workoutSets,
    workoutMinutes,
    waterDaysMet,
  ];
}
