import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/features/onboarding/domain/utils/goal_calculator.dart';
import 'package:fitness_app/features/onboarding/domain/utils/macros_calculator.dart';

void main() {
  group('GoalCalculator', () {
    test('returns expected step goals for each goal', () {
      expect(GoalCalculator.calculateStepGoal('Lose Weight', 'Moderate'), 12000);
      expect(GoalCalculator.calculateStepGoal('Build Muscle', 'Moderate'), 8000);
      expect(GoalCalculator.calculateStepGoal('Stay Fit', 'Moderate'), 10000);
      expect(GoalCalculator.calculateStepGoal('Improve Endurance', 'Moderate'), 15000);
      expect(GoalCalculator.calculateStepGoal('Unknown Goal', 'Moderate'), 10000);
    });

    test('calculates daily calories for a sedentary male', () {
      final result = GoalCalculator.calculateDailyCalories(
        gender: 'Male',
        weight: 70,
        height: 175,
        age: 25,
        activityLevel: 'Sedentary',
      );

      expect(result, 2009);
    });

    test('calculates daily calories for a moderately active female', () {
      final result = GoalCalculator.calculateDailyCalories(
        gender: 'Female',
        weight: 60,
        height: 165,
        age: 30,
        activityLevel: 'Moderate',
      );

      expect(result, 2046);
    });
  });

  group('MacroCalculator', () {
    test('calculates macros for lose weight goal', () {
      final result = MacroCalculator.calculate(
        calories: 2000,
        goal: 'Lose Weight',
      );

      expect(result['protein'], closeTo(200.0, 0.01));
      expect(result['carbs'], closeTo(150.0, 0.01));
      expect(result['fat'], closeTo(66.67, 0.01));
    });

    test('calculates macros for build muscle goal', () {
      final result = MacroCalculator.calculate(
        calories: 2000,
        goal: 'Build Muscle',
      );

      expect(result['protein'], closeTo(150.0, 0.01));
      expect(result['carbs'], closeTo(225.0, 0.01));
      expect(result['fat'], closeTo(55.56, 0.01));
    });
  });
}
