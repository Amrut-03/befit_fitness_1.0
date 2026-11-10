import 'package:fitness_app/core/l10n/l10n.dart';
import 'package:fitness_app/features/health_calculator/domain/repositories/health_calculator_repository.dart';

import '../../domain/entities/calculator_result_entity.dart';

import '../datasources/local/health_calculator_local_datasource.dart';

import '../models/calculator_result_model.dart';

class HealthCalculatorRepositoryImpl implements HealthCalculatorRepository {
  final HealthCalculatorLocalDatasource localDatasource;

  HealthCalculatorRepositoryImpl(this.localDatasource);

  @override
  Future<void> saveResult(CalculatorResultEntity result) async {
    final model = CalculatorResultModel(
      value: result.value,

      title: result.title,

      description: result.description,
    );

    await localDatasource.saveResult(model);
  }

  @override
  Future<CalculatorResultEntity?> getLastResult() async {
    final model = await localDatasource.getLastResult();

    if (model == null) {
      return CalculatorResultEntity(
        value: 0,

        title: AppLocale.l10n.calcNoResults,

        description: AppLocale.l10n.calcNoResultsBody,
      );
    }

    return model;
  }
}
