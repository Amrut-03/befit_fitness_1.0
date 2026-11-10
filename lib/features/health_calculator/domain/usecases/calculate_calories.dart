import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/features/health_calculator/domain/repositories/health_calculator_repository.dart';

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

    final maintenance = bmr * activity.clamp(1.2, 1.9);

    final result = CalculatorResultEntity(
      value: double.parse(maintenance.toStringAsFixed(0)),

      title: AppLocale.l10n.calcCaloriesResult,

      description: AppLocale.l10n.calcCaloriesDescription,
    );

    await repository.saveResult(result);

    return result;
  }
}
