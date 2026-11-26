import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/features/health_calculator/domain/repositories/health_calculator_repository.dart';

import '../entities/calculator_result_entity.dart';

class CalculateWaterIntake {
  final HealthCalculatorRepository repository;

  CalculateWaterIntake(this.repository);

  static const _waterCoefficient = 0.035;

  Future<CalculatorResultEntity> call({required double weight}) async {
    final liters = weight * _waterCoefficient;

    final result = CalculatorResultEntity(
      value: double.parse(liters.toStringAsFixed(1)),

      title: AppLocale.l10n.calcWaterResult,

      description: AppLocale.l10n.calcWaterDescription,
    );

    await repository.saveResult(result);

    return result;
  }
}
