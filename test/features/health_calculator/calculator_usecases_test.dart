import 'package:fitness_app/features/health_calculator/domain/entities/calculator_result_entity.dart';
import 'package:fitness_app/features/health_calculator/domain/repositories/health_calculator_repository.dart';
import 'package:fitness_app/features/health_calculator/domain/usecases/calculate_bmi.dart';
import 'package:fitness_app/features/health_calculator/domain/usecases/calculate_calories.dart';
import 'package:fitness_app/features/health_calculator/domain/usecases/calculate_protein.dart';
import 'package:fitness_app/features/health_calculator/domain/usecases/calculate_water_intake.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements HealthCalculatorRepository {}

void main() {
  late _MockRepo repo;

  setUpAll(() {
    registerFallbackValue(
      const CalculatorResultEntity(value: 0, title: '', description: ''),
    );
  });

  setUp(() {
    repo = _MockRepo();
    when(() => repo.saveResult(any())).thenAnswer((_) async {});
  });

  group('CalculateBMI', () {
    test('computes BMI to one decimal and saves it', () async {
      final result = await CalculateBMI(repo)(weight: 70, height: 175);

      expect(result.value, 22.9);
      expect(result.title, 'Normal');
      verify(() => repo.saveResult(result)).called(1);
    });

    test('maps BMI to categories at the boundaries', () async {
      final bmi = CalculateBMI(repo);
      // height 100 cm → BMI equals weight.
      expect((await bmi(weight: 18.4, height: 100)).title, 'Underweight');
      expect((await bmi(weight: 18.5, height: 100)).title, 'Normal');
      expect((await bmi(weight: 25, height: 100)).title, 'Overweight');
      expect((await bmi(weight: 30, height: 100)).title, 'Obese');
    });
  });

  group('CalculateCalories (Mifflin-St Jeor)', () {
    test('male maintenance calories', () async {
      final result = await CalculateCalories(repo)(
        weight: 70,
        height: 175,
        age: 25,
        gender: 'Male',
        activity: 1.55,
      );
      // BMR = 700 + 1093.75 - 125 + 5 = 1673.75; × 1.55 = 2594.3
      expect(result.value, 2594);
    });

    test('female maintenance calories', () async {
      final result = await CalculateCalories(repo)(
        weight: 60,
        height: 165,
        age: 30,
        gender: 'Female',
        activity: 1.2,
      );
      // BMR = 600 + 1031.25 - 150 - 161 = 1320.25; × 1.2 = 1584.3
      expect(result.value, 1584);
    });

    test('clamps the activity factor to 1.2–1.9', () async {
      final calc = CalculateCalories(repo);
      final low = await calc(
        weight: 70,
        height: 175,
        age: 25,
        gender: 'Male',
        activity: 0.5,
      );
      final high = await calc(
        weight: 70,
        height: 175,
        age: 25,
        gender: 'Male',
        activity: 5,
      );
      expect(low.value, (1673.75 * 1.2).roundToDouble());
      expect(high.value, (1673.75 * 1.9).roundToDouble());
    });
  });

  group('CalculateProtein', () {
    test('uses g/kg by goal, defaulting to 1.6', () async {
      final calc = CalculateProtein(repo);
      expect((await calc(weight: 70, goal: 'Fat Loss')).value, 140);
      expect((await calc(weight: 70, goal: 'Muscle Gain')).value, 154);
      expect((await calc(weight: 70, goal: 'Maintain')).value, 112);
      expect((await calc(weight: 70, goal: 'Other')).value, 112);
    });
  });

  group('CalculateWaterIntake', () {
    test('uses 35 ml per kg', () async {
      final result = await CalculateWaterIntake(repo)(weight: 70);
      expect(result.value, 2.5);
      verify(() => repo.saveResult(any())).called(1);
    });
  });
}
