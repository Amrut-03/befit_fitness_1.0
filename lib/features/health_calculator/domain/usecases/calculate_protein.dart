import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/features/health_calculator/domain/repositories/health_calculator_repository.dart';

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
    } else if (goal == "Maintain") {
      factor = 1.6;
    }

    final protein = weight * factor;

    final result = CalculatorResultEntity(
      value: double.parse(protein.toStringAsFixed(0)),

      title: AppLocale.l10n.calcProteinResult,

      description: AppLocale.l10n.calcProteinDescription,
    );

    await repository.saveResult(result);

    return result;
  }
}
