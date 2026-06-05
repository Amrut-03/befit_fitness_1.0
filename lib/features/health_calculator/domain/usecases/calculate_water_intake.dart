import 'package:fitness_app/features/health_calculator/domain/repositories/health_calculator_reposittory.dart';

import '../entities/calculator_result_entity.dart';

class CalculateWaterIntake {
  final HealthCalculatorRepository repository;

  CalculateWaterIntake(this.repository);

  Future<CalculatorResultEntity> call({required double weight}) async {
    final liters = weight * 0.035;

    final result = CalculatorResultEntity(
      value: double.parse(liters.toStringAsFixed(1)),

      title: "Daily Water Intake",

      description: "Recommended water intake per day.",
    );

    await repository.saveResult(result);

    return result;
  }
}
