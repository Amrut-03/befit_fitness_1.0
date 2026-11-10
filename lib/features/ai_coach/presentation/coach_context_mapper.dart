import 'package:fitness_app/features/health/presentation/bloc/health_state.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/progress_report/presentation/bloc/weekly_report_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_state.dart';
import 'package:fitness_app/features/water_intake/presentation/bloc/water_intake_bloc.dart';

import '../domain/entities/coach_context.dart';

/// Builds the coach's grounding data from whatever the app has loaded.
CoachContext coachContextFrom({
  ProfileState? profile,
  HealthState? health,
  StreakState? streak,
  WaterIntakeState? water,
  WeeklyReportState? report,
}) {
  final p = profile is ProfileLoaded ? profile.profile : null;
  final h = health is HealthLoaded ? health.data : null;
  final w = water != null && water.today != null ? water : null;
  final r = report?.report;
  final adherence = r?.adherencePct;

  return CoachContext(
    name: p?.name.split(' ').first,
    goal: p?.goal,
    age: p?.age.round(),
    gender: p?.gender,
    weightKg: r?.latestWeightKg ?? p?.weight,
    heightCm: p?.height,
    activityLevel: p?.activityLevel,
    stepGoal: p?.dailyStepGoal,
    calorieGoal: p?.dailyCalorieGoal,
    proteinGoal: p?.proteinGoal,
    carbsGoal: p?.carbsGoal,
    fatGoal: p?.fatGoal,
    stepsToday: h?.steps,
    caloriesBurnedToday: h?.calories.round(),
    streakDays: streak == null || streak.isLoading
        ? null
        : streak.currentStreak,
    waterTodayMl: w?.totalMl,
    waterGoalMl: w?.goalMl,
    weekWeightChangeKg: r?.weightChangeKg,
    weekMacroAdherencePct: adherence?.round(),
    weekLoggedDays: adherence == null ? null : r?.loggedDays,
    weekDaysElapsed: r?.daysElapsed,
    weekWorkouts: r?.workouts,
    weekWorkoutMinutes: r?.workoutMinutes,
    weekWaterDaysMet: r?.waterDaysMet,
  );
}
