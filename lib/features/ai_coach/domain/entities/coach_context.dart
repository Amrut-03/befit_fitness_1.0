import 'package:equatable/equatable.dart';

/// A compact snapshot of the user's data that grounds the coach's answers.
/// Every field is optional: the coach works with whatever has loaded.
class CoachContext extends Equatable {
  const CoachContext({
    this.name,
    this.goal,
    this.age,
    this.gender,
    this.weightKg,
    this.heightCm,
    this.activityLevel,
    this.stepGoal,
    this.calorieGoal,
    this.proteinGoal,
    this.carbsGoal,
    this.fatGoal,
    this.stepsToday,
    this.caloriesBurnedToday,
    this.streakDays,
    this.waterTodayMl,
    this.waterGoalMl,
    this.weekWeightChangeKg,
    this.weekMacroAdherencePct,
    this.weekLoggedDays,
    this.weekDaysElapsed,
    this.weekWorkouts,
    this.weekWorkoutMinutes,
    this.weekWaterDaysMet,
  });

  final String? name;
  final String? goal;
  final int? age;
  final String? gender;
  final double? weightKg;
  final double? heightCm;
  final String? activityLevel;
  final int? stepGoal;
  final int? calorieGoal;
  final int? proteinGoal;
  final int? carbsGoal;
  final int? fatGoal;

  final int? stepsToday;
  final int? caloriesBurnedToday;
  final int? streakDays;
  final int? waterTodayMl;
  final int? waterGoalMl;

  final double? weekWeightChangeKg;
  final int? weekMacroAdherencePct;
  final int? weekLoggedDays;
  final int? weekDaysElapsed;
  final int? weekWorkouts;
  final int? weekWorkoutMinutes;
  final int? weekWaterDaysMet;

  double? get bmi {
    final w = weightKg, h = heightCm;
    if (w == null || h == null || w <= 0 || h <= 0) return null;
    return w / ((h / 100) * (h / 100));
  }

  @override
  List<Object?> get props => [
    name,
    goal,
    age,
    gender,
    weightKg,
    heightCm,
    activityLevel,
    stepGoal,
    calorieGoal,
    proteinGoal,
    carbsGoal,
    fatGoal,
    stepsToday,
    caloriesBurnedToday,
    streakDays,
    waterTodayMl,
    waterGoalMl,
    weekWeightChangeKg,
    weekMacroAdherencePct,
    weekLoggedDays,
    weekDaysElapsed,
    weekWorkouts,
    weekWorkoutMinutes,
    weekWaterDaysMet,
  ];
}
