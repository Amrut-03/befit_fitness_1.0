import 'package:fitness_app/features/water_intake/domain/entities/water_day.dart';
import 'package:fitness_app/features/water_intake/domain/entities/water_entry.dart';
import 'package:fitness_app/features/water_intake/domain/utils/water_goal.dart';
import 'package:fitness_app/features/water_intake/presentation/widgets/water_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WaterGoal.recommendedMl', () {
    test('35 ml per kg, rounded to the nearest 50 ml', () {
      expect(WaterGoal.recommendedMl(70), 2450);
      expect(WaterGoal.recommendedMl(72), 2500); // 2520 → 2500
      expect(WaterGoal.recommendedMl(73), 2550); // 2555 → 2550
    });

    test('falls back when weight is missing', () {
      expect(WaterGoal.recommendedMl(null), WaterGoal.fallbackMl);
      expect(WaterGoal.recommendedMl(0), WaterGoal.fallbackMl);
    });

    test('is clamped to the allowed range', () {
      expect(WaterGoal.recommendedMl(5), WaterGoal.minMl);
      expect(WaterGoal.recommendedMl(400), WaterGoal.maxMl);
    });
  });

  test('dayKey is zero-padded local yyyy-MM-dd', () {
    expect(WaterGoal.dayKey(DateTime(2026, 3, 7, 23, 59)), '2026-03-07');
  });

  test('formatWater', () {
    expect(formatWater(250), '250 ml');
    expect(formatWater(1000), '1 L');
    expect(formatWater(1250), '1.25 L');
    expect(formatWater(2400), '2.4 L');
  });

  group('WaterDay', () {
    WaterEntry e(int ml) => WaterEntry(id: '$ml', ml: ml, at: DateTime(2026));

    test('totals, progress and goal', () {
      final day = WaterDay(
        day: DateTime(2026, 11, 10),
        goalMl: 2000,
        entries: [e(500), e(1000)],
      );
      expect(day.totalMl, 1500);
      expect(day.progress, 0.75);
      expect(day.goalReached, isFalse);
    });

    test('progress caps at 1 once over the goal', () {
      final day = WaterDay(
        day: DateTime(2026, 11, 10),
        goalMl: 1000,
        entries: [e(1500)],
      );
      expect(day.progress, 1);
      expect(day.goalReached, isTrue);
    });
  });
}
