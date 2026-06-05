import 'package:fitness_app/features/health_calculator/domain/repositories/health_calculator_reposittory.dart';

import '../entities/calculator_result_entity.dart';

class CalculateProtein {
  final HealthCalculatorRepository repository;

  CalculateProtein(this.repository);

  Future<CalculatorResultEntity> call({
    required double weight,

    required String goal,
  }) async {
    double factor = 1.6;

    if (goal == "Fat Loss") {
      factor = 2.0;
    } else if (goal == "Muscle Gain") {
      factor = 2.2;
    }

    final protein = weight * factor;

    final result = CalculatorResultEntity(
      value: double.parse(protein.toStringAsFixed(0)),

      title: "Protein Intake",

      description: "Recommended protein intake per day.",
    );

    await repository.saveResult(result);

    return result;
  }
}
