import 'package:fitness_app/features/health_calculator/domain/repositories/health_calculator_reposittory.dart';

import '../entities/calculator_result_entity.dart';

class CalculateBMI {
  final HealthCalculatorRepository repository;

  CalculateBMI(this.repository);

  Future<CalculatorResultEntity> call({
    required double weight,

    required double height,
  }) async {
    final bmi = weight / ((height / 100) * (height / 100));

    String category;

    if (bmi < 18.5) {
      category = "Underweight";
    } else if (bmi < 25) {
      category = "Normal";
    } else if (bmi < 30) {
      category = "Overweight";
    } else {
      category = "Obese";
    }

    final result = CalculatorResultEntity(
      value: double.parse(bmi.toStringAsFixed(1)),

      title: category,

      description: "Your BMI indicates $category body weight.",
    );

    await repository.saveResult(result);

    return result;
  }
}
