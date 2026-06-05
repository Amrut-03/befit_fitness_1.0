import 'package:fitness_app/features/health_calculator/domain/repositories/health_calculator_reposittory.dart';

import '../entities/calculator_result_entity.dart';

class CalculateCalories {
  final HealthCalculatorRepository repository;

  CalculateCalories(this.repository);

  Future<CalculatorResultEntity> call({
    required double weight,

    required double height,

    required int age,

    required String gender,

    required double activity,
  }) async {
    double bmr;

    if (gender == "Male") {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    final maintenance = bmr * activity;

    final result = CalculatorResultEntity(
      value: double.parse(maintenance.toStringAsFixed(0)),

      title: "Maintenance Calories",

      description: "Calories needed to maintain your weight.",
    );

    await repository.saveResult(result);

    return result;
  }
}
