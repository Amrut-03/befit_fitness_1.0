import 'package:fitness_app/features/diet/domain/entities/daily_nutrition.dart';
import 'package:fitness_app/features/diet/domain/entities/diet_history_entity.dart';
import 'package:fitness_app/features/diet/domain/usecases/get_diet_history.dart';
import 'package:fitness_app/features/diet/domain/usecases/nutrition_log_usecases.dart';
import 'package:fitness_app/features/health_metrics/domain/entities/health_metrics_entity.dart';
import 'package:fitness_app/features/health_metrics/domain/usecases/get_health_metrics.dart';
import 'package:fitness_app/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:fitness_app/features/onboarding/domain/usecases/get_user_profile.dart';
import 'package:fitness_app/features/progress_report/data/repositories/weekly_report_repository_impl.dart';
import 'package:fitness_app/features/progress_report/domain/entities/weekly_report.dart';
import 'package:fitness_app/features/water_intake/domain/entities/water_day.dart';
import 'package:fitness_app/features/water_intake/domain/entities/water_entry.dart';
import 'package:fitness_app/features/water_intake/domain/usecases/water_usecases.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_history_entity.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_workout_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Metrics extends Mock implements GetHealthMetrics {}

class _Log extends Mock implements GetNutritionLog {}

class _Diet extends Mock implements GetDietHistory {}

class _Profile extends Mock implements GetUserProfile {}

class _Workouts extends Mock implements GetWorkoutHistory {}

class _WaterRange extends Mock implements GetWaterRange {}

class _WaterGoal extends Mock implements GetWaterGoal {}

void main() {
  final week = WeekRange.of(DateTime(2026, 11, 12));
  late _Metrics metrics;
  late _Log log;
  late _Diet diet;
  late _Profile profile;
  late _Workouts workouts;
  late _WaterRange water;
  late _WaterGoal waterGoal;

  setUpAll(() => registerFallbackValue(MetricType.weight));

  setUp(() {
    metrics = _Metrics();
    log = _Log();
    diet = _Diet();
    profile = _Profile();
    workouts = _Workouts();
    water = _WaterRange();
    waterGoal = _WaterGoal();

    when(() => metrics(MetricType.weight)).thenAnswer(
      (_) async => [
        HealthMetricEntity(
          type: MetricType.weight,
          date: DateTime(2026, 11, 4),
          value: 72,
          isManual: true,
        ),
        HealthMetricEntity(
          type: MetricType.weight,
          date: DateTime(2026, 11, 11),
          value: 71.5,
          isManual: false,
        ),
      ],
    );
    when(() => log(week.start, week.end)).thenAnswer(
      (_) async => [
        DailyNutrition(
          day: DateTime(2026, 11, 10),
          calories: 2000,
          protein: 150,
          carbs: 200,
          fat: 60,
        ),
      ],
    );
    when(() => diet()).thenAnswer(
      (_) => Stream.value([
        DietHistoryEntity(
          id: 'h',
          planId: 'p',
          planName: 'Cut',
          calories: 1800,
          protein: 75,
          carbs: 200,
          fat: 60,
          completedAt: DateTime(2026, 11, 11, 21),
          meals: const [],
        ),
      ]),
    );
    when(() => profile()).thenAnswer(
      (_) async => const UserProfileEntity(
        email: '',
        goal: 'lose',
        gender: 'Male',
        weight: 72,
        height: 175,
        age: 30,
        activityLevel: 'moderate',
        profileCompleted: true,
        dailyStepGoal: 8000,
        dailyCalorieGoal: 2000,
        proteinGoal: 150,
        carbsGoal: 200,
        fatGoal: 60,
      ),
    );
    when(() => workouts()).thenAnswer(
      (_) => Stream.value([
        WorkoutHistoryEntity(
          workoutName: 'Chest',
          bodyPart: 'chest',
          completedAt: DateTime(2026, 11, 12, 18),
          exercises: const ['Bench'],
          exerciseLogs: const [
            ExerciseLog(
              name: 'Bench',
              bodyPart: 'chest',
              sets: [SetLog(reps: 10), SetLog(reps: 10)],
            ),
          ],
          durationSeconds: 1800,
        ),
        WorkoutHistoryEntity(
          workoutName: 'Old',
          bodyPart: 'back',
          completedAt: DateTime(2026, 11, 2),
          exercises: const ['Row'],
        ),
      ]),
    );
    when(() => waterGoal()).thenAnswer((_) async => 2000);
    when(() => water(week.start, days: 7, goalMl: 2000)).thenAnswer(
      (_) async => [
        for (var i = 0; i < 7; i++)
          WaterDay(
            day: week.days[i],
            goalMl: 2000,
            entries: [
              if (i < 2) WaterEntry(id: '$i', ml: 2000, at: week.days[i]),
            ],
          ),
      ],
    );
  });

  WeeklyReportRepositoryImpl repo() => WeeklyReportRepositoryImpl(
    getHealthMetrics: metrics,
    getNutritionLog: log,
    getDietHistory: diet,
    getUserProfile: profile,
    getWorkoutHistory: workouts,
    getWaterRange: water,
    getWaterGoal: waterGoal,
    clock: () => DateTime(2026, 11, 13, 9),
  );

  test('combines every source into the week', () async {
    final r = await repo().getReport(week);

    expect(r.daysElapsed, 5); // Mon 9 – Fri 13
    expect(r.weightChangeKg, -0.5);
    expect(r.latestWeightKg, 71.5);
    expect(r.loggedDays, 2); // Monday from the log, Tuesday from the plan
    // Tuesday (log) 100 %; Wednesday (plan) protein 50 % → 83.3. Mean 91.7.
    expect(r.adherencePct, 92);
    expect(r.workouts, 1);
    expect(r.workoutSets, 2);
    expect(r.workoutMinutes, 30);
    expect(r.waterDaysMet, 2);
  });

  test('a failing source leaves its section empty', () async {
    when(() => workouts()).thenAnswer((_) => Stream.error(Exception('x')));
    when(() => profile()).thenThrow(Exception('offline'));

    final r = await repo().getReport(week);

    expect(r.workouts, 0);
    expect(r.goals, isNull);
    expect(r.adherencePct, isNull);
    expect(r.weightChangeKg, -0.5); // other sections intact
  });
}
