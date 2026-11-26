import 'package:fitness_app/features/ai_coach/presentation/coach_context_mapper.dart';
import 'package:fitness_app/features/health/domain/entities/health_data_entity.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_state.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/progress_report/domain/entities/weekly_report.dart';
import 'package:fitness_app/features/progress_report/presentation/bloc/weekly_report_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_state.dart';
import 'package:fitness_app/features/water_intake/domain/entities/water_day.dart';
import 'package:fitness_app/features/water_intake/domain/entities/water_entry.dart';
import 'package:fitness_app/features/water_intake/presentation/bloc/water_intake_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const profile = ProfileEntity(
    name: 'Amrut Khochikar',
    email: 'a@b.c',
    goal: 'Build muscle',
    streak: 3,
    weight: 70,
    height: 175,
    age: 26.6,
    gender: 'Male',
    dailyStepGoal: 9000,
    dailyCalorieGoal: 2500,
    proteinGoal: 150,
    carbsGoal: 300,
    fatGoal: 70,
    activityLevel: 'Moderate',
  );

  test('maps loaded states into the coach context', () {
    final day = DateTime(2026, 11, 12);
    final week = WeekRange.of(day);
    final c = coachContextFrom(
      profile: ProfileLoaded(profile),
      health: const HealthLoaded(
        data: HealthDataEntity(steps: 4200, calories: 310.6, moveMinutes: 30),
      ),
      streak: const StreakState(currentStreak: 6),
      water: WaterIntakeState(
        status: WaterStatus.ready,
        goalMl: 2500,
        today: WaterDay(
          day: day,
          goalMl: 2500,
          entries: [WaterEntry(id: '1', ml: 750, at: day)],
        ),
      ),
      report: WeeklyReportState(
        status: ReportStatus.ready,
        report: WeeklyReport(
          week: week,
          daysElapsed: 4,
          macroDays: [
            for (final d in week.days)
              MacroDay(day: d, logged: d.day == 9 || d.day == 10),
          ],
          latestWeightKg: 69.4,
          weightChangeKg: -0.3,
          adherencePct: 78.6,
          workouts: 2,
          workoutMinutes: 80,
          waterDaysMet: 1,
        ),
      ),
    );

    expect(c.name, 'Amrut');
    expect(c.age, 27);
    expect(c.weightKg, 69.4, reason: 'latest logged weight wins');
    expect(c.stepsToday, 4200);
    expect(c.caloriesBurnedToday, 311);
    expect(c.streakDays, 6);
    expect(c.waterTodayMl, 750);
    expect(c.waterGoalMl, 2500);
    expect(c.weekMacroAdherencePct, 79);
    expect(c.weekLoggedDays, 2);
    expect(c.weekWorkouts, 2);
  });

  test('nothing loaded gives an empty context', () {
    final c = coachContextFrom(
      profile: ProfileInitial(),
      health: HealthInitial(),
      streak: const StreakState(isLoading: true),
      water: const WaterIntakeState(),
      report: const WeeklyReportState(),
    );
    expect(c.name, isNull);
    expect(c.streakDays, isNull);
    expect(c.waterTodayMl, isNull);
    expect(c.weekWorkouts, isNull);
  });
}
