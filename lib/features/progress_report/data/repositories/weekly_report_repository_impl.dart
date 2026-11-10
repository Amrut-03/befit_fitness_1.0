import 'dart:async';

import 'package:fitness_app/features/diet/domain/entities/diet_history_entity.dart';
import 'package:fitness_app/features/diet/domain/entities/daily_nutrition.dart';
import 'package:fitness_app/features/diet/domain/usecases/get_diet_history.dart';
import 'package:fitness_app/features/diet/domain/usecases/nutrition_log_usecases.dart';
import 'package:fitness_app/features/health_metrics/domain/entities/health_metrics_entity.dart';
import 'package:fitness_app/features/health_metrics/domain/usecases/get_health_metrics.dart';
import 'package:fitness_app/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/get_user_profile.dart';
import 'package:fitness_app/features/water_intake/domain/entities/water_day.dart';
import 'package:fitness_app/features/water_intake/domain/usecases/water_usecases.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_workout_history.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/weekly_report.dart';
import '../../domain/repositories/weekly_report_repository.dart';
import '../../domain/utils/report_calculator.dart';

/// Builds a report from other features' use cases. Every source is best
/// effort: one failing (offline, no permission) leaves its section empty
/// instead of failing the whole report.
class WeeklyReportRepositoryImpl implements WeeklyReportRepository {
  WeeklyReportRepositoryImpl({
    required this.getHealthMetrics,
    required this.getNutritionLog,
    required this.getDietHistory,
    required this.getUserProfile,
    required this.getWorkoutHistory,
    required this.getWaterRange,
    required this.getWaterGoal,
    DateTime Function()? clock,
    this.streamTimeout = const Duration(seconds: 8),
  }) : _now = clock ?? DateTime.now;

  final GetHealthMetrics getHealthMetrics;
  final GetNutritionLog getNutritionLog;
  final GetDietHistory getDietHistory;
  final GetUserProfile getUserProfile;
  final GetWorkoutHistory getWorkoutHistory;
  final GetWaterRange getWaterRange;
  final GetWaterGoal getWaterGoal;
  final Duration streamTimeout;
  final DateTime Function() _now;

  Future<T> _safe<T>(String what, Future<T> Function() load, T fallback) async {
    try {
      return await load();
    } catch (e) {
      debugPrint('WeeklyReport: $what unavailable: $e');
      return fallback;
    }
  }

  @override
  Future<WeeklyReport> getReport(WeekRange week) async {
    final weightsF = _safe(
      'weight',
      () => getHealthMetrics(MetricType.weight),
      <HealthMetricEntity>[],
    );
    final logF = _safe(
      'nutrition log',
      () => getNutritionLog(week.start, week.end),
      <DailyNutrition>[],
    );
    final dietF = _safe(
      'diet history',
      () => getDietHistory().first.timeout(streamTimeout),
      <DietHistoryEntity>[],
    );
    final profileF = _safe<UserProfileEntity?>(
      'profile',
      () => getUserProfile(),
      null,
    );
    final workoutsF = _safe(
      'workouts',
      () => getWorkoutHistory().first.timeout(streamTimeout),
      <WorkoutHistoryEntity>[],
    );
    final waterF = _safe('water', () async {
      final goal = await getWaterGoal();
      return getWaterRange(week.start, days: 7, goalMl: goal);
    }, <WaterDay>[]);

    final weighIns = [
      for (final m in await weightsF) (at: m.date, value: m.value),
    ];
    final trend = ReportCalculator.weightTrend(weighIns, week);

    final profile = await profileF;
    final goals = profile == null
        ? null
        : MacroGoals(
            protein: profile.proteinGoal.toDouble(),
            carbs: profile.carbsGoal.toDouble(),
            fat: profile.fatGoal.toDouble(),
            calories: profile.dailyCalorieGoal.toDouble(),
          );

    final macroDays = ReportCalculator.macroDays(
      week: week,
      logged: [
        for (final n in await logF)
          if (!n.isEmpty)
            MacroDay(
              day: n.day,
              logged: true,
              protein: n.protein,
              carbs: n.carbs,
              fat: n.fat,
              calories: n.calories,
            ),
      ],
      completedPlans: [
        for (final h in await dietF)
          if (week.contains(h.completedAt))
            MacroDay(
              day: DateTime(
                h.completedAt.year,
                h.completedAt.month,
                h.completedAt.day,
              ),
              logged: true,
              protein: h.protein,
              carbs: h.carbs,
              fat: h.fat,
              calories: h.calories,
            ),
      ],
    );

    final weekWorkouts = [
      for (final w in await workoutsF)
        if (week.contains(w.completedAt)) w,
    ];

    return WeeklyReport(
      week: week,
      daysElapsed: ReportCalculator.daysElapsed(week, _now()),
      weightTrend: trend,
      weightChangeKg: ReportCalculator.weightChange(trend, week),
      latestWeightKg: ReportCalculator.latestWeight(weighIns, week),
      macroDays: macroDays,
      goals: goals,
      adherencePct: ReportCalculator.weekAdherence(macroDays, goals),
      workouts: weekWorkouts.length,
      workoutSets: weekWorkouts.fold(0, (n, w) => n + w.totalSets),
      workoutMinutes: weekWorkouts.fold(
        0,
        (n, w) => n + ((w.durationSeconds ?? 0) / 60).round(),
      ),
      waterDaysMet: (await waterF).where((d) => d.goalReached).length,
    );
  }
}
