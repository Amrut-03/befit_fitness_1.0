import 'package:fitness_app/features/health_calculator/domain/repositories/health_calculator_reposittory.dart';

import '../entities/calculator_result_entity.dart';

class CalculateWaterIntake {
  final HealthCalculatorRepository repository;

  CalculateWaterIntake(this.repository);

  static const _waterCoefficient = 0.035;

  Future<CalculatorResultEntity> call({required double weight}) async {
    final liters = weight * _waterCoefficient;

    final result = CalculatorResultEntity(
      value: double.parse(liters.toStringAsFixed(1)),

      title: "Daily Water Intake",

      description:
          "General guideline: weight (kg) × 0.035 liters. Adjust for climate, activity, and personal needs.",
    );

    await repository.saveResult(result);

    return result;
  }
}
