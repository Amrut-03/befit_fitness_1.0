import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/features/health_calculator/domain/repositories/health_calculator_repository.dart';

import '../entities/calculator_result_entity.dart';

class CalculateBMI {
  final HealthCalculatorRepository repository;

  CalculateBMI(this.repository);

  Future<CalculatorResultEntity> call({
    required double weight,

    required double height,
  }) async {
    final bmi = weight / ((height / 100) * (height / 100));

    final l10n = AppLocale.l10n;
    String category;

    if (bmi < 18.5) {
      category = l10n.calcBmiUnderweight;
    } else if (bmi < 25) {
      category = l10n.calcBmiNormal;
    } else if (bmi < 30) {
      category = l10n.calcBmiOverweight;
    } else {
      category = l10n.calcBmiObese;
    }

    final result = CalculatorResultEntity(
      value: double.parse(bmi.toStringAsFixed(1)),

      title: category,

      description: l10n.calcBmiDescription(category),
    );

    await repository.saveResult(result);

    return result;
  }
}
