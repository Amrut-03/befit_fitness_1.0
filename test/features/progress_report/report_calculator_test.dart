import 'package:fitness_app/features/diet/domain/entities/daily_nutrition.dart';
import 'package:fitness_app/features/diet/domain/entities/meal_entity.dart';
import 'package:fitness_app/features/progress_report/domain/entities/weekly_report.dart';
import 'package:fitness_app/features/progress_report/domain/utils/report_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Monday 9 Nov 2026 – Sunday 15 Nov 2026.
  final week = WeekRange.of(DateTime(2026, 11, 12, 15));

  group('WeekRange', () {
    test('runs Monday to Sunday', () {
      expect(week.start, DateTime(2026, 11, 9));
      expect(week.end, DateTime(2026, 11, 15));
      expect(WeekRange.of(DateTime(2026, 11, 15, 23, 59)), week);
      expect(WeekRange.of(DateTime(2026, 11, 16)), week.shift(1));
    });

    test('shifts across month and year ends', () {
      expect(week.shift(-2).start, DateTime(2026, 10, 26));
      expect(WeekRange.of(DateTime(2027, 1, 1)).start, DateTime(2026, 12, 28));
    });

    test('contains ignores the time of day', () {
      expect(week.contains(DateTime(2026, 11, 15, 23, 59)), isTrue);
      expect(week.contains(DateTime(2026, 11, 8, 23, 59)), isFalse);
    });
  });

  group('weight', () {
    final weighIns = [
      (at: DateTime(2026, 10, 27), value: 72.0), // week of 26 Oct
      (at: DateTime(2026, 11, 3), value: 71.6), // week of 2 Nov
      (at: DateTime(2026, 11, 5), value: 71.2),
      (at: DateTime(2026, 11, 10), value: 71.0), // this week
      (at: DateTime(2026, 11, 13), value: 70.6),
      (at: DateTime(2026, 11, 19), value: 69.0), // next week: ignored
    ];

    test('weekly averages over 8 weeks, skipping empty weeks', () {
      final trend = ReportCalculator.weightTrend(weighIns, week);
      expect(trend, [
        WeeklyWeight(weekStart: DateTime(2026, 10, 26), avgKg: 72.0),
        WeeklyWeight(weekStart: DateTime(2026, 11, 2), avgKg: 71.4),
        WeeklyWeight(weekStart: DateTime(2026, 11, 9), avgKg: 70.8),
      ]);
      expect(ReportCalculator.weightChange(trend, week), -0.6);
    });

    test('no change without a weigh-in last week', () {
      final trend = ReportCalculator.weightTrend(weighIns, week.shift(-1));
      expect(ReportCalculator.weightChange(trend, week.shift(-1)), -0.6);
      final gap = ReportCalculator.weightTrend([
        weighIns[0],
        weighIns[3],
      ], week);
      expect(ReportCalculator.weightChange(gap, week), isNull);
    });

    test('latest weigh-in up to the end of the week', () {
      expect(ReportCalculator.latestWeight(weighIns, week), 70.6);
      expect(ReportCalculator.latestWeight(weighIns, week.shift(-1)), 71.2);
      expect(ReportCalculator.latestWeight(const [], week), isNull);
    });
  });

  group('macros', () {
    const goals = MacroGoals(protein: 150, carbs: 200, fat: 60, calories: 2000);

    test('a day exactly on goal scores 100; nothing or double scores 0', () {
      final d = DateTime(2026, 11, 10);
      expect(
        ReportCalculator.dayAdherence(
          MacroDay(day: d, logged: true, protein: 150, carbs: 200, fat: 60),
          goals,
        ),
        100,
      );
      expect(
        ReportCalculator.dayAdherence(
          MacroDay(day: d, logged: true, protein: 300, carbs: 0, fat: 120),
          goals,
        ),
        0,
      );
      // Protein 90%, carbs 110%, fat 50% → (90 + 90 + 50) / 3.
      expect(
        ReportCalculator.dayAdherence(
          MacroDay(day: d, logged: true, protein: 135, carbs: 220, fat: 30),
          goals,
        ),
        closeTo(76.67, 0.01),
      );
    });

    test('the nutrition log wins over a completed plan on the same day', () {
      final days = ReportCalculator.macroDays(
        week: week,
        logged: [
          MacroDay(day: DateTime(2026, 11, 10), logged: true, protein: 100),
        ],
        completedPlans: [
          MacroDay(day: DateTime(2026, 11, 10), logged: true, protein: 999),
          MacroDay(day: DateTime(2026, 11, 11), logged: true, protein: 120),
        ],
      );
      expect(days, hasLength(7));
      expect(days.map((d) => d.logged), [
        false,
        true,
        true,
        false,
        false,
        false,
        false,
      ]);
      expect(days[1].protein, 100);
      expect(days[2].protein, 120);
    });

    test('week adherence averages logged days only', () {
      final days = [
        MacroDay(
          day: DateTime(2026, 11, 10),
          logged: true,
          protein: 150,
          carbs: 200,
          fat: 60,
        ),
        MacroDay(day: DateTime(2026, 11, 11), logged: true),
        MacroDay(day: DateTime(2026, 11, 12)), // not logged
      ];
      expect(ReportCalculator.weekAdherence(days, goals), 50);
      expect(ReportCalculator.weekAdherence(days, null), isNull);
      expect(ReportCalculator.weekAdherence([days[2]], goals), isNull);
      expect(
        ReportCalculator.weekAdherence(
          days,
          const MacroGoals(protein: 0, carbs: 0, fat: 0, calories: 0),
        ),
        isNull,
      );
    });
  });

  test('daysElapsed', () {
    expect(ReportCalculator.daysElapsed(week, DateTime(2026, 11, 9, 8)), 1);
    expect(ReportCalculator.daysElapsed(week, DateTime(2026, 11, 12)), 4);
    expect(ReportCalculator.daysElapsed(week, DateTime(2026, 11, 30)), 7);
    expect(ReportCalculator.daysElapsed(week, DateTime(2026, 11, 1)), 0);
  });

  test('DailyNutrition.fromMeals sums only meals eaten that day', () {
    MealEntity meal(DateTime? at) => MealEntity(
      id: '$at',
      name: 'm',
      calories: 400,
      protein: 30,
      carbs: 40,
      fat: 10,
      consumedAt: at,
    );
    final day = DateTime(2026, 11, 12, 21);
    final n = DailyNutrition.fromMeals(day, [
      meal(DateTime(2026, 11, 12, 8)),
      meal(DateTime(2026, 11, 12, 13)),
      meal(DateTime(2026, 11, 11, 13)), // yesterday
      meal(null),
    ]);
    expect(n.day, DateTime(2026, 11, 12));
    expect(n.calories, 800);
    expect(n.protein, 60);
    expect(n.isEmpty, isFalse);
  });
}
